# Härdningsrapport – elev-36 (Rocky Linux 9)

Martin · Team 5 · 2026-11-18

Rapporten bygger på ett AI-utkast som har granskats påstående för påstående. Varje påstående är numrerat och har en dom (stämmer, fel eller ogrundat) och ett belägg från servern. Påståenden som var fel eller ogrundade är rättade. Rättelserna finns i rattelselogg.md, och arbetssättet beskrivs i metodbilaga.md.

## Inledning

**P1.** elev-36 används som loggserver med hög känslighet.
*Dom: stämmer.* Belägg: zonmodellen, avsnitt 3 (Loggzon: hög känslighet, hög driftkritikalitet).

Rapporten beskriver fem härdningsåtgärder. För varje åtgärd anges motivering, effekt och hur effekten verifierades.

## Åtgärd 1 – SELinux i enforcing, nu och efter omstart

**Motivering.** Servern är loggserver med hög känslighet. Om en tjänst tas över och SELinux inte är enforcing finns inget som begränsar en process som kör som root.

**P2.** SELinux är aktiverat med policyn targeted och kör i tvingande läge.
*Dom: stämmer.* Belägg: `sestatus` → SELinux status: enabled, Loaded policy name: targeted, Current mode: enforcing.

**P3.** Läget står i konfigurationsfilen och gäller därför även efter omstart.
*Dom: stämmer.* Belägg: `sestatus` → Mode from config file: enforcing.

**P4.** verifiera-hardning gav GÄLLER även efter en omstart.
*Dom: stämmer.* Belägg: `ls -l --time-style='+%F %T' /usr/local/bin/verifiera-hardning` → 2026-11-18 08:38:26, och `uptime -s` → 2026-11-18 08:42:11. Skriptet fanns före omstarten och gav sju GÄLLER efteråt.

## Åtgärd 2 – zonvakt under egen policy (zonvakt_t), inte permissiv

**Motivering.** zonvakt kör som root och tar emot anslutningar från nätet.

**P10 (rättad).** När zonvakt_t var permissiv skrev zonvakt i /etc, eftersom policyn bara loggade och inte stoppade.
*Dom: ogrundat i utkastets form, rättad.* Utkastet påstod att zonvakt kunde skriva i /etc när den körde i unconfined_service_t, men det finns ingen sparad utdata från den fasen. Belägg för den rättade formen: `sudo grep OBS /var/log/zonvakt/zonvakt.log` → `2026-11-17T15:28:25 127.0.0.1 'overtrad' -> OBS: skrev till /etc/zonvakt-otillaten - policyn stoppade inte det`.

**P5.** Policymodulen zonvakt är laddad.
*Dom: stämmer.* Belägg: `sudo semodule -l | grep zonvakt` → `zonvakt`.

**P6.** zonvakt kör i den egna domänen zonvakt_t.
*Dom: stämmer.* Belägg: `ps -eZ | grep zonvakt` → `system_u:system_r:zonvakt_t:s0 1009 ? 00:00:00 zonvakt`.

**P7.** Domänen zonvakt_t är inte permissiv.
*Dom: stämmer.* Belägg: `sudo semanage permissive -l` → zonvakt_t finns inte med, bara de inbyggda typerna.

**P8.** Försök att skriva i /etc nekas.
*Dom: stämmer.* Belägg: `echo overtrad | nc -w2 127.0.0.1 7536` → `zonvakt elev-36 nekad: Permission denied`.

**P9.** Tjänsten fungerar som den ska.
*Dom: stämmer.* Belägg: `echo hej | nc -w2 127.0.0.1 7536` → `zonvakt elev-36 ok`.

**P21 (tillägg 2026-11-23, U7.6).** zonvakt får bara binda till sin egen port. Innan fick zonvakt_t binda till alla oreserverade portar, via `corenet_tcp_bind_generic_port`. Den regeln är nu bytt mot den egna porttypen zonvakt_port_t. Port 7536 har märkts med `semanage port -a -t zonvakt_port_t -p tcp 7536`, och policyn tillåter bara `allow zonvakt_t zonvakt_port_t:tcp_socket name_bind;`.
*Dom: stämmer.* Belägg: `sudo semanage port -l | grep zonvakt` → `zonvakt_port_t tcp 7536`. `echo hej | nc -w2 127.0.0.1 7536` → `zonvakt elev-36 ok`, alltså fungerar tjänsten fortfarande med den smalare regeln.

