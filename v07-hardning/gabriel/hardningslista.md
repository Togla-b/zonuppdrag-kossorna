# Vecka 7 – Härdningslista

**Server:** elev-44  
**Ansvarig:** Gabriel  
**Zon:** Admin

## Genomförda härdningsåtgärder

| Åtgärd | Syfte och effekt | Verifiering | Resultat |
|---|---|---|---|
| SELinux Enforcing | Jag använder SELinux i tvingande läge för att blockera otillåtna åtgärder. | `getenforce` | Enforcing |
| Egen SELinux-policy för zonvakt | Jag skapade en egen policy som begränsar vad zonvakt får göra. | `ps -eZ \| grep zonvakt` och test med `echo overtrad` | Zonvakt kör i `zonvakt_t` och otillåten skrivning blockeras. |
| SELinux-etikett för webbservern | Jag satte rätt etikett så att Apache kan läsa webbfilerna. | `ls -Zd /srv/zonwebb` | `httpd_sys_content_t` |
| Verifieringsskript | Jag skapade ett skript som kontrollerar att säkerhetsinställningarna fortfarande gäller efter omstart. | `/usr/local/bin/verifiera-hardning` | Tre `GÄLLER` och exitkod 0 efter omstart. |

## Kort sammanfattning

Jag har härdat min server med SELinux och skapat en egen policy för zonvakt. Jag har även kontrollerat webbserverns SELinux-etikett och skapat ett verifieringsskript som kontrollerar säkerhetsinställningarna. Efter omstart fungerade alla tre kontrollerna.
