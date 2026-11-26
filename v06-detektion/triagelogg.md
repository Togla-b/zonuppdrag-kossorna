# Triagelogg – Milstolpe 6

**Team:** Kossorna  
**Verktyg:** Wazuh  
**Syfte:** Dokumentera observation, analys, slutsats och åtgärd för teamets fyra detektioner.

## 1. Brute force mot SSH

**Playbook:** Brute force mot SSH  
**Berörd server:** `elev-13`  
**Status:** Behöver undersökas vidare

**Observation:**  
I SSH-loggarna på `elev-13` har vi observerat upprepade misslyckade inloggningsförsök, bland annat `Invalid user` från IP-adressen `172.20.1.10`. Flera olika användarnamn förekommer. Vi har även genomfört tester med misslyckade inloggningar.

**Analys:**  
Händelserna kan tyda på lösenordsgissning eller försök att identifiera giltiga användarkonton. Vi behöver kontrollera antalet försök från samma IP, om någon lyckad inloggning följde och om andra servrar berördes.

**Slutsats:**  
Aktiviteten liknar ett brute force-försök, men det är ännu inte fastställt vilka händelser som tillhör godkända tester. Ett verifierat Wazuh-larm behöver dokumenteras.

**Åtgärd:**  
Undersök vidare och verifiera att SSH-loggarna når Wazuh. Eskalera om aktiviteten inte kan förklaras eller om en misstänkt lyckad inloggning upptäcks. Avfärda dokumenterade testhändelser.

**Verifiering som återstår:**  
- Datum och tidsstämpel för larmet.
- Antal misslyckade inloggningar och berörda användarnamn.
- Kontroll av lyckade inloggningar.
- Bekräftelse på att monitorn faktiskt utlöst ett larm.

---

## 2. Zonöverträdelse – blockerad trafik

**Playbook:** Zonöverträdelse  
**Berörd server:** `elev-36`  
**Monitor:** `Zonöverträdelse elev-36`  
**Status:** Testtrafik dokumenterad, larmtid behöver kompletteras

**Observation:**  
Brandväggen nftables har registrerat blockerad utgående trafik med loggprefixet `ZON-UT-DROP`. I dokumentationen finns testhändelser mot `1.1.1.1` på port 81 och 8080.

Under ett mätfönster på 24 timmar registrerades 6 träffar och under 168 timmar registrerades 20 träffar. Enligt dokumentationen var samtliga framkallade tester.

**Analys:**  
Den blockerade trafiken stämmer med den definierade detektionen. En sådan händelse kan bero på obehörig kommunikation eller felkonfiguration, men i detta fall är den dokumenterade trafiken kopplad till gruppens tester.

**Slutsats:**  
De dokumenterade testhändelserna bedöms som legitim testaktivitet. Det finns inget i underlaget som visar att dessa tester var skadliga.

**Åtgärd:**  
Avfärda de kända testhändelserna efter kontroll mot testplanen. Behåll brandväggens blockering. Eskalera framtida okända eller misstänkta zonöverträdelser enligt playbooken.

**Verifiering som återstår:**  
- Exakt tidpunkt för testhändelsen.
- Exakt tidpunkt för motsvarande Wazuh-larm.
- Bekräftelse på att larmet matchar den framkallade händelsen.

---

## 3. Kommando som körs som root

**Playbook:** Kommando som körs som root  
**Berörd server:** `elev-44` (Admin-zonen)  
**Monitor:** `root-commands-elev44-grupp`  
**Trigger:** `root-command-detected`  
**Status:** Larm verifierat, exakt händelsekoppling återstår

**Observation:**  
Den 11 november genomfördes ett planerat test där kommandot `sudo /usr/bin/touch /tmp/root-monitor-test` kördes på Adminservern.

Auditd registrerade root-aktivitet med nyckeln `root_commands`. Wazuh har även registrerat ett larm med allvarlighetsgrad 3 (Medium), som startade kl. 11:50 och avslutades kl. 11:56.

