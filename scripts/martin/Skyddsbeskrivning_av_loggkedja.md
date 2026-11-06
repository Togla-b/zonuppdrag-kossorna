# Skyddsbeskrivning av loggkedjan – Martin, elev-36 (10.40.5.5)

Datum: 2026-11-06

Kedja: journald/imjournal + auditd (syslog-plugin) → rsyslog → TLS 6514 → loggservern 172.20.1.58

## 1. Vem kan ändra eller radera loggen lokalt?

Loggfilerna på elev-36 ägs av root och kan bara läsas och skrivas av root (rättigheterna 0600). Eftersom student är medlem i gruppen wheel kan student bli root med sudo, och därmed ändra eller radera loggarna. Filerna har inget extra skydd: varken append-only (a) eller immutable (i) är satt. Även om de vore satta kan root ta bort attributen med chattr. Slutsatsen är att root och alla som kan använda sudo kan ändra eller radera loggen lokalt. Den lokala loggen kan därför inte litas på efter ett intrång där angriparen har fått root.

Belägg:
```
$ ls -l /var/log/messages /var/log/secure
-rw-------. 1 root root 10388183 Nov  6 13:40 /var/log/messages
-rw-------. 1 root root    68966 Nov  6 13:21 /var/log/secure

$ ls -l /var/log/audit/audit.log
ls: cannot access '/var/log/audit/audit.log': Permission denied
$ sudo ls -l /var/log/audit/audit.log
-rw-------. 1 root root 3287123 Nov  6 13:41 /var/log/audit/audit.log

$ getent group wheel
wheel:x:10:student

$ sudo lsattr /var/log/messages /var/log/secure
--------------e------- /var/log/messages
--------------e------- /var/log/secure
```

## 2. Vem kan ändra eller radera loggen centralt?

Jag har inget konto på loggservern 172.20.1.58. Min enda åtkomst är kommandot loggsök på jump, som bara läser och bara visar rader från min egen server. Loggservern sorterar raderna efter avsändarens adress (172.20.1.136), inte efter värdnamnet i meddelandet, så ingen elev kan skriva i någon annans logg. Det är bara loggserverns administratörer som kan ändra eller radera den centrala loggen.

Det syns också i praktiken: klartextraderna från testet med DPT=81 ligger kvar på loggservern trots att jag har åtgärdat felet. Det som har skickats går inte att ta tillbaka.

Begränsning: loggservern kontrollerar inte vem som skickar, utan identifierar avsändaren på adressen (RFC 5425 §5.3 och §6.1). Den som har root på elev-36 kan därför skicka falska rader som ser ut att komma från min server. TLS ger inte heller något kvitto på att en rad faktiskt sparades (RFC 5425 §6.3).

Belägg:
```
mottaget 2026-11-06T12:50:41.687Z KLARTEXT | 2026-11-06T12:50:41+00:00 172.20.1.136 elev-36 kernel: ZON-UT-DROP ... DPT=81 ...
mottaget 2026-11-06T13:10:05.187Z TLS      | 2026-11-06T13:10:04.685456+00:00 172.20.1.136 elev-36 sparbarhet[99860] VA2-martin
```

## 3. Lagringstid och rotation

**Lokalt:**
- rsyslogs filer (messages, secure, cron, maillog, spooler) roteras varje vecka och fyra gamla versioner sparas. Loggen finns alltså kvar i cirka fyra till fem veckor, sedan raderas den äldsta.
- Journalen sparas bara i minnet (/run/log/journal), eftersom Storage=auto gäller och /var/log/journal saknas. Hela journalen försvinner vid omstart.
- auditd roterar efter storlek: fem filer på högst 8 MB, cirka 40 MB totalt. När gränsen nås skrivs den äldsta filen över. Lagringstiden i dagar beror på hur mycket som loggas.

Slutsats: lokalt finns loggarna kvar i några veckor som mest. Journalen försvinner redan vid omstart. Ett intrång som upptäcks efter mer än en månad går inte att utreda med bara den lokala loggen.

**Centralt:** Jag har ingen åtkomst till loggserverns inställningar och vet därför inte hur länge loggarna sparas där. Det är en öppen fråga till läraren.

Belägg:
```
$ grep -E "^(weekly|daily|monthly|rotate|compress|dateext)" /etc/logrotate.conf
weekly
rotate 4
dateext

$ cat /etc/logrotate.d/rsyslog
/var/log/cron
/var/log/maillog
/var/log/messages
/var/log/secure
/var/log/spooler
{
    missingok
    sharedscripts
    postrotate
        /usr/bin/systemctl -s HUP kill rsyslog.service >/dev/null 2>&1 || true
    endscript
}

$ ls -ld /var/log/journal /run/log/journal
ls: cannot access '/var/log/journal': No such file or directory
drwxr-sr-x+ 4 root systemd-journal 80 Oct  4 15:45 /run/log/journal

$ grep -iE "^#?(Storage|SystemMaxUse)" /etc/systemd/journald.conf
#Storage=auto
#SystemMaxUse=

$ journalctl --disk-usage
Archived and active journals take up 72.8M in the file system.

$ sudo grep -E "^(max_log_file|num_logs|max_log_file_action)" /etc/audit/auditd.conf
max_log_file = 8
num_logs = 5
max_log_file_action = ROTATE
```