## Åtgärd 3 – Bestående filkontext för /srv/zonwebb (httpd_sys_content_t)

**Motivering.** httpd ska bara läsa webbinnehåll. Utan en bestående regel slutar sidan fungera vid nästa relabel, och då är det lätt att stänga av SELinux för att få det att fungera.

**P11.** /srv/zonwebb har typen httpd_sys_content_t.
*Dom: stämmer.* Belägg: `ls -Zd /srv/zonwebb` → `unconfined_u:object_r:httpd_sys_content_t:s0 /srv/zonwebb`.

**P12.** Regeln finns i den lokala policyn och överlever en relabel.
*Dom: stämmer.* Belägg: `sudo semanage fcontext -l -C | grep zonwebb` → `/srv/zonwebb(/.*)? all files system_u:object_r:httpd_sys_content_t:s0`.

**P13.** httpd serverar kvittot.
*Dom: stämmer.* Belägg: `curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1/zon/kvitto.txt` → `200`.

## Åtgärd 4 – Default deny i nftables, in och ut

**Motivering.** Utan default deny kan alla i labbnätet nå alla tjänster på servern, och servern kan skicka ut vad som helst. Bara flödena i flödestabellen ska vara öppna.

**P14.** Kedjan in har policy drop.
*Dom: stämmer.* Belägg: `sudo nft list chain inet zon in | head -3` → `type filter hook input priority filter; policy drop;`.

**P15.** Kedjan ut har policy drop.
*Dom: stämmer.* Belägg: `sudo nft list chain inet zon ut | head -3` → `type filter hook output priority filter; policy drop;`.

**P16 (rättad).** Nekad utgående trafik loggas som ZON-UT-DROP. Loggregeln ZON-IN-DROP finns i kedjan in, men ingen inkommande nekning har loggats sedan omstarten.
*Dom: delvis ogrundat i utkastets form, rättad.* Belägg: `timeout 3 bash -c 'exec 3<>/dev/tcp/1.1.1.1/85'` följt av `sudo journalctl -k -g ZON- --since "-5 min"` → `ZON-UT-DROP ... DST=1.1.1.1 ... DPT=85 ... SYN`. `sudo journalctl -k -g ZON-IN-DROP --since today` → `-- No entries --`.

## Åtgärd 5 – auditd loggar root-kommandon (nyckel root-cmd)

**P17 (rättad).** Student kan bli root med sudo, via gruppen wheel. Om fler läggs till i wheel kan även de bli root.
*Dom: fel i utkastets form, rättad.* Utkastet påstod att flera användare kan bli root. Belägg: `getent group wheel` → `wheel:x:10:student`.

**Motivering.** Utan auditregeln går det inte att se vem som körde ett kommando som root.

**P18.** Auditregeln root-cmd finns.
*Dom: stämmer.* Belägg: `sudo auditctl -l` → två regler med `-F euid=0 -F auid>=1000 -F auid!=-1 -F key=root-cmd`, för b64 och b32.

**P19 (rättad).** Varje root-kommando som körs av en inloggad användare (auid 1000 eller högre) loggas med auid. Root-kommandon från tjänster loggas inte.
*Dom: fel i utkastets form, rättad.* Utkastet påstod att varje root-kommando loggas. Belägg: `sudo auditctl -l` → villkoren `auid>=1000` och `auid!=-1`.

## Sammanfattning

**P20.** Verifieringsskriptet rapporterar GÄLLER på alla sju kontroller och avslutas med slutkod 0.
*Dom: stämmer.* Belägg: `sudo /usr/local/bin/verifiera-hardning; echo "slutkod $?"` → sju rader GÄLLER, slutkod 0.

Av 20 påståenden i AI-utkastet stämde 16. Två var fel (P17, P19) och två var ogrundade eller delvis ogrundade (P10, P16). Alla fyra är rättade ovan. P10 och P17 kom från min egen härdningslista, som också är rättad.

P21 kom inte från AI-utkastet. Jag lade till det efter U7.6, när zonvakt fick en egen porttyp.
