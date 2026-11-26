# Milstolpe 5 – Centralloggning och spårbarhet

**Team:** Kossorna  
**Datum:** 2026-11-09  
**Central loggserver:** `172.20.1.58` (`log.sec.chas-lab.dev`)  
**Protokoll:** TCP/6514 med TLS

## 1. Loggkällekarta och urval

Följande loggkällor har kontrollerats på Adminservern `elev-44`.

| Loggkälla | Vad samlas in? | Säkerhetsfråga |
|---|---|---|
| Systemloggar | Systemhändelser och tjänstefel | Har något slutat fungera på servern? |
| Autentisering | SSH- och inloggningshändelser | Vem har loggat in och när? |
| Brandvägg | Blockerad trafik från nftables | Vilken trafik har blockerats och varför? |

**Urval och bortval:** Vi har valt att skicka relevanta system-, autentiserings- och brandväggsloggar centralt. Fullständigt paketinnehåll samlas inte in genom denna loggning. Cloud-init-loggar hanteras separat lokalt.

*Teamets övriga servrar och gemensamma bortval behöver kompletteras.*

## 2. Insamling via TLS

Adminservern `elev-44` skickar loggar till den centrala loggservern via TLS på TCP/6514.

Rsyslog använder `omfwd` för vidarebefordran och `gtls` med certifikatverifiering för krypterad överföring.

Den tidigare klartextöverföringen via TCP/514 har inaktiverats i rsyslog-konfigurationen.

## 3. Verifiering – Adminserver

| Test | Kommando | Resultat |
|---|---|---|
| Kontrollera tjänsten | `sudo systemctl is-active rsyslog` | `active` ✓ |
| Kontrollera syntax | `sudo rsyslogd -N1` | Inga syntaxfel ✓ |
| Autentisering | `loggsök sshd` | SSH-händelser mottagna via TLS ✓ |
| Skapa systemlogg | `logger -p daemon.info "M5-TLS-TEST-elev44"` | Testhändelse skapad ✓ |
| Sök systemlogg | `loggsök M5-TLS-TEST-elev44` | Mottagen via TLS ✓ |
| Skapa brandväggshändelse | `curl --connect-timeout 3 --max-time 5 http://10.40.5.5:65001` | Anslutning blockerad ✓ |
| Sök brandväggshändelse | `loggsök 'DPT=65001'` | Mottagen via TLS ✓ |
| Kontroll av klartext | `loggsök 'DPT=65001'` | Endast TLS för den nya testhändelsen ✓ |
| Omstart av rsyslog | `sudo systemctl restart rsyslog` | Tjänsten aktiv efter omstart ✓ |
| Omstart av server | Ej genomfört | Återstår |

Testhändelserna kunde hittas på den centrala loggservern med rätt värdnamn (`elev-44`) och tidsstämpel.

## 4. Skydd av loggkedjan

| Skyddsområde | Beskrivning |
|---|---|
| Kryptering | Loggar överförs via TLS |
| Certifikat | Mottagarens certifikat verifieras med CA och värdnamn |
| Åtkomst | Lokala loggfiler har systemstyrda behörigheter; exakt åtkomst behöver verifieras |
| Köhantering | Rsyslog har en LinkedList-kö med återförsök och sparning vid kontrollerad avstängning |
| Avbrott | Beteendet vid otillgänglig loggserver behöver testas |
| Lagringstid | Behöver kontrolleras med läraren eller serveransvarig |
| Ändring och radering | Behörigheter och skydd på central loggserver behöver bekräftas |

## 5. Återstående arbete

- Komplettera loggkällekartan för teamets övriga fem servrar.
- Verifiera TLS och spårbara testhändelser från samtliga servrar.
- Kontrollera loggning efter serveromstart när det kan göras säkert.
- Komplettera skyddsbeskrivningen med behörigheter, lagringstid och avbrottshantering.

## Slutsats

Adminserverns system-, autentiserings- och brandväggsloggar har verifierats på den centrala loggservern via TLS. Den tidigare klartextöverföringen har inaktiverats och ett nytt brandväggstest visade endast TLS.

Teamets gemensamma verifiering och vissa skyddskontroller återstår.