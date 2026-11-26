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
| 8 | httpd_sys_content_t är avsedd för webbinnehåll | Ogrundat i redovisat underlag | `ls -Zd /srv/zonwebb` visar att etiketten används, men bevisar inte dess avsedda användningsområde. Påståendet behöver stöd i SELinux-dokumentation. |
| 9 | Etikettestet bevisar inte att Apache kan leverera sidan | Stämmer | `ls -Zd` visar etikett, inte HTTP-funktion. |
| 10 | Verifieringsskriptet finns | Stämmer | Skriptet kördes via sin sökväg. |
| 11 | Skriptet kontrollerar tre säkerhetsinställningar | Stämmer | Skriptets tre kontroller gav GÄLLER. |
| 12 | Alla kontroller godkändes med exitkod 0 | Stämmer | Verifieringsskriptets utdata. |

## Slutsats
Jag granskade AI-utkastets 12 numrerade påståenden mot kommandon och resultat från min egen labbserver.

Vid granskningen upptäckte jag att påstående 8 saknade tillräckligt stöd i det redovisade underlaget. Kommandot `ls -Zd /srv/zonwebb` visade att katalogen hade SELinux-typen `httpd_sys_content_t`, men bevisade inte vad typen är avsedd att användas till.

Jag ändrade därför bedömningen av påstående 8 från **Stämmer** till **Ogrundat i redovisat underlag**.

Detta visar varför AI-genererade påståenden behöver granskas kritiskt. Ett kommando kan bekräfta en viss inställning utan att bevisa alla slutsatser som AI drar av resultatet.
