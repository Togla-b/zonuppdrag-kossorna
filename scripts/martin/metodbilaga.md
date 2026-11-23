# Metodbilaga – härdningsrapport elev-36 (Martin)

AI-verktyg: Claude (Anthropic), i en ny chatt utan tidigare sammanhang
Datum: 2026-11-18

## 1. Underlag som matades in

| Underlag | Källa | Maskerat |
| --- | --- | --- |
| Härdningslista, 5 rader | Egen fil, hardningslista.md | Inget behövde maskeras |
| `sestatus` | elev-36 | Inget behövde maskeras |
| `semodule -l \| grep zonvakt` | elev-36 | Inget behövde maskeras |
| `ps -eZ \| grep zonvakt` | elev-36 | Inget behövde maskeras. Processnumret 1009 är inte känsligt. |
| Utdata från `verifiera-hardning` | elev-36 | Inget behövde maskeras |

Alla underlag kontrollerades innan de matades in. Inget av dem innehöll lösenord, nycklar, tokens, flaggor eller adresser som inte är publika.

## 2. Prompt, ordagrant

**Försök 1:** prompten skickades innan platshållarna var ifyllda. Tre av fem underlag stod kvar som "[klistra in]". AI:n hittade inte på något, utan markerade själv luckorna och skrev bara om det som fanns. Det utkastet användes inte.

**Försök 2**, som användes:

```
Jag ska skriva en härdningsrapport för min Rocky Linux 9-server elev-36. Nedan finns min härdningslista och utdata från servern. Skriv ett utkast till en härdningsrapport som beskriver varje åtgärd, dess effekt och hur den verifierades. Hitta inte på något som inte står i underlaget.

=== Härdningslista ===
| Nr | Åtgärd | Motivering – varför just här | Förväntad effekt | Hur den verifierades | Skript? |
| --- | --- | --- | --- | --- | --- |
| 1 | SELinux i enforcing, nu och efter omstart | Servern är loggserver med hög känslighet. Om en tjänst tas över och SELinux inte är enforcing finns inget som begränsar en process som kör som root. | getenforce visar Enforcing och /etc/selinux/config säger SELINUX=enforcing | getenforce → Enforcing, grep ^SELINUX= /etc/selinux/config → enforcing. GÄLLER i verifiera-hardning även efter omstart. | Ja |
| 2 | zonvakt under egen policy (zonvakt_t), inte permissiv | zonvakt kör som root och tar emot anslutningar från nätet. Utan egen policy körde den i unconfined_service_t och kunde skriva i /etc, vilket overtrad visade. | zonvakt kör i zonvakt_t, hej fungerar och overtrad nekas | ps -eZ | grep zonvakt → zonvakt_t. echo overtrad → nekad: Permission denied. AVC 12665: write på etc_t, permissive=0. | Ja |
| 3 | Bestående filkontext för /srv/zonwebb (httpd_sys_content_t) | httpd ska bara läsa webbinnehåll. Utan en regel slutar sidan fungera vid nästa relabel, och då är det lätt att stänga av SELinux för att få det att fungera. | /srv/zonwebb har typen httpd_sys_content_t, och regeln finns kvar | semanage fcontext -l -C visar regeln för /srv/zonwebb. curl http://127.0.0.1/zon/kvitto.txt gav kvittot. | Ja |
| 4 | Default deny i nftables, in och ut | Utan default deny kan alla i labbnätet nå alla tjänster på servern, och servern kan skicka ut vad som helst. Bara flödena i flödestabellen ska vara öppna. | Kedjorna in och ut har policy drop, och nekad trafik loggas som ZON-IN-DROP och ZON-UT-DROP | nft list chain inet zon in → policy drop. Testskriptet i vecka 4 gav förväntat utfall på alla rader. | Ja |
| 5 | auditd loggar root-kommandon (nyckel root-cmd) | Flera kan bli root med sudo. Utan auditregeln går det inte att se vem som körde ett kommando som root. | Varje root-kommando loggas med auid, alltså vem som loggade in | auditctl -l visar regeln root-cmd. Testet med VA4 gav auid=1000 (student) och euid=0. | Ja |

=== sestatus ===
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      33

=== semodule -l | grep zonvakt ===
zonvakt

=== ps -eZ | grep zonvakt ===
system_u:system_r:zonvakt_t:s0     1009 ?        00:00:00 zonvakt

=== verifiera-hardning ===
GÄLLER SELinux i tvingande läge nu (getenforce = Enforcing)
GÄLLER SELinux enforcing efter omstart (/etc/selinux/config)
GÄLLER zonvakt kör i egen domän zonvakt_t
GÄLLER zonvakt-domänen är inte permissiv
GÄLLER /srv/zonwebb har bestående fcontext-regel
GÄLLER paketfiltret: policy drop inkommande
GÄLLER auditd loggar root-kommandon (nyckel root-cmd)
slutkod 0
```