Vid en senare kontroll av loggarna hittades även processen `unix_chkpwd` kl. 11:49:46 svensk tid. Loggen visade `auid=1000`, `euid=0`, `success=yes` och `key="root_commands"`.

**Analys:**  
Detektionen identifierar kommandon och processer som körs med root-behörighet. Sådan aktivitet är inte automatiskt skadlig eftersom legitim systemadministration också kan utlösa larm.

Monitorn och dess trigger har kontrollerats i Wazuh. Larmet kl. 11:50 ligger tidsmässigt nära de registrerade händelserna, men vi har ännu inte fastställt exakt vilken logghändelse som utlöste det.

**Slutsats:**  
Det planerade `touch`-kommandot är legitim testaktivitet. Wazuh-monitorn har bekräftats kunna utlösa larm, men kopplingen mellan det specifika testkommandot och larmet behöver verifieras ytterligare.

**Åtgärd:**  
Dokumentera testaktiviteten. Ingen incidentåtgärd krävs för det godkända testet. Okända eller misstänkta root-kommandon ska undersökas och vid behov eskaleras.

**Verifiering som återstår:**  
- Kontrollera motsvarande `touch`-logg och dess tidsstämpel.
- Jämför logghändelsen med larmets tid.
- Dokumentera eventuellt negativt test.

---

## 4. Skapande av nya användarkonton

**Playbook:** Skapande av nya användarkonton  
**Berörd server:** Ej fastställd  
**Status:** Planerad – verifiering återstår

**Observation:**  
Gruppen har valt att övervaka händelser där nya lokala användarkonton skapas på Linux-servrar.

Enligt den befintliga dokumentationen återstår det att verifiera att Wazuh tar emot loggarna och att ett sådant konto faktiskt utlöser ett larm.

**Analys:**  
Skapandet av ett nytt användarkonto kan vara en godkänd administrativ åtgärd, men kan också vara ett tecken på obehörig åtkomst eller försök att behålla åtkomst.

För att avgöra detta behöver vi identifiera vem som skapade kontot, när det skapades och om det fick administratörs- eller sudo-behörighet.

**Slutsats:**  
Det finns ännu inte tillräckligt verifierat underlag i teamets dokumentation för att bedöma ett specifikt larm.

**Åtgärd:**  
Genomför ett godkänt test av kontoskapande och kontrollera motsvarande händelse i Wazuh. Dokumentera observationen och bedöm om kontot är legitimt. Eskalera om kontot är obehörigt eller har fått oväntade privilegier.

**Verifiering som återstår:**  
- Berörd server och kontonamn.
- Vem som skapade kontot.
- Datum och tidsstämpel.
- Loggutdrag från Wazuh.
- Bekräftelse på att monitorn utlöser ett larm.
- Slutlig bedömning av testhändelsen.

---

## Sammanfattning

| Detektion | Bedömning | Status |
|---|---|---|
| Brute force mot SSH | Misstänkt mönster, testaktivitet förekommer | Fortsatt undersökning |
| Zonöverträdelse | Dokumenterade tester är legitima | Komplettera larmverifiering |
| Root-kommandon | Planerat test är legitimt | Larm verifierat, exakt händelsekoppling återstår |
| Nya användarkonton | Ingen verifierad specifik händelse dokumenterad | Test återstår |

## Test av playbooks

Varje playbook ska genomföras av en annan gruppmedlem än den som skrev den.

| Playbook | Testad av | Datum | Resultat |
|---|---|---|---|
| Brute force mot SSH | Ej dokumenterat | – | Återstår att dokumentera |
| Zonöverträdelse | Ej dokumenterat | – | Återstår att dokumentera |
| Root-kommandon | Ej dokumenterat | – | Återstår att dokumentera |
| Nya användarkonton | Ej dokumenterat | – | Återstår att dokumentera |
