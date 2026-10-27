# Zonmodell och IP-adressplan

## 1. Tilldelat nätverk

Vi har blivit tilldelade nätverket **10.40.5.0/24** av läraren och får använda maximalt 8 subnät.

Vi har valt att dela upp nätverket i fyra zoner med hjälp av VLSM, utifrån antalet servrar och deras behov.

## 2. IP-adressplan

| Zon | Antal servrar | Prefix | Nätverksadress | Användbara IP-adresser | Broadcast |
| :--- | ---: | :--- | :--- | :--- | :--- |
| Jumpserver | 1 | /30 | 10.40.5.0 | 10.40.5.1–10.40.5.2 | 10.40.5.3 |
| Loggserver | 1 | /30 | 10.40.5.4 | 10.40.5.5–10.40.5.6 | 10.40.5.7 |
| CTF-server | 1 | /30 | 10.40.5.8 | 10.40.5.9–10.40.5.10 | 10.40.5.11 |
| Elevservrar | 6 | /28 | 10.40.5.16 | 10.40.5.17–10.40.5.30 | 10.40.5.31 |

**Motivering:** Vi har valt `/30` för zonerna med en server och `/28` för elevservrarna. Ett `/28` ger 14 användbara IP-adresser, vilket ger plats för våra 6 elevservrar, gateway och eventuella reserverade adresser.

Alla subnät ligger inom `10.40.5.0/24` och överlappar inte.

## 3. Tillgångar, klassificering och zonindelning

| Tillgång | Antal | Prefix | Känslighet | Driftkritikalitet | Föreslagen zon |
| :--- | ---: | :--- | :--- | :--- | :--- |
| Jumpserver | 1 | /30 | Hög | Hög | Administrationszon |
| Loggserver | 1 | /30 | Hög | Hög | Loggzon |
| CTF-server | 1 | /30 | Hög | Medel | CTF-zon |
| Elevservrar | 6 | /28 | Medel | Medel | Elevzon |

### Motivering

- **Jumpserver:** Hög känslighet och driftkritikalitet eftersom den används för att administrera andra servrar.
- **Loggserver:** Hög känslighet och driftkritikalitet eftersom den innehåller viktiga säkerhetsloggar.
- **CTF-server:** Hög känslighet eftersom den kan innehålla känsliga uppgifter, flaggor och säkerhetsövningar. Driftkritikaliteten bedöms som medel.
- **Elevservrar:** Medel känslighet och driftkritikalitet eftersom de används för laborationer.

## 4. Tillitsregler

Vi utgår från principen att endast nödvändig trafik mellan zonerna ska tillåtas.

| Källa | Mål | Protokoll/port | Beslut | Motivering |
| :--- | :--- | :--- | :--- | :--- |
| Jumpserver | Elevservrar | TCP/22 (SSH) | Tillåt | Elever ska kunna ansluta till sina labbservrar. |
| Elevservrar | Loggserver | TCP/6514 | Tillåt vid behov | Skicka säkerhetsloggar om tjänsten används. |
| Elevservrar | CTF-server | Enligt övning | Tillåt vid behov | Genomföra CTF-övningar. |
| CTF-server | Jumpserver | Alla portar | Neka | Skydda administrationszonen. |
| Elevservrar | Jumpserver | Nya anslutningar | Neka som standard | Begränsa obehörig åtkomst. |

Reglerna är förslag och behöver anpassas efter hur labbmiljön faktiskt fungerar.

## 5. Grundläggande säkerhetsprinciper

- **Minsta möjliga åtkomst:** Endast nödvändig kommunikation tillåts.
- **Blockera som standard:** Övrig trafik mellan zonerna nekas.
- **Segmentering:** Servrarna delas upp i separata subnät.
- **Skyddad administration:** SSH till elevservrarna sker via Jumpservern.
- **Central loggning:** Säkerhetsloggar kan samlas på Loggservern.
- **CTF-isolering:** CTF-servern ska inte ha obehörig åtkomst till andra zoner.

## 6. Verifiering

Vi ska kontrollera att:

- Alla subnät ligger inom `10.40.5.0/24`.
- Inga subnät överlappar.
- SSH via Jumpservern fungerar.
- Nödvändig kommunikation mellan zonerna fungerar.
- Otillåten trafik blockeras.

Separata subnät ger inte automatiskt säkerhetsisolering. För att genomföra zonmodellen behöver vi även rätt routing och brandväggsregler.

Innan vi inför IP-planen måste vi kontrollera molnleverantörens reserverade adresser och hur nätverket är konfigurerat.
