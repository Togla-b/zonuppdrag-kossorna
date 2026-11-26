# Zonmodell med tillitsregler

## IP-plan

Nätverket är indelat i separata zoner för att begränsa åtkomst mellan olika system och delar av verksamheten. IP-planen utgår från nätverket `10.40.0.0/16` och dimensioneras för 25 % tillväxt.

Vår adressplan: [Adressplan.md](Adressplan.md)

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
