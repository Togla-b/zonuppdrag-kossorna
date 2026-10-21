# Analys: PHP-sårbarheterna och eMudhra-incidenten
 
## 1. PHP (CVE-2026-109618 och CVE-2026-109619)
 
### Vad har hänt?
Säkerhetsföretaget watchTowr skriver om två rapporterade sårbarheter i PHP. Uppgifterna kommer från ett inlägg på sociala medier som påstår att PHP ska publicera ett säkerhetsmeddelande den 22 oktober 2026 kl. 18:00.
 
### Fakta
- Sårbarheterna beskrivs som RCE, alltså att en angripare skulle kunna köra egen kod på servern.
- Uppgifterna är obekräftade.
- Ingen exploatering har rapporterats.
- Det finns ingen CVSS-poäng och ingen patch.
### Hypoteser
- Om ryktet stämmer kan alla versioner från PHP 5 och uppåt vara drabbade, vilket vore allvarligt eftersom PHP används så brett.
- Äldre PHP-versioner som inte längre får uppdateringar kan bli utan patch.
- Artikeln verkar skriven i hast, bland annat listas PHP 6 som aldrig släpptes, så detaljerna kan vara felaktiga.
### Rekommenderade åtgärder
- Inventera vilka servrar som kör PHP och vilken version.
- Bevaka PHP:s officiella besked och förbered en snabb uppdatering.
- Installera patchen så snart den finns.
---
 
## 2. eMudhra
 
### Vad har hänt?
Certifikatutfärdaren eMudhra har fått de privata nycklarna till åtta mellanliggande CA-certifikat komprometterade. Incidenten publicerades den 20 oktober 2026.
 
### Fakta
- Nycklarna genererades felaktigt, så vem som helst kan räkna fram dem utifrån certifikaten.
- Incidenten är bevisad med meddelanden signerade med nycklarna.
- Firefox, Chrome, Apple och Microsoft har blockerat certifikaten, och eMudhra har återkallat dem.
- Webbläsare bedöms inte ha kunnat angripas.
### Hypoteser
- En angripare med nycklarna skulle kunna utge sig för att vara vilken webbplats som helst.
- Program utanför webbläsarna kan fortfarande lita på certifikaten tills de uppdateras.
- Det är okänt om någon har utnyttjat bristen sedan certifikaten skapades i april 2025.
### Rekommenderade åtgärder
- Uppdatera webbläsare och operativsystem.
- Uppdatera certifikatpaket på servrar och i programspråk, till exempel ca-certificates, Python certifi och PHP:s Composer ca-bundle.
---
 
## Källor
 
- watchTowr: <https://watchtowr.com/intelligence/php-cve-2026-109618-faq/>
- eMudhra Intermediate CA Compromise: <https://emudhra.we-have-a-problem.com/>