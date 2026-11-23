# Rättelselogg – härdningsrapport elev-36

| Påst. nr | Påstående (kort) | Dom | Kommando som avgjorde | Faktiskt utfall | Feltyp | Ändrat till |
| --- | --- | --- | --- | --- | --- | --- |
| P1 | elev-36 är loggserver med hög känslighet | stämmer | Zonmodellen, avsnitt 3 | Loggzon: hög känslighet | – | – |
| P2 | SELinux aktiverat, targeted, tvingande läge | stämmer | `sestatus` | enabled, targeted, Current mode: enforcing | – | – |
| P3 | Läget står i config och gäller efter omstart | stämmer | `sestatus` | Mode from config file: enforcing | – | – |
| P4 | verifiera-hardning gav GÄLLER efter omstart | stämmer | `ls -l --time-style='+%F %T' /usr/local/bin/verifiera-hardning` och `uptime -s` | Skriptet 08:38:26, uppstart 08:42:11, alla GÄLLER efteråt | – | – |
| P5 | Modulen zonvakt är laddad | stämmer | `sudo semodule -l \| grep zonvakt` | `zonvakt` | – | – |
| P6 | zonvakt kör i zonvakt_t | stämmer | `ps -eZ \| grep zonvakt` | `system_u:system_r:zonvakt_t:s0 1009 ... zonvakt` | – | – |
| P7 | zonvakt_t är inte permissiv | stämmer | `sudo semanage permissive -l` | zonvakt_t finns inte med, bara inbyggda typer | – | – |
| P8 | Försök att skriva i /etc nekas | stämmer | `echo overtrad \| nc -w2 127.0.0.1 7536` | `zonvakt elev-36 nekad: Permission denied` | – | – |
| P9 | hej fungerar | stämmer | `echo hej \| nc -w2 127.0.0.1 7536` | `zonvakt elev-36 ok` | – | – |
| P10 | Utan egen policy (unconfined_service_t) kunde zonvakt skriva i /etc | ogrundat | `sudo grep OBS /var/log/zonvakt/zonvakt.log` | Enda OBS-raden är från 15:28:25, när zonvakt_t var permissiv | Ogrundat | När zonvakt_t var permissiv skrev zonvakt i /etc (OBS-rad 15:28:25), eftersom policyn bara loggade och inte stoppade. |
| P11 | /srv/zonwebb har typen httpd_sys_content_t | stämmer | `ls -Zd /srv/zonwebb` | `...httpd_sys_content_t:s0 /srv/zonwebb` | – | – |
| P12 | Regeln finns kvar och tål en relabel | stämmer | `sudo semanage fcontext -l -C \| grep zonwebb` | `/srv/zonwebb(/.*)? all files ...httpd_sys_content_t:s0` | – | – |
| P13 | curl gav kvittot | stämmer | `curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1/zon/kvitto.txt` | `200` | – | – |
| P14 | Kedjan in har policy drop | stämmer | `sudo nft list chain inet zon in \| head -3` | `type filter hook input priority filter; policy drop;` | – | – |
| P15 | Kedjan ut har policy drop | stämmer | `sudo nft list chain inet zon ut \| head -3` | `type filter hook output priority filter; policy drop;` | – | – |
| P16 | Nekad trafik loggas som ZON-IN-DROP och ZON-UT-DROP | delvis ogrundat | `sudo journalctl -k -g ZON- --since "-5 min"` och `sudo journalctl -k -g ZON-IN-DROP --since today` | ZON-UT-DROP loggades för DPT=85. Inga ZON-IN-DROP sedan omstarten. | Ogrundat (IN-delen) | Nekad utgående trafik loggas som ZON-UT-DROP (visat med DPT=85). Loggregeln ZON-IN-DROP finns i kedjan in, men ingen inkommande nekning har loggats sedan omstarten. |
| P17 | Flera användare kan bli root med sudo | fel | `getent group wheel` | `wheel:x:10:student`, bara en användare | Ogrundat | Student kan bli root med sudo, via gruppen wheel. Om fler läggs till i wheel kan även de bli root. |
| P18 | Auditregeln root-cmd finns | stämmer | `sudo auditctl -l` | Två regler med `key=root-cmd` (b64 och b32) | – | – |
| P19 | Varje root-kommando loggas med auid | fel | `sudo auditctl -l` | Villkoren `auid>=1000` och `auid!=-1` | Överdrift | Varje root-kommando som körs av en inloggad användare (auid 1000 eller högre) loggas med auid. Root-kommandon från tjänster loggas inte. |
| P20 | Alla sju kontroller GÄLLER, slutkod 0 | stämmer | `sudo /usr/local/bin/verifiera-hardning` | 7 × GÄLLER, slutkod 0 | – | – |

**Summering:** 20 påståenden. 16 stämmer, 2 är fel (P17, P19) och 2 är ogrundade eller delvis ogrundade (P10, P16). P10 och P17 kom från min egen härdningslista, så rad 2 och rad 5 i listan är också rättade.