## 4. Vad händer när mottagaren är onåbar?

Vidarebefordran använder en diskstödd kö (LinkedList med queue.filename="fwd_log"). När loggservern inte svarar sparas meddelandena först i minnet och skrivs sedan till disk i /var/lib/rsyslog. Med queue.saveOnShutdown="on" sparas kön även när rsyslog startas om, och med action.resumeRetryCount="-1" försöker rsyslog skicka igen i all oändlighet. När loggservern blir nåbar igen levereras det som har köats, i efterhand.

Att kön håller verifierades i U5.2: en händelse som skickades under ett avbrott, med två omstarter av rsyslog, levererades i efterhand när blockeringen togs bort.

Gräns: queue.maxDiskSpace är inte satt, så kön har ingen egen gräns och begränsas bara av ledigt utrymme på / (35 GB). Det skyddar mot att loggar tappas vid ett långt avbrott, men en kö som växer obegränsat kan till slut fylla disken och påverka hela servern, även de lokala loggarna. Om disken blir full kan rsyslog inte lägga fler meddelanden i kön, och nya händelser går förlorade. En förbättring vore att sätta queue.maxDiskSpace till ett rimligt värde.

En begränsning till: journalen ligger bara i minnet. Händelser som rsyslog ännu inte hunnit läsa från journalen försvinner om servern startas om, oavsett kön.

Med en ren minneskö (utan queue.filename) hade allt som väntade i kön försvunnit vid omstart av rsyslog.

Belägg:
```
$ sudo cat /etc/rsyslog.d/90-log.conf
global(
  DefaultNetstreamDriver="gtls"
  DefaultNetstreamDriverCAFile="/etc/pki/rsyslog/ca.pem"
)

action(type="omfwd" target="172.20.1.58" port="6514" protocol="tcp" template="RSYSLOG_SyslogProtocol23Format"
  StreamDriver="gtls" StreamDriverMode="1"
  StreamDriverAuthMode="x509/name"
  StreamDriverPermittedPeers="log.sec.chas-lab.dev"
  queue.type="LinkedList" queue.filename="fwd_log"
  queue.saveOnShutdown="on" action.resumeRetryCount="-1"
)

$ sudo ls -l /var/lib/rsyslog          # mottagaren nåbar: ingen kö på disk
total 4
-rw-------. 1 root root 126 Nov  6 13:49 imjournal.state

$ df -h /var/lib/rsyslog
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        38G  1.8G   35G   5% /
```

## Scenario: angripare med root på elev-36

**Så skulle angriparen försöka förstöra bevisen:**
1. Radera eller ändra /var/log/secure, /var/log/messages och /var/log/audit/audit.log. Det går eftersom root äger filerna och inga skyddsattribut är satta.
2. Starta om servern eller rensa journalen. Journalen ligger bara i minnet och försvinner då helt.
3. Stoppa loggningen: systemctl stop rsyslog, service auditd stop eller auditctl -D för att ta bort auditreglerna. Alternativt ändra 90-log.conf, eller blockera tcp/6514 i nftables och sedan radera köfilerna i /var/lib/rsyslog.
4. Skicka falska rader med logger för att dölja det verkliga förloppet. Loggservern identifierar bara avsändaren på adressen och kan inte skilja dem från äkta rader.

**Det kedjan ändå fångar:**
- Allt som redan hade skickats. Leveransen tar under en sekund (se verifieringsanteckningen), och angriparen har inget konto på loggservern.
- Själva intrånget: inloggningen i secure, sudo-raden och auditposten med auid. Auditposten visar vem som körde kommandot som root, som i VA4: auid=1000 (student) trots euid=0.
- Troligen även angriparens första försök att stoppa loggningen. Kommandot sudo systemctl stop rsyslog loggas av auditd och skickas innan rsyslog hinner stängas.
- Att elev-36 plötsligt tystnar. Det syns centralt, precis som servern som slutade skicka i U5.4.

**Det kedjan inte fångar:**
- Händelser efter att loggningen har stoppats.
- Rader som låg i kön men raderades innan de skickades.
- Ändringar som görs innan en rad skickas. TLS skyddar transporten, inte det som står på servern (RFC 5425 §6).