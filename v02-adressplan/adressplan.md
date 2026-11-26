# Zonmodell och IP-adressplan – Team 5

## 1. Tilldelat nätverk

Vi har blivit tilldelade det privata nätverket **10.40.5.0/24** av läraren.

Nätverket är skapat i Hetzner och heter `itsx26-team-5`.

Vi har valt att dela upp nätverket i **6 säkerhetszoner** med hjälp av VLSM. Varje gruppmedlem ansvarar för en zon.

Vi använder IPv4. IPv6 är avstängt på labbservrarna.

## 2. IP-adressplan

| Zon | Antal servrar | Prefix | Nätverksadress | Reserverade adresser | Möjliga serveradresser | Broadcast |
| :--- | ---: | :--- | :--- | :--- | :--- | :--- |
| Administrationszon | 1 | /30 | 10.40.5.0 | .0, .1 (gateway), .3 | 10.40.5.2 | 10.40.5.3 |
| Loggzon | 1 | /30 | 10.40.5.4 | .4, .7 | 10.40.5.5–10.40.5.6 | 10.40.5.7 |
| CTF-zon | 1 | /30 | 10.40.5.8 | .8, .11 | 10.40.5.9–10.40.5.10 | 10.40.5.11 |
| Elevzon | 6 | /28 | 10.40.5.16 | .16, .31 | 10.40.5.17–10.40.5.30 | 10.40.5.31 |
| Driftzon | 1 (planerad) | /30 | 10.40.5.32 | .32, .35 | 10.40.5.33–10.40.5.34 | 10.40.5.35 |
| DMZ | 1 (planerad) | /30 | 10.40.5.36 | .36, .39 | 10.40.5.37–10.40.5.38 | 10.40.5.39 |

### Hetzners reserverade adresser

Hetzner använder **10.40.5.1 som gateway för hela nätverket**, inte en gateway per subnät.

Följande adresser kan inte tilldelas servrar:

- Nätverksadressen i varje subnät.
- Broadcastadressen i varje subnät.
- Gatewayadressen `10.40.5.1`.
- Eventuella ytterligare adresser som Hetzner reserverar.

De angivna serveradresserna är preliminära tills vi har kontrollerat att de är tillgängliga i Hetzner.

**Observera:** Vi behöver också kontrollera om Hetzner tillåter `/30` som subnätsstorlek innan vi skapar dessa subnät.

## 3. Tillgångar, klassificering och zonindelning

| Zon | Enheter/servrar | Antal | Känslighet | Driftkritikalitet | Ansvarig |
| :--- | :--- | ---: | :--- | :--- | :--- |
| Administrationszon | Jumpserver | 1 | Hög | Hög | Gabriel |
| Loggzon | Loggserver | 1 | Hög | Hög | Martin |
| CTF-zon | CTF-server | 1 | Hög | Medel | Algot |
| Elevzon | Elevservrar | 6 | Medel | Medel | Kareem |
| Driftzon | Övervakningsserver (planerad) | 1 | Hög | Hög | Andre |
| DMZ | Webbserver (planerad) | 1 | Medel | Medel | Rasmus |

### Motivering

**Administrationszon:** Jumpservern används för administration och åtkomst till andra servrar. Därför har den hög känslighet och driftkritikalitet.

**Loggzon:** Loggservern innehåller säkerhetsloggar som behövs för felsökning och incidenthantering.

**CTF-zon:** CTF-servern har hög känslighet eftersom den kan innehålla flaggor och känslig övningsinformation. Driftkritikaliteten bedöms som medel.

**Elevzon:** Innehåller gruppens 6 elevservrar som används för laborationer. Alla placeras i samma subnät.

**Driftzon:** En planerad övervakningsserver som ska användas för att kontrollera systemens status och upptäcka problem.

**DMZ:** En planerad webbserver som kan tillhandahålla webbtjänster utan att ha fri åtkomst till interna zoner.

## 4. Föreslagen IP-fördelning

| Enhet | Föreslagen IP-adress | Ansvarig |
| :--- | :--- | :--- |
| Hetzner gateway | 10.40.5.1 | Hetzner |
| Jumpserver | 10.40.5.2 | Gabriel |
| Loggserver | 10.40.5.5 | Martin |
| CTF-server | 10.40.5.9 | Algot |
| Elevserver 1 | 10.40.5.17 | Teamet |
| Elevserver 2 | 10.40.5.18 | Teamet |
| Elevserver 3 | 10.40.5.19 | Teamet |
| Elevserver 4 | 10.40.5.20 | Teamet |
| Elevserver 5 | 10.40.5.21 | Teamet |
| Elevserver 6 | 10.40.5.22 | Teamet |
| Övervakningsserver (planerad) | 10.40.5.33 | Andre |
| Webbserver (planerad) | 10.40.5.37 | Rasmus |

Adresserna ska verifieras innan de används med `moln koppla`.

## 5. Zonmodell och tillitsregler

Vi följer principen att endast nödvändig trafik ska tillåtas mellan zonerna.

| Källa | Mål | Protokoll/port | Beslut | Motivering |
| :--- | :--- | :--- | :--- | :--- |
| Administrationszon | Elevzon | TCP/22 (SSH) | Tillåt | Administration och inloggning på elevservrar. |
| Elevzon | Loggzon | Enligt konfigurerad syslog-tjänst | Tillåt | Skicka säkerhetsloggar till loggservern. |
| Elevzon | CTF-zon | Enligt övning | Tillåt vid behov | Genomföra CTF-övningar. |
| Driftzon | Övriga zoner | Endast övervakningsportar | Tillåt vid behov | Kontrollera servrarnas status. |
| Internet | DMZ | TCP/80 och TCP/443 | Tillåt vid behov | Tillhandahålla webbtrafik. |
| DMZ | Administrationszon | Alla portar | Neka | Skydda administrationszonen. |
| CTF-zon | Administrationszon | Alla portar | Neka | Begränsa åtkomst till Jumpservern. |

## 6. Säkerhetsprinciper

- **Minsta möjliga åtkomst:** Endast nödvändig trafik tillåts.
- **Blockera som standard:** Övrig trafik mellan zonerna nekas.
- **Segmentering:** Servrar delas upp i olika subnät.
- **Skyddad administration:** Administration sker via Jumpservern.
- **Central loggning:** Säkerhetsloggar skickas till Loggservern.
- **DMZ:** Webbservern isoleras från interna system.
- **Övervakning:** Driftzonen används för att kontrollera systemens status.

### Viktigt om Hetzner

Trafik i det privata nätverket passerar inte Hetzners molnbrandvägg.

Därför behöver vi använda **nftables på servrarna** för att filtrera trafiken.

Separata subnät ger inte automatiskt fullständig säkerhetsisolering.

## 7. Verifiering och uppföljning

Vi ska kontrollera att:

- Alla subnät ligger inom `10.40.5.0/24`.
- Inga subnät överlappar.
- Reserverade IP-adresser inte tilldelas servrar.
- Varje server får rätt privat IP-adress.
- SSH via Jumpservern fungerar.
- Servrarna kan kommunicera där det behövs.
- Otillåten trafik blockeras med nftables.

### Kommandon för kontroll

Kontrollera nätverket och subnäten:

```bash
moln status
```

Kontrollera serverns nätverkskort:

```bash
ip -br addr
```

Kontrollera routing:

```bash
ip route
```

Testa anslutningen till en annan server:

```bash
ping -c 2 <teamkamratens-IP>
```

Innan vi ändrar brandväggsregler ska vi säkerställa att SSH-åtkomsten fortsätter fungera.
