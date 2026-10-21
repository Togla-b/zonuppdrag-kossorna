# Zonmodell med tillitsregler

## IP-plan

Nätverket är indelat i separata zoner för att begränsa åtkomst mellan olika system och delar av verksamheten. IP-planen utgår från nätverket `10.40.0.0/16` och dimensioneras för 25 % tillväxt.

| **#** | **Grupp** | **Behov** | **Prefix** | **Nätverksadress** | **Användbara adresser** | **Broadcast** |
|---:|---|---:|---:|---|---|---|
| 1 | Klienter | 169 | /24 | 10.40.0.0 | 10.40.0.1–10.40.0.254 | 10.40.0.255 |
| 2 | Gäst och besök | 44 | /26 | 10.40.1.0 | 10.40.1.1–10.40.1.62 | 10.40.1.63 |
| 3 | VPN och fjärråtkomst | 30 | /27 | 10.40.1.64 | 10.40.1.65–10.40.1.94 | 10.40.1.95 |
| 4 | IoT och skrivare | 23 | /27 | 10.40.1.96 | 10.40.1.97–10.40.1.126 | 10.40.1.127 |
| 5 | Servrar | 18 | /27 | 10.40.1.128 | 10.40.1.129–10.40.1.158 | 10.40.1.159 |
| 6 | Test- och utvecklingsmiljö | 19 | /27 | 10.40.1.160 | 10.40.1.161–10.40.1.190 | 10.40.1.191 |
| 7 | Cybersäkerhetsteam | 13 | /28 | 10.40.1.192 | 10.40.1.193–10.40.1.206 | 10.40.1.207 |
| 8 | DMZ – webbservrar | 10 | /28 | 10.40.1.208 | 10.40.1.209–10.40.1.222 | 10.40.1.223 |
| 9 | Nätverksutrustning och management | 13 | /28 | 10.40.1.224 | 10.40.1.225–10.40.1.238 | 10.40.1.239 |
| 10 | Drift och administration | 12 | /28 | 10.40.1.240 | 10.40.1.241–10.40.1.254 | 10.40.1.255 |
| 11 | Säkerhetsverktyg och analys | 9 | /28 | 10.40.2.0 | 10.40.2.1–10.40.2.14 | 10.40.2.15 |
| 12 | Incidenthantering och forensik | 8 | /28 | 10.40.2.16 | 10.40.2.17–10.40.2.30 | 10.40.2.31 |
| 13 | Backup och återställning | 7 | /28 | 10.40.2.32 | 10.40.2.33–10.40.2.46 | 10.40.2.47 |
| 14 | Databaser | 5 | /29 | 10.40.2.48 | 10.40.2.49–10.40.2.54 | 10.40.2.55 |
| 15 | DMZ – e-post | 8 | /28 | 10.40.2.64 | 10.40.2.65–10.40.2.78 | 10.40.2.79 |
| 16 | Logg och övervakning | 7 | /28 | 10.40.2.80 | 10.40.2.81–10.40.2.94 | 10.40.2.95 |
| 17 | Länknät 1 | 2 | /30 | 10.40.2.96 | 10.40.2.97–10.40.2.98 | 10.40.2.99 |
| 18 | Länknät 2 | 2 | /30 | 10.40.2.100 | 10.40.2.101–10.40.2.102 | 10.40.2.103 |
| 19 | Länknät 3 | 2 | /30 | 10.40.2.104 | 10.40.2.105–10.40.2.106 | 10.40.2.107 |

## Tillitsregler

Teamets flödestabell beskriver vilka anslutningar som tillåts mellan zonerna. Trafik som inte omfattas av en uttrycklig tillitsregel blockeras som standard.

