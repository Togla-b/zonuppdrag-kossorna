## Översikt: alla flöden

Totalt 14 flöden. F2, F4, F6, F7, F8, F10 och F11 kommer direkt från zonmodellen i avsnitt 5; övriga är härledda från säkerhetsprinciperna i avsnitt 6 eller behövs för att servrarna ska fungera.

| ID | Källa | Mål | Protokoll/port | Beslut | Var | Ursprung |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | Alla teamservrar | Alla teamservrar | ICMP echo-request | Tillåt | nft output (källa) + nft input (mål) | Befintlig regel |
| F2 | Jumpserver 10.40.5.2 | Elevservrar 10.40.5.17–.22 | TCP/22 | Tillåt | nft output Jump + nft input Elev | Zonmodell |
| F3 | Jumpserver 10.40.5.2 | Logg .5, CTF .9, Drift .33, Webb .37 | TCP/22 | Tillåt | nft output Jump + nft input på resp. server | Princip: Skyddad administration |
| F4 | Elevservrar .17–.22 | Loggserver 10.40.5.5 | UDP/514 och/eller TCP/514 (syslog) | Tillåt | nft output Elev + nft input Logg | Zonmodell |
| F5 | Jump .2, CTF .9, Drift .33, Webb .37 | Loggserver 10.40.5.5 | UDP/514 och/eller TCP/514 (syslog) | Tillåt | nft output resp. server + nft input Logg | Princip: Central loggning |
| F6 | Elevservrar .17–.22 | CTF-server 10.40.5.9 | Enligt övning (fylls i) | Tillåt vid behov | nft output Elev + nft input CTF | Zonmodell |
| F7 | Övervakning 10.40.5.33 | Alla övriga servrar | ICMP + övervakningsport (t.ex. TCP/9100, fylls i) | Tillåt vid behov | nft output Drift + nft input på resp. server | Zonmodell |
| F8 | Internet | Webbserver 10.40.5.37 (publik IP) | TCP/80, TCP/443 | Tillåt vid behov | Moln + nft input Webb | Zonmodell |
| F9 | Internet (helst bara skolans IP) | Jumpserver (publik IP) | TCP/22 | Tillåt | Moln + nft input Jump | Princip: Skyddad administration |
| F10 | DMZ 10.40.5.37 | Jumpserver 10.40.5.2 | Alla | Neka | nft output Webb + nft input Jump | Zonmodell |
| F11 | CTF 10.40.5.9 | Jumpserver 10.40.5.2 | Alla | Neka | nft output CTF + nft input Jump | Zonmodell |
| F12 | Internet | Alla servrar utom Jump och Webb | Alla | Neka | Moln | Princip: Minsta möjliga åtkomst |
| F13 | Alla servrar | Internet | UDP+TCP/53 (DNS), TCP/80+443 (apt), UDP/123 (NTP) | Tillåt | nft output på alla servrar | Behövs för uppdateringar |
| F14 | All övrig trafik | – | Alla | Neka | Policy drop i nft + standard-neka i Moln | Princip: Blockera som standard |

## Regler per person

Varje person lägger in sina rader utöver den gemensamma grunden. "Motpart" är källa för input-regler och mål för output-regler. Neka-regler (F10, F11) läggs **före** F1 så att de vinner.

### Gabriel – Jumpserver 10.40.5.2 (Administrationszon)

| Var | Motpart | Protokoll/port | Beslut | Flöde |
| --- | --- | --- | --- | --- |
| Moln | Internet (helst skolans IP) | TCP/22 | Tillåt | F9 |
| nft input (publikt kort) | Internet | TCP/22 | Tillåt | F9 |
| nft input | 10.40.5.37 (DMZ) | Alla | Neka | F10 |
| nft input | 10.40.5.9 (CTF) | Alla | Neka | F11 |
| nft input | Övriga teamservrar | ICMP echo-request | Tillåt | F1 |
| nft output | 10.40.5.17–.22 | TCP/22 | Tillåt | F2 |
| nft output | 10.40.5.5, .9, .33, .37 | TCP/22 | Tillåt | F3 |
| nft output | 10.40.5.5 | Syslog 514 | Tillåt | F5 |
| nft output | Teamservrar (ej .9, .37) | ICMP echo-request | Tillåt | F1 |
| nft output | Internet | DNS, HTTP/S, NTP | Tillåt | F13 |

### Martin – Loggserver 10.40.5.5 (Loggzon)

