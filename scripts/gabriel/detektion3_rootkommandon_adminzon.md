
## Händelse 3 – Kommando som körs som root (Admin-zonen)

### 1. Händelse och syfte
Syftet är att upptäcka när ett kommando körs med root-behörighet på Admin-zonens server (elev-44). Detektionen bygger på auditd-regeln från vecka 5.

### 2. Loggkälla
- Källa: auditd
- Loggkedja: auditd → audisp-syslog → rsyslog → Wazuh
- Server: elev-44 (Admin-zonen)
- Index: `wazuh-archives-*`

### 3. Fält och faktiska värden

En riktig logghändelse från 2026-11-11 kl. 10:10 UTC innehöll:

| Fält | Värde | Betydelse |
|---|---|---|
| type | SYSCALL | Registrerat systemanrop |
| SYSCALL | execve | Programstart |
| auid | 1000 (student) | Ursprunglig användare |
| uid | 0 (root) | Processens användar-ID |
| euid | 0 (root) | Effektiv root-behörighet |
| comm | journalctl | Programnamn |
| exe | /usr/bin/journalctl | Programmets sökväg |
| key | root_commands | Matchad auditd-regel |
| success | yes | Systemanropet lyckades |

### 4. Detektion i Wazuh

**Monitor:** `root-commands-elev44-grupp`

**Trigger:** `root-command-detected`

Inställningar:
- Monitor type: Per query monitor
- Index: `wazuh-archives-*`
- Schedule: Varje minut
- Query time range: Senaste 5 minuterna
- Metric: COUNT OF documents
- Filter 1: `location contains elev-44`
- Filter 2: `full_log contains root_commands`
- Trigger condition: IS ABOVE 0
- Severity: 3 (Medium)

Detektionen larmar om minst en matchande loggpost hittas under fem minuter.

### 5. Träffmängd och mätfönster

- Mätning: 2026-11-11
- Tidsfönster: Last 1 hour (1 timme)
- Antal träffar: 18
- Genomsnitt: 18 träffar per timme i det uppmätta fönstret

Mätningen innehåller administrativ aktivitet och är inte verifierad som en separat ostörd normaltrafikperiod.

Det fem minuter långa detektionsfönstret är skilt från mätfönstret på en timme.

### 6. Verifiering

Testkommando på elev-44:

```bash
sudo /usr/bin/touch /tmp/root-monitor-test
```

Kommandot kördes med root-behörighet för att skapa en ofarlig testhändelse.

**Resultat:**
- Monitorn skapades och sparades.
- Wazuh visade röd markering (Triggered).
- Ett aktivt larm för `root-command-detected` syntes kl. 11:50 den 11 november 2026.

Larmet har verifierats i Wazuh. Den exakta testhändelsens tidsstämpel har ännu inte jämförts mot larmet.

### 7. Gränsfall – ska inte träffa

Ett vanligt kommando som körs utan root-behörighet och inte matchar auditd-regeln `root_commands` ska inte ge träff i denna detektion.

Detta negativa test har ännu inte genomförts separat.

### 8. Falsklarmrisk

Legitima administrativa root-kommandon, exempelvis `sudo journalctl` och `sudo cat`, kan utlösa larm. Ett larm betyder därför inte automatiskt att ett angrepp pågår.

För att bedöma händelsen behöver vi kontrollera användare, kommando, tidpunkt och sammanhang.

### 9. Avgränsning

Monitorn filtrerar på `elev-44` och övervakar därför endast Admin-zonens server, inte de andra gruppmedlemmarnas servrar.

Detektionen kan utökas till andra servrar när deras auditd-loggar och fält har verifierats.

### 10. Kvar att komplettera

- Genomföra och dokumentera ett negativt test.
- Mäta en separat normaltrafikperiod och ange längd i timmar.
- Jämföra testhändelsens tidsstämpel med larmets tid.
- Bifoga skärmbild från Wazuh som visar det aktiva larmet.
