| **Grupp** | **Idag** | **Med 25 % tillväxt** |
| --- | ---: | ---: |
| Klienter | 135 | 169 |
| Gäst och besök | 35 | 44 |
| Servrar | 14 | 18 |
| Drift och administration | 9 | 12 |
| Databaser | 4 | 5 |
| Logg och övervakning | 5 | 7 |
| DMZ – webbservrar och publika tjänster | 8 | 10 |
| DMZ – e-post och externa tjänster | 6 | 8 |
| Cybersäkerhetsteam | 10 | 13 |
| Säkerhetsverktyg och analys | 7 | 9 |
| Incidenthantering och forensik | 6 | 8 |
| Backup och återställning | 5 | 7 |
| Nätverksutrustning och management | 10 | 13 |
| VPN och fjärråtkomst | 24 | 30 |
| IoT och skrivare | 18 | 23 |
| Test- och utvecklingsmiljö | 15 | 19 |
| Länknät mellan routrar | 3 länknät  2 adresser | 3 länknät  2 adresser |

#	Grupp	Behov	Prefix	Nätverksadress	Användbara adresser	Broadcast
1	Klienter	169	/24	10.40.0.0	10.40.0.1–10.40.0.254	10.40.0.255
2	Gäst och besök	44	/26	10.40.1.0	10.40.1.1–10.40.1.62	10.40.1.63
3	VPN och fjärråtkomst	30	/27	10.40.1.64	10.40.1.65–10.40.1.94	10.40.1.95
4	IoT och skrivare	23	/27	10.40.1.96	10.40.1.97–10.40.1.126	10.40.1.127
5	Servrar	18	/27	10.40.1.128	10.40.1.129–10.40.1.158	10.40.1.159
6	Test- och utvecklingsmiljö	19	/27	10.40.1.160	10.40.1.161–10.40.1.190	10.40.1.191
7	Cybersäkerhetsteam	13	/28	10.40.1.192	10.40.1.193–10.40.1.206	10.40.1.207
8	DMZ – webbservrar	10	/28	10.40.1.208	10.40.1.209–10.40.1.222	10.40.1.223
9	Nätverksutrustning och management	13	/28	10.40.1.224	10.40.1.225–10.40.1.238	10.40.1.239
10	Drift och administration	12	/28	10.40.1.240	10.40.1.241–10.40.1.254	10.40.1.255
11	Säkerhetsverktyg och analys	9	/28	10.40.2.0	10.40.2.1–10.40.2.14	10.40.2.15
12	Incidenthantering och forensik	8	/28	10.40.2.16	10.40.2.17–10.40.2.30	10.40.2.31
13	Backup och återställning	7	/28	10.40.2.32	10.40.2.33–10.40.2.46	10.40.2.47
14	Databaser	5	/29	10.40.2.48	10.40.2.49–10.40.2.54	10.40.2.55
15	DMZ – e-post	8	/28	10.40.2.64	10.40.2.65–10.40.2.78	10.40.2.79
16	Logg och övervakning	7	/28	10.40.2.80	10.40.2.81–10.40.2.94	10.40.2.95
17	Länknät 1	2	/30	10.40.2.96	10.40.2.97–10.40.2.98	10.40.2.99
18	Länknät 2	2	/30	10.40.2.100	10.40.2.101–10.40.2.102	10.40.2.103
19	Länknät 3	2	/30	10.40.2.104	10.40.2.105–10.40.2.106	10.40.2.107