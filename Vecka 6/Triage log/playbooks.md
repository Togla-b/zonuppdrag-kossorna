### Playbooks – Workshop 2

#### Playbook 1 – Brute force mot SSHFas 1: Förberedelse
Öppna Wazuh och gå till Security Events.
Kontrollera att SSH- och autentiseringsloggar är tillgängliga.
Notera regel-ID, tidsstämpel och berörd server.

Fas 2: Upptäckt och analys
Sök efter misslyckade SSH-inloggningar under ett tidsfönster på 10 minuter.
Gruppera händelserna efter käll-IP.
Kontrollera hur många misslyckade försök som kommer från samma IP.
Undersök vilka användarnamn som har använts.
Sök efter lyckade inloggningar från samma IP under samma tidsperiod och 30 minuter efteråt.
Sök även efter samma käll-IP utan värdfilter för att kontrollera om fler servrar berörts.

Fas 3: Begränsning och återställning
Eskalera till ansvarig säkerhetsanalytiker om många misslyckade försök följs av en lyckad inloggning eller om aktiviteten inte kan förklaras.
Skicka med käll-IP, användarnamn, tidsstämplar, berörda servrar och loggutdrag.
Begränsa käll-IP eller kontot efter godkännande om aktiviteten bekräftas vara skadlig.
Avfärda larmet om det kan kopplas till ett dokumenterat och godkänt test.

Fas 4: Efterarbete
Dokumentera observation och slutsats i triageloggen.
Spara relevanta loggar.
Kontrollera om detektionen behöver justeras.

#### Playbook 2 – ZonöverträdelseFas 1: Förberedelse
Öppna Wazuh och kontrollera att brandväggsloggar tas emot.
Ha tillgång till serverns brandväggsregler.
Kontrollera vilka anslutningar som är tillåtna mellan zonerna.

Fas 2: Upptäckt och analys
Sök efter blockerade anslutningar under ett tidsfönster på 10 minuter.
Notera käll-IP, destinations-IP och destinationsport.
Kontrollera vilken brandväggsregel som blockerade trafiken.
Jämför anslutningen med nätverkets tillåtna kommunikation.
Gruppera händelserna efter käll-IP.
Sök efter samma käll-IP utan värdfilter för att se om fler servrar berörts.
Kontrollera om samma IP försökt nå flera portar eller servrar.

Fas 3: Begränsning och återställning
Eskalera till nätverksansvarig eller säkerhetsansvarig om trafiken verkar vara ett obehörigt åtkomstförsök.
Skicka med käll-IP, destinations-IP, port, tidsstämpel och brandväggsregel.
Behåll blockeringen medan händelsen undersöks.
Avfärda larmet om trafiken kan kopplas till ett dokumenterat och godkänt test.

Fas 4: Efterarbete
Dokumentera resultatet i triageloggen.
Spara relevanta brandväggsloggar.
Föreslå ändringar om legitima anslutningar återkommande blockeras.

#### Playbook 3 – Kommando som körs som rootFas 1: Förberedelse
Öppna Wazuh och kontrollera att auditd-loggar tas emot.
Kontrollera att auditd-regeln för root-kommandon är aktiv.
Ha tillgång till relevanta auditloggar.

Fas 2: Upptäckt och analys
Sök efter root-kommandon under ett tidsfönster på 10 minuter.
Notera vilket kommando som kördes och när det inträffade.
Kontrollera användare, process och berörd server.
Jämför kommandot med annan administrativ aktivitet under samma tidsperiod.
Sök efter samma typ av aktivitet utan värdfilter för att kontrollera om fler servrar berörts.
Kontrollera om kommandot följdes av andra ovanliga händelser.

Fas 3: Begränsning och återställning
Eskalera till systemansvarig eller säkerhetsansvarig om kommandot är okänt, misstänkt eller utförts av obehörig.
Skicka med kommando, användare, tidsstämpel, processinformation och berörd server.
Vid bekräftad skadlig aktivitet ska ansvarig besluta om begränsning och eventuell återställning.
Avfärda larmet om kommandot kan kopplas till en dokumenterad och godkänd administrativ uppgift.

Fas 4: Efterarbete
Dokumentera kommandot och bedömningen i triageloggen.
Spara relevanta auditloggar.
Kontrollera om detektionen behöver justeras för att minska onödiga larm.

#### Playbook 4 – Skapande av nya användarkontonFas 1: Förberedelse
Öppna Wazuh och kontrollera att system- och auditloggar tas emot.
Kontrollera att detektionen för skapande av användarkonton är aktiv.
Ha tillgång till information om godkända användarkonton och administratörer.

Fas 2: Upptäckt och analys
Sök efter händelser där nya användarkonton har skapats under ett tidsfönster på 30 minuter.
Notera vilket konto som skapades och när det inträffade.
Kontrollera vilken användare eller process som skapade kontot.
Kontrollera om det nya kontot har fått administratörs- eller sudo-behörighet.
Sök efter samma konto eller aktivitet utan värdfilter för att kontrollera om fler servrar berörts.
Jämför händelsen med godkända ändringar och administrativ aktivitet.

Fas 3: Begränsning och återställning
Eskalera till systemansvarig eller säkerhetsansvarig om kontot inte är godkänt eller om det har fått oväntade privilegier.
Skicka med kontonamn, skapande användare, tidsstämpel, berörd server och relevanta loggar.
Vid bekräftad obehörig aktivitet ska ansvarig besluta om kontot ska inaktiveras eller tas bort.
Avfärda larmet om kontot kan kopplas till en dokumenterad och godkänd kontoändring.

Fas 4: Efterarbete
Dokumentera händelsen och slutsatsen i triageloggen.
Spara relevanta loggar.
Kontrollera om detektionen fungerar som tänkt.
Föreslå förbättringar om legitima kontoändringar orsakar onödiga larm.
