### Milstolpe 5 – Verifiering av central loggning (Admin-zon)

**Server:** elev-44  
**Zon:** Admin (10.40.5.2)  
**Central loggserver:** 172.20.1.58  
**Protokoll:** TCP/6514 med TLS  
**Datum:** 2026-11-09

| Test | Verifiering | Resultat | Status |
|---|---|---|---|
| Rsyslog | `systemctl is-active rsyslog` | Tjänsten är aktiv | ✓ Godkänd |
| Konfiguration | `rsyslogd -N1` | Inga syntaxfel | ✓ Godkänd |
| Autentiseringsloggar | `loggsök sshd` | SSH-händelser från elev-44 mottagna via TLS | ✓ Godkänd |
| Systemloggar | `loggsök M5-TLS-TEST-elev44` | Testlogg mottagen via TLS | ✓ Godkänd |
| Brandväggsloggar | `loggsök 'DPT=65001'` | Riktiga blockerade anslutningar mottagna via TLS | ✓ Godkänd |
| Krypterad överföring | Kontroll av `TLS` i `loggsök` | Loggar mottagna via TLS på central server | ✓ Godkänd |
| Klartextöverföring | `loggsök 'DPT=65001'` | Endast TLS för testhändelsen, ingen KLARTEXT | ✓ Godkänd |
| Säkerhetskopia | Backup av rsyslog-konfiguration | Säkerhetskopior skapade | ✓ Godkänd |
| Persistens | Verifiering efter serveromstart | Inte genomförd ännu | Ej testad |

**Kort slutsats:**

Admin-zonen skickar system-, autentiserings- och brandväggsloggar till den centrala loggservern via TLS. Vi har verifierat detta med testloggar och riktiga blockerade anslutningar. Den tidigare klartextöverföringen har inaktiverats och det senaste testet visade endast TLS.