| Var | Motpart | Protokoll/port | Beslut | Flöde |
| --- | --- | --- | --- | --- |
| Moln | Internet | Alla | Neka | F12 |
| nft input | 10.40.5.2 | TCP/22 | Tillåt | F3 |
| nft input | 10.40.5.17–.22 | Syslog 514 | Tillåt | F4 |
| nft input | 10.40.5.2, .9, .33, .37 | Syslog 514 | Tillåt | F5 |
| nft input | 10.40.5.33 | ICMP + övervakningsport | Tillåt | F7 |
| nft input | Teamservrar | ICMP echo-request | Tillåt | F1 |
| nft output | Teamservrar | ICMP echo-request | Tillåt | F1 |
| nft output | Internet | DNS, HTTP/S, NTP | Tillåt | F13 |

### Algot – CTF-server 10.40.5.9 (CTF-zon)

| Var | Motpart | Protokoll/port | Beslut | Flöde |
| --- | --- | --- | --- | --- |
| Moln | Internet | Alla | Neka | F12 |
| nft input | 10.40.5.2 | TCP/22 | Tillåt | F3 |
| nft input | 10.40.5.17–.22 | Övningsportar (fylls i) | Tillåt vid behov | F6 |
| nft input | 10.40.5.33 | ICMP + övervakningsport | Tillåt | F7 |
| nft input | Teamservrar | ICMP echo-request | Tillåt | F1 |
| nft output | 10.40.5.2 | Alla nya anslutningar | Neka | F11 |
| nft output | 10.40.5.5 | Syslog 514 | Tillåt | F5 |
| nft output | Teamservrar (ej .2) | ICMP echo-request | Tillåt | F1 |
| nft output | Internet | DNS, HTTP/S, NTP | Tillåt | F13 |

### Kareem – Elevservrar 10.40.5.17–.22 (Elevzon, alla sex)

| Var | Motpart | Protokoll/port | Beslut | Flöde |
| --- | --- | --- | --- | --- |
| Moln | Internet | Alla | Neka | F12 |
| nft input | 10.40.5.2 | TCP/22 | Tillåt | F2 |
| nft input | 10.40.5.33 | ICMP + övervakningsport | Tillåt | F7 |
| nft input | Teamservrar | ICMP echo-request | Tillåt | F1 |
| nft output | 10.40.5.5 | Syslog 514 | Tillåt | F4 |
| nft output | 10.40.5.9 | Övningsportar (fylls i) | Tillåt vid behov | F6 |
| nft output | Teamservrar | ICMP echo-request | Tillåt | F1 |
| nft output | Internet | DNS, HTTP/S, NTP | Tillåt | F13 |

### Andre – Övervakningsserver 10.40.5.33 (Driftzon, planerad)

| Var | Motpart | Protokoll/port | Beslut | Flöde |
| --- | --- | --- | --- | --- |
| Moln | Internet | Alla | Neka | F12 |
| nft input | 10.40.5.2 | TCP/22 | Tillåt | F3 |
| nft input | Teamservrar | ICMP echo-request | Tillåt | F1 |
| nft output | Alla övriga servrar | ICMP + övervakningsport | Tillåt | F7 |
| nft output | 10.40.5.5 | Syslog 514 | Tillåt | F5 |
| nft output | Internet | DNS, HTTP/S, NTP | Tillåt | F13 |

### Rasmus – Webbserver 10.40.5.37 (DMZ, planerad)

| Var | Motpart | Protokoll/port | Beslut | Flöde |
| --- | --- | --- | --- | --- |
| Moln | Internet | TCP/80, TCP/443 | Tillåt | F8 |
| Moln | Internet | Övriga portar | Neka | F12 |
| nft input (publikt kort) | Internet | TCP/80, TCP/443 | Tillåt | F8 |
| nft input | 10.40.5.2 | TCP/22 | Tillåt | F3 |
| nft input | 10.40.5.33 | ICMP + övervakningsport | Tillåt | F7 |
| nft input | Teamservrar | ICMP echo-request | Tillåt | F1 |
| nft output | 10.40.5.2 | Alla nya anslutningar | Neka | F10 |
| nft output | 10.40.5.5 | Syslog 514 | Tillåt | F5 |
| nft output | Teamservrar (ej .2) | ICMP echo-request | Tillåt | F1 |
| nft output | Internet | DNS, HTTP/S, NTP | Tillåt | F13 |