| **Källa** | **Mål** | **Protokoll/port** | **Riktning** | **Motivering** |
|---|---|---|---|---|
| Klienter | DMZ – webbservrar | tcp/443 | Klienter → DMZ | Användarna behöver nå företagets webbportal via HTTPS. |
| DMZ – webbservrar | Servrar | tcp/8080 | DMZ → Servrar | Webbservern behöver kommunicera med applikationstjänsten. |
| Servrar | Databaser | tcp/5432 | Servrar → Databaser | Applikationer behöver läsa och skriva data i databasen. |
| Godkända system | Logg och övervakning | tcp/6514 | System → Logg | Säkerhetsrelevanta loggar skickas krypterat till den centrala loggservern. |
| Drift och administration | Servrar | tcp/22 | Drift → Servrar | Administratörer behöver kunna hantera Linux-servrar via SSH. |
| Godkända interna system | DNS-server | udp/53 | System → DNS | Systemen behöver kunna göra namnuppslag. |
| Gäst och besök | Internet | tcp/80, tcp/443 | Gäst → Internet | Gäster behöver kunna surfa utan åtkomst till interna zoner. |
| VPN och fjärråtkomst | Drift och administration | Enligt vald VPN-lösning | VPN → Drift | Behöriga fjärranvändare behöver kunna nå administrativa resurser. |
| Nätverksutrustning och management | Logg och övervakning | tcp/6514 | Management → Logg | Nätverksutrustning behöver skicka loggar till central övervakning. |
| Säkerhetsverktyg och analys | Godkända interna system | Enligt verktygets behov | Säkerhetsverktyg → System | Säkerhetsverktyg behöver kunna genomföra godkända kontroller och analyser. |
| Cybersäkerhetsteam | Säkerhetsverktyg och analys | Enligt verktygets behov | Säkerhetsteam → Verktyg | Teamet behöver kunna använda säkerhetsverktyg i sitt arbete. |
| Incidenthantering och forensik | Godkända system för undersökning | Enligt undersökningsbehov | Forensik → System | Behörig personal behöver kunna undersöka incidenter och samla in bevis. |
| Servrar | Backup och återställning | Enligt backup-lösningen | Servrar → Backup | System behöver kunna säkerhetskopieras och återställas. |
| Godkända system | DMZ – e-post | Enligt e-postlösningen | System → E-post | Godkända system behöver kunna skicka eller ta emot e-post. |
| Drift och administration | Nätverksutrustning och management | Enligt administrationslösningen | Drift → Management | Administratörer behöver kunna hantera nätverksutrustning. |
| Godkända klienter och system | IoT och skrivare | Enligt tjänstens behov | Klienter → IoT | Användare behöver kunna använda godkända skrivare och IoT-tjänster. |
| Test- och utvecklingsmiljö | Godkända testtjänster | Enligt testbehov | Test → Testtjänster | Utvecklare behöver kunna testa applikationer utan fri åtkomst till produktion. |

## Grundläggande säkerhetsprinciper

- **Minsta möjliga åtkomst:** Varje zon får bara kommunicera med de system och tjänster som behövs.
- **Blockera som standard:** All trafik mellan zoner blockeras om den inte uttryckligen tillåts.
- **Separering:** Gästnätverk, IoT, testmiljö och DMZ hålls åtskilda från känsliga interna system.
- **Skydd av databaser:** Endast godkända applikationer och administrativa system får den åtkomst som behövs.
- **Central loggning:** Loggar skickas till en separat loggzon och skyddas mot obehörig ändring.
- **Begränsad administration:** Administrativa anslutningar tillåts bara från godkända system och för behöriga användare.
- **Dokumentation:** Varje regel ska ha en tydlig motivering och granskas regelbundet.
- **Returtrafik:** En tillståndsbevarande brandvägg tillåter normalt svarstrafik för etablerade anslutningar. Separata regler för returtrafik behövs därför vanligtvis inte.

## Uppföljning

Flödestabellen ska stämma överens med reglerna som implementeras i brandväggar och på enskilda system. Innan reglerna aktiveras ska tjänster, portar och riktningar verifieras mot den faktiska miljön. Regler som inte längre behövs ska tas bort.
