**IPv6 är avstängt för säkerhetens skull i detta nätverk.**

# Nätverksplanering – 10.40.5.0/24

## 1. Antal enheter och 25 % tillväxt

| Grupp | Idag | Med 25 % tillväxt |
| :--- | ---: | ---: |
| Klienter | 49 | 62 |
| Gäst och besök | 11 | 14 |
| Servrar | 11 | 14 |
| Drift och administration | 4 | 5 |
| Databaser | 1 | 2 |
| Logg och övervakning | 4 | 5 |
| DMZ – webbservrar och publika tjänster | 4 | 5 |
| DMZ – e-post och externa tjänster | 4 | 5 |
| Cybersäkerhetsteam | 4 | 5 |
| Säkerhetsverktyg och analys | 4 | 5 |
| Incidenthantering och forensik | 4 | 5 |
| Backup och återställning | 4 | 5 |
| Nätverksutrustning och management | 4 | 5 |
| VPN och fjärråtkomst | 11 | 14 |
| IoT och skrivare | 11 | 14 |
| Test- och utvecklingsmiljö | 4 | 5 |
| Länknät mellan routrar | 3 × 2 | 3 × 2 |

*Tillväxten är avrundad uppåt till hela enheter. Länknäten har två användbara adresser vardera.*

## 2. VLSM – adressplanering

| # | Grupp | Behov | Prefix | Nätverksadress | Användbara adresser | Broadcast |
| ---: | :--- | ---: | :--- | :--- | :--- | :--- |
| 1 | Klienter | 62 | /26 | 10.40.5.0 | 10.40.5.1–10.40.5.62 | 10.40.5.63 |
| 2 | Gäst och besök | 14 | /28 | 10.40.5.64 | 10.40.5.65–10.40.5.78 | 10.40.5.79 |
| 3 | VPN och fjärråtkomst | 14 | /28 | 10.40.5.80 | 10.40.5.81–10.40.5.94 | 10.40.5.95 |
| 4 | IoT och skrivare | 14 | /28 | 10.40.5.96 | 10.40.5.97–10.40.5.110 | 10.40.5.111 |
| 5 | Servrar | 14 | /28 | 10.40.5.112 | 10.40.5.113–10.40.5.126 | 10.40.5.127 |
| 6 | Test- och utvecklingsmiljö | 5 | /29 | 10.40.5.128 | 10.40.5.129–10.40.5.134 | 10.40.5.135 |
| 7 | Cybersäkerhetsteam | 5 | /29 | 10.40.5.136 | 10.40.5.137–10.40.5.142 | 10.40.5.143 |
| 8 | DMZ – webbservrar | 5 | /29 | 10.40.5.144 | 10.40.5.145–10.40.5.150 | 10.40.5.151 |
| 9 | Nätverksutrustning och management | 5 | /29 | 10.40.5.152 | 10.40.5.153–10.40.5.158 | 10.40.5.159 |
| 10 | Drift och administration | 5 | /29 | 10.40.5.160 | 10.40.5.161–10.40.5.166 | 10.40.5.167 |
| 11 | Säkerhetsverktyg och analys | 5 | /29 | 10.40.5.168 | 10.40.5.169–10.40.5.174 | 10.40.5.175 |
| 12 | Incidenthantering och forensik | 5 | /29 | 10.40.5.176 | 10.40.5.177–10.40.5.182 | 10.40.5.183 |
| 13 | Backup och återställning | 5 | /29 | 10.40.5.184 | 10.40.5.185–10.40.5.190 | 10.40.5.191 |
| 14 | Databaser | 2 | /30 | 10.40.5.208 | 10.40.5.209–10.40.5.210 | 10.40.5.211 |
| 15 | DMZ – e-post | 5 | /29 | 10.40.5.192 | 10.40.5.193–10.40.5.198 | 10.40.5.199 |
| 16 | Logg och övervakning | 5 | /29 | 10.40.5.200 | 10.40.5.201–10.40.5.206 | 10.40.5.207 |
| 17 | Länknät 1 | 2 | /30 | 10.40.5.212 | 10.40.5.213–10.40.5.214 | 10.40.5.215 |
| 18 | Länknät 2 | 2 | /30 | 10.40.5.216 | 10.40.5.217–10.40.5.218 | 10.40.5.219 |
| 19 | Länknät 3 | 2 | /30 | 10.40.5.220 | 10.40.5.221–10.40.5.222 | 10.40.5.223 |

**Ledigt adressutrymme:** 10.40.5.224–10.40.5.255.

## 3. Tillgångar, klassificering och zonindelning

| Tillgång | Antal +25 % | Prefix | Känslighet | Driftkritikalitet | Föreslagen zon |
| :--- | ---: | :--- | :--- | :--- | :--- |
| Klienter | 62 | /26 | Medel | Medel | Klientzon |
| Gäst och besök | 14 | /28 | Låg | Låg | Gästzon |
| Servrar | 14 | /28 | Hög | Hög | Serverzon |
| Drift och administration | 5 | /29 | Hög | Hög | Driftzon |
| Databaser | 2 | /30 | Hög | Hög | Databaszon |
| Logg och övervakning | 5 | /29 | Hög | Hög | Övervakningszon |
| DMZ – webbservrar | 5 | /29 | Medel–hög | Hög | DMZ |
| DMZ – e-post | 5 | /29 | Hög | Hög | DMZ |
| Cybersäkerhetsteam | 5 | /29 | Hög | Hög | Säkerhetszon |
| Säkerhetsverktyg och analys | 5 | /29 | Hög | Hög | Säkerhetszon |
| Incidenthantering och forensik | 5 | /29 | Hög | Hög | Säkerhetszon |
| Backup och återställning | 5 | /29 | Hög | Hög | Backupzon |
| Nätverksutrustning och management | 5 | /29 | Hög | Hög | Driftzon |
| VPN och fjärråtkomst | 14 | /28 | Hög | Hög | VPN-zon |
| IoT och skrivare | 14 | /28 | Låg–medel | Medel | IoT-zon |
| Test- och utvecklingsmiljö | 5 | /29 | Medel | Låg–medel | Testzon |
| Länknät mellan routrar | 3 × 2 | 3 × /30 | Medel | Hög | Transitnät |

## 2. Motivering till zonindelning

Vi har delat in tillgångarna i olika säkerhetszoner utifrån deras funktion, känslighet och driftkritikalitet.

Syftet är att separera olika typer av nätverkstrafik och begränsa åtkomsten mellan zonerna för att minska säkerhetsriskerna.

Exempelvis placeras databaser i en separat zon eftersom de kan innehålla känslig information. Gästnätverket isoleras från interna servrar eftersom gäster inte ska ha tillgång till organisationens interna resurser.

DMZ används för publika tjänster som behöver kunna nås utifrån, samtidigt som åtkomsten till interna nätverket begränsas.