## 3. Råsvar, oredigerat

```
Härdningsrapport – elev-36 (Rocky Linux 9) – utkast
Inledning

Rapporten beskriver fem härdningsåtgärder på servern elev-36, som används som loggserver med hög känslighet. För varje åtgärd anges motivering, förväntad effekt och hur effekten verifierades. Underlaget är härdningslistan samt utdata från sestatus, semodule -l | grep zonvakt, ps -eZ | grep zonvakt och verifieringsskriptet verifiera-hardning. Där en uppgift bara finns i härdningslistan och inte syns i den bifogade serverutdatan anges det.

Åtgärd 1 – SELinux i enforcing, nu och efter omstart

Motivering. Servern är loggserver med hög känslighet. Om en tjänst tas över och SELinux inte är enforcing finns inget som begränsar en process som kör som root.

Effekt. SELinux är aktiverat med policyn targeted och kör i tvingande läge. Läget är också inställt i konfigurationsfilen, så det gäller även efter omstart.

Verifiering. sestatus visar SELinux status: enabled, Loaded policy name: targeted, Current mode: enforcing och Mode from config file: enforcing. verifiera-hardning rapporterar GÄLLER SELinux i tvingande läge nu (getenforce = Enforcing) och GÄLLER SELinux enforcing efter omstart (/etc/selinux/config). Enligt härdningslistan gav verifiera-hardning GÄLLER även efter en omstart; själva omstarten syns inte i den bifogade utdatan.

Åtgärd 2 – zonvakt under egen policy (zonvakt_t), inte permissiv

Motivering. zonvakt kör som root och tar emot anslutningar från nätet. Utan egen policy körde den i unconfined_service_t och kunde skriva i /etc, vilket testet overtrad visade.

Effekt. zonvakt kör i en egen domän, zonvakt_t, som inte är permissiv. Försök att skriva i /etc nekas.

Verifiering. semodule -l | grep zonvakt visar att modulen zonvakt är laddad. ps -eZ | grep zonvakt visar processen med PID 1009 i kontexten system_u:system_r:zonvakt_t:s0. verifiera-hardning rapporterar GÄLLER zonvakt kör i egen domän zonvakt_t och GÄLLER zonvakt-domänen är inte permissiv. Enligt härdningslistan gav echo overtrad svaret nekad: Permission denied, och AVC 12665 visade write på etc_t med permissive=0; den utdatan finns inte med i underlaget. Härdningslistan anger också att hej ska fungera, men någon verifiering av det finns varken i listans verifieringskolumn eller i serverutdatan.

Åtgärd 3 – Bestående filkontext för /srv/zonwebb (httpd_sys_content_t)

Motivering. httpd ska bara läsa webbinnehåll. Utan en bestående regel slutar sidan fungera vid nästa relabel, och då är det lätt att stänga av SELinux för att få det att fungera.

Effekt. /srv/zonwebb har typen httpd_sys_content_t, och regeln finns kvar i den lokala policyn så att den överlever en relabel.

Verifiering. verifiera-hardning rapporterar GÄLLER /srv/zonwebb har bestående fcontext-regel. Enligt härdningslistan visar semanage fcontext -l -C regeln för /srv/zonwebb, och curl http://127.0.0.1/zon/kvitto.txt gav kvittot. Varken regelns typ eller den faktiska filkontexten på katalogen (till exempel ls -Z) syns i den bifogade utdatan.

Åtgärd 4 – Default deny i nftables, in och ut

Motivering. Utan default deny kan alla i labbnätet nå alla tjänster på servern, och servern kan skicka ut vad som helst. Bara flödena i flödestabellen ska vara öppna.

Effekt. Enligt härdningslistan har kedjorna in och ut policy drop, och nekad trafik loggas med prefixen ZON-IN-DROP och ZON-UT-DROP.

Verifiering. verifiera-hardning rapporterar GÄLLER paketfiltret: policy drop inkommande. Enligt härdningslistan visar nft list chain inet zon in policy drop, och testskriptet från vecka 4 gav förväntat utfall på alla rader. Underlaget innehåller ingen kontroll av den utgående kedjan och inget som visar loggprefixen, så de delarna av effekten är inte verifierade i den bifogade utdatan.

Åtgärd 5 – auditd loggar root-kommandon (nyckel root-cmd)

Motivering. Flera användare kan bli root med sudo. Utan auditregeln går det inte att se vem som körde ett kommando som root.

Effekt. Varje root-kommando loggas med auid, alltså vem som ursprungligen loggade in.

Verifiering. verifiera-hardning rapporterar GÄLLER auditd loggar root-kommandon (nyckel root-cmd). Enligt härdningslistan visar auditctl -l regeln root-cmd, och testet med VA4 gav auid=1000 (student) och euid=0; den utdatan finns inte med i underlaget.

Sammanfattning

Alla fem åtgärder är markerade som skriptade i härdningslistan. verifiera-hardning rapporterade GÄLLER på samtliga sju kontroller och avslutades med slutkod 0. Följande delar vilar enbart på härdningslistan och bör kompletteras med utdata från servern innan rapporten är klar:

att verifiera-hardning gav GÄLLER efter en faktisk omstart (åtgärd 1)
echo overtrad och AVC 12665, samt att hej fungerar (åtgärd 2)
semanage fcontext -l -C, den faktiska kontexten på /srv/zonwebb och curl-testet (åtgärd 3)
policy drop i utgående kedja och loggprefixen ZON-IN-DROP/ZON-UT-DROP (åtgärd 4)
auditctl -l och auditposten från testet med VA4 (åtgärd 5)
```

