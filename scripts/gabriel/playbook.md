# Playbook – Root-kommandon (Admin-zonen)

**Monitor:** `root-commands-elev44-grupp`  
**Loggkälla:** auditd → rsyslog → Wazuh  
**Syfte:** Undersöka kommandon som körs med root-behörighet.

### 1. Förberedelse (Preparation)
- Kontrollera att monitorn är aktiv i Wazuh.
- Öppna Discover och välj `wazuh-archives-*`.
- Kontrollera att loggar från `elev-44` finns.

### 2. Upptäckt och analys (Detection & Analysis)
- Välj tidsintervallet kring larmet.
- Använd Lucene-filtret:

`location:*elev-44* AND full_log:*root_commands*`

- Kontrollera `comm`, `exe`, `auid`, `euid` och `success`.
- Ta bort värdfiltret och sök med `full_log:*root_commands*` för att undersöka övriga servrar.
- Jämför aktiviteten med godkända administrativa åtgärder.

### 3. Begränsning, åtgärd och återställning (Containment, Eradication & Recovery)
- Vid bekräftad testaktivitet: dokumentera och avfärda larmet.
- Vid okänd eller misstänkt aktivitet: eskalera till ansvarig säkerhetsanalytiker eller lärare med loggutdrag, tidpunkt, server, användare och kommando.
- Vid bekräftad incident: låt ansvarig besluta om begränsning och återställning.

### 4. Uppföljning (Post-Incident Activity)
- Dokumentera observation, slutsats och åtgärd i triageloggen.
- Notera eventuella falsklarm och förbättringar av detektionen.
- Kontrollera att monitorn fortsätter fungera.
