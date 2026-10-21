Enkel analys: PHP-sårbarheterna och eMudhra-incidenten
1. PHP (CVE-2026-109618 och CVE-2026-109619)

Säkerhetsföretaget watchTowr skriver om två rapporterade sårbarheter i PHP som skulle kunna låta en angripare köra egen kod på en server och ta kontroll över den. Enligt uppgifterna berörs alla versioner från PHP 5 och uppåt. Allt bygger dock på ett obekräftat inlägg på sociala medier. Ingen exploatering har rapporterats, det finns ingen CVSS-poäng och ingen patch. Artikeln innehåller också fel, till exempel listas PHP 6 som aldrig släpptes. PHP:s officiella besked väntas torsdag 22 oktober kl. 18:00.

Bedömning: Ett obekräftat rykte. Man bör inventera sina PHP-system och vänta på det officiella beskedet, men det finns ingen anledning till panik.

2. eMudhra

Certifikatutfärdaren eMudhra har fått de privata nycklarna till åtta mellanliggande CA-certifikat komprometterade, eftersom nycklarna genererats felaktigt. Med en sådan nyckel kan en angripare utge sig för att vara vilken webbplats som helst. Incidenten är bevisad med signerade meddelanden, och Firefox, Chrome, Apple och Microsoft har redan blockerat certifikaten. Webbläsare bedöms vara skyddade, men andra program som inte kontrollerar certifikat lika noga kan fortfarande vara sårbara.

Bedömning: En bekräftad och allvarlig incident, men redan till stor del åtgärdad. Användare bör uppdatera webbläsare och operativsystem.

Jämförelse

Händelserna är inte relaterade, men de visar skillnaden mellan rykte och fakta. PHP-fallet saknar bevis och åtgärder, medan eMudhra-fallet är bekräftat med tekniska bevis och har färdiga patchar. Den enda kopplingen är att PHP:s pakethanterare Composer har ett certifikatpaket (ca-bundle) som behöver uppdateras på grund av eMudhra-incidenten.

Källor
watchTowr: https://watchtowr.com/intelligence/php-cve-2026-109618-faq/
eMudhra Intermediate CA Compromise: https://emudhra.we-have-a-problem.com/