### Milstolpe 5 – Verifiering av central loggning (Admin)

**Server:** elev-44  
**Datum:** 2026-11-09  
**Loggserver:** 172.20.1.58  
**Överföring:** TCP/6514 med TLS

| Test | Kommando | Resultat | Status |
|---|---|---|---|
| Rsyslog aktiv | `sudo systemctl is-active rsyslog` | `active` | ✓ |
| Kontroll av konfiguration | `sudo rsyslogd -N1` | Inga syntaxfel | ✓ |
| Autentiseringsloggar | `loggsök sshd` | SSH-händelser från elev-44 mottagna via TLS | ✓ |
| Systemloggar | `logger -p daemon.info "M5-TLS-TEST-elev44"` | Testhändelse skapad | ✓ |
| Verifiera systemlogg | `loggsök M5-TLS-TEST-elev44` | Mottagen via TLS med rätt värdnamn och tidsstämpel | ✓ |
| Brandväggstest | `curl --connect-timeout 3 --max-time 5 http://10.40.5.5:65001` | Anslutningen blockerades | ✓ |
| Lokal brandväggslogg | `sudo journalctl -k --since "5 minutes ago" --no-pager` | `ZON-UT-DROP` registrerades | ✓ |
| Central brandväggslogg | `loggsök 'DPT=65001'` | Händelsen mottagen via TLS | ✓ |
| Kontroll av klartext | `loggsök 'DPT=65001'` | Inga KLARTEXT-rader för testet efter ändringen | ✓ |
| Loggning efter serveromstart | Ej genomfört | Återstår | Ej testad |

#### Slutsats

Vi har verifierat att Adminservern skickar system-, autentiserings- och brandväggsloggar till den centrala loggservern via TLS.

Vid brandväggstestet blockerades trafik till TCP-port 65001. Händelsen registrerades lokalt och kunde sedan hittas centralt med rätt värdnamn och tidsstämpel.

Efter att den gamla klartextöverföringen inaktiverades visade det nya testet endast TLS.