## 4. Rättelselogg

20 påståenden numrerades och dömdes med kommando och utdata från elev-36. 16 stämmer, 2 är fel och 2 är ogrundade eller delvis ogrundade. Hela loggen finns i rattelselogg.md.

| Påst. nr | Påstående (kort) | Dom | Kommando som avgjorde | Ändrat till |
| --- | --- | --- | --- | --- |
| P10 | Utan egen policy (unconfined_service_t) kunde zonvakt skriva i /etc | ogrundat | `sudo grep OBS /var/log/zonvakt/zonvakt.log` | När zonvakt_t var permissiv skrev zonvakt i /etc (OBS-rad 15:28:25). |
| P16 | Nekad trafik loggas som ZON-IN-DROP och ZON-UT-DROP | delvis ogrundat | `sudo journalctl -k -g ZON-IN-DROP --since today` | ZON-UT-DROP visat med DPT=85. Ingen ZON-IN-DROP loggad sedan omstarten. |
| P17 | Flera användare kan bli root med sudo | fel | `getent group wheel` | Student kan bli root med sudo, via gruppen wheel. |
| P19 | Varje root-kommando loggas med auid | fel | `sudo auditctl -l` | Root-kommandon från inloggade användare (auid 1000 eller högre) loggas. Root-kommandon från tjänster loggas inte. |

**Iakttagelse:** P10 och P17 fanns redan i min egen härdningslista, och AI:n förde dem vidare utan att ifrågasätta dem. Felen syntes först när jag kontrollerade varje påstående mot servern. Härdningslistan är rättad på rad 2 och rad 5.

## 5. Utelämningslista

| Det som inte matades in | Varför |
| --- | --- |
| Flaggor och kvitton från CTF-labbarna | Personliga och hemliga. Curl-testet redovisas bara med HTTP-koden 200. |
| IP-adresser i labbnätet och teamnätet | Inte publika adresser |
| Hela `zon.nft` | Innehåller interna adresser och hela regelverkets struktur |
| Certifikat och nycklar i /etc/pki/rsyslog | Nycklar ska aldrig matas in |
| Lösenord, även sudo-lösenordet | Ska aldrig matas in |
| `zonvakt.te` och `zonvakt.fc` | Behövdes inte för rapporten. Policyn verifierades med kommandon i stället. |
