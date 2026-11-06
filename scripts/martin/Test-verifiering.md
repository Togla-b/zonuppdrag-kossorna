# Verifieringsanteckning – Martin, elev-36 (10.40.5.5)

Datum: 2026-11-06 · Loggserver: 172.20.1.58:6514 (TLS) · Konfiguration: /etc/rsyslog.d/90-log.conf

| Identifierare | Tid (UTC) | Värdnamn | Källa | Söksträng | Hittad centralt? | Avvikelse? |
| --- | --- | --- | --- | --- | --- | --- |
| VA1-martin | 13:21:37 | elev-36 | Systemlogg (user.notice) | VA1-martin | Ja, TLS, 0,4 s fördröjning | Ingen |
| VA2-martin | 13:10:04 | elev-36 | Autentisering (authpriv.notice) | VA2-martin | Ja, TLS, 0,5 s fördröjning | Ingen |
| VA3 brandvägg | 12:50:41 | elev-36 | Kärnlogg (ZON-UT-DROP) | DPT=81 | Ja, både TLS och KLARTEXT | Ja, dubbel leverans (se nedan) |
| VA3b brandvägg | 13:09:12 | elev-36 | Kärnlogg (ZON-UT-DROP) | DPT=83 | Ja, bara TLS, 0,3–0,5 s fördröjning | Ingen, efter åtgärd |
| VA4-martin | 13:21:59 | elev-36 | Audit (EXECVE + SYSCALL) | VA4-martin, sedan 1793971319.441:9604 | Ja, TLS, auid=1000 (student), euid=0 (root) | Ingen |

Alla rader kom fram med rätt värdnamn och avsändaradressen 172.20.1.136 (eth1). Skillnaden mellan serverns tidsstämpel och mottagningstiden var under en sekund, vilket visar att klockan är synkad.

## Avvikelser

Testhändelsen DPT=81 kom fram två gånger, en gång över TLS och en gång i klartext till port 514. Orsaken var att konfigurationen från vecka 4 (/etc/rsyslog.d/60-brandvagg.conf) fortfarande skickade kern.* i klartext, parallellt med 90-log.conf.

Att ta bort brandväggsregeln för tcp/514 räckte inte, eftersom rsyslogs befintliga anslutning släpptes igenom av ct state established,related accept. Klartexten slutade först när filen flyttades till /root/60-brandvagg.conf.bak och rsyslog startades om. Ett nytt test med DPT=83 kom bara fram över TLS. D5 i flödestabellen ändrades till tcp/6514.

Systemlogg- och autentiseringshändelser påverkades inte, eftersom den gamla filen bara skickade kern.*.

## Belägg

### VA1 – Systemlogg
```
mottaget 2026-11-06T13:21:38.191Z TLS      | 2026-11-06T13:21:37.804850+00:00 172.20.1.136 elev-36 sparbarhet[99863] VA1-martin
```

### VA2 – Autentisering
```
mottaget 2026-11-06T13:10:05.187Z TLS      | 2026-11-06T13:10:04.685456+00:00 172.20.1.136 elev-36 sparbarhet[99860] VA2-martin
```

### VA3 – Brandvägg, före åtgärd (dubbel leverans)
```
mottaget 2026-11-06T12:50:41.687Z KLARTEXT | 2026-11-06T12:50:41+00:00 172.20.1.136 elev-36 kernel: ZON-UT-DROP IN= OUT=eth0 SRC=2.28.100.109 DST=1.1.1.1 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=10660 DF PROTO=TCP SPT=41978 DPT=81 WINDOW=64240 RES=0x00 SYN URGP=0
mottaget 2026-11-06T12:50:41.687Z TLS      | 2026-11-06T12:50:41.380496+00:00 172.20.1.136 elev-36 kernel ZON-UT-DROP IN= OUT=eth0 SRC=2.28.100.109 DST=1.1.1.1 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=10660 DF PROTO=TCP SPT=41978 DPT=81 WINDOW=64240 RES=0x00 SYN URGP=0
```

### VA3b – Brandvägg, efter åtgärd (bara TLS)
```
mottaget 2026-11-06T13:09:13.187Z TLS      | 2026-11-06T13:09:12.722496+00:00 172.20.1.136 elev-36 kernel ZON-UT-DROP IN= OUT=eth0 SRC=2.28.100.109 DST=1.1.1.1 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=56243 DF PROTO=TCP SPT=43152 DPT=83 WINDOW=64240 RES=0x00 SYN URGP=0
mottaget 2026-11-06T13:09:14.087Z TLS      | 2026-11-06T13:09:13.748140+00:00 172.20.1.136 elev-36 kernel ZON-UT-DROP IN= OUT=eth0 SRC=2.28.100.109 DST=1.1.1.1 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=56244 DF PROTO=TCP SPT=43152 DPT=83 WINDOW=64240 RES=0x00 SYN URGP=0
```

### VA4 – Audit (sökt på 1793971319.441:9604)
```
mottaget 2026-11-06T13:21:59.691Z TLS      | 2026-11-06T13:21:59.443636+00:00 172.20.1.136 elev-36 audisp-syslog[98669] type=SYSCALL msg=audit(1793971319.441:9604): arch=c000003e syscall=59 success=yes exit=0 a0=563df09f6028 a1=563df0a0e5f0 a2=563df0a4ece0 a3=64 items=2 ppid=99869 pid=99870 auid=1000 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=198 comm="touch" exe="/usr/bin/touch" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="root-cmd" ARCH=x86_64 SYSCALL=execve AUID="student" UID="root" GID="root" EUID="root" SUID="root" FSUID="root" EGID="root" SGID="root" FSGID="root"
mottaget 2026-11-06T13:21:59.691Z TLS      | 2026-11-06T13:21:59.443812+00:00 172.20.1.136 elev-36 audisp-syslog[98669] type=EXECVE msg=audit(1793971319.441:9604): argc=2 a0="/usr/bin/touch" a1="/tmp/VA4-martin"
mottaget 2026-11-06T13:21:59.691Z TLS      | 2026-11-06T13:21:59.443868+00:00 172.20.1.136 elev-36 audisp-syslog[98669] type=CWD msg=audit(1793971319.441:9604): cwd="/home/student"
mottaget 2026-11-06T13:21:59.693Z TLS      | 2026-11-06T13:21:59.444087+00:00 172.20.1.136 elev-36 audisp-syslog[98669] type=EOE msg=audit(1793971319.441:9604):
```

Samma händelse i autentiseringsloggen (sudo):
```
mottaget 2026-11-06T13:21:59.690Z TLS      | 2026-11-06T13:21:59.432481+00:00 172.20.1.136 elev-36 sudo[99865] student : TTY=pts/0 ; PWD=/home/student ; USER=root ; COMMAND=/usr/bin/touch /tmp/VA4-martin