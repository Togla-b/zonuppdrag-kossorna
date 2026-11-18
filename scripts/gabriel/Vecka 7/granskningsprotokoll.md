# Vecka 7 – Granskningsprotokoll

**Server:** elev-44  
**Ansvarig:** Gabriel  
**Underlag:** AI-utkast till härdningsrapport och verifierade resultat från labbservern.

## Granskning av AI:s påståenden

| Nr | Påstående (förkortat) | Bedömning | Verifiering |
|---|---|---|---|
| 1 | SELinux är aktiverat | Stämmer | `sestatus` → enabled |
| 2 | SELinux körs i Enforcing | Stämmer | `sestatus` → enforcing |
| 3 | Enforcing är konfigurerat för uppstart | Stämmer | `sestatus` → Mode from config file: enforcing |
| 4 | Policymodulen zonvakt är installerad | Stämmer | `sudo semodule -l \| grep zonvakt` |
| 5 | Zonvakt kör i domänen zonvakt_t | Stämmer | `ps -eZ \| grep zonvakt` |
| 6 | Egen domän möjliggör särskilda åtkomstbegränsningar | Stämmer | SELinux-domänen verifierad. Tidigare negativt test gav Permission denied. |
| 7 | /srv/zonwebb har typen httpd_sys_content_t | Stämmer | `ls -Zd /srv/zonwebb` |
| 8 | httpd_sys_content_t är avsedd för webbinnehåll | Stämmer | SELinux-typens normala användningsområde. |
| 9 | Etikettestet bevisar inte att Apache kan leverera sidan | Stämmer | `ls -Zd` visar etikett, inte HTTP-funktion. |
| 10 | Verifieringsskriptet finns | Stämmer | Skriptet kördes via sin sökväg. |
| 11 | Skriptet kontrollerar tre säkerhetsinställningar | Stämmer | Skriptets tre kontroller gav GÄLLER. |
| 12 | Alla kontroller godkändes med exitkod 0 | Stämmer | Verifieringsskriptets utdata. |

## Slutsats

Jag granskade AI-utkastets 12 numrerade påståenden mot kommandon och resultat från min egen server.

Alla 12 bedömdes som korrekta. Påstående 9 markerades först som ogrundat, men efter att ha granskat vad kommandot faktiskt visar ändrade jag bedömningen till stämmer.

Granskningen visar också vikten av att skilja mellan en korrekt SELinux-etikett och att en tjänst faktiskt fungerar. Ett kommando kan bekräfta en viss inställning utan att bevisa att hela tjänsten fungerar.
