Metodbilaga – Milstolpe 7

Namn: Kareem
Elevnummer: 06
Vecka: 7

Underlag som matades in, med maskerade värden markerade

Följande information användes som underlag för AI-granskningen:

Härdningslistan för Milstolpe 7.
Resultatet från getenforce.
Resultatet från sestatus.
Resultatet från ps -eZ | grep zonvakt.
Resultatet från sudo semodule -l | grep zonvakt.
Resultatet från sudo semanage permissive -l.
Resultatet från verifieringsskriptet.
Testresultatet för hej och overtrad.

Elevnumret användes som identifierare i dokumentationen. Inga lösenord, nycklar, tokens eller hemliga uppgifter matades in.

Prompt, ordagrant

Skriv ett utkast till en härdningsrapport för Milstolpe 7 utifrån underlaget nedan. Beskriv varje åtgärd, dess förväntade effekt och hur den verifierades. Hitta inte på något som inte står i underlaget. Markera påståenden som saknar bevis. Rapporten ska innehålla SELinux i enforcing-läge, zonvakt under den egna SELinux-domänen zonvakt_t, skydd mot otillåtna skrivningar, verifieringsskript och kontroll efter omstart.

Råsvar, oredigerat

AI-utkastet till härdningsrapport användes som grund för den slutliga rapporten. Påståendena granskades därefter mot faktiska kommandon och resultat från elevservern.

Det slutliga rapportutkastet finns i hardningsrapport.md.

Rättelselogg, en rad per ändrat påstående

P3: Påståendet om att zonvakt kan skriva otillåtna filer i /etc rättades. Testet med echo overtrad | nc -w2 127.0.0.1 7506 visade Permission denied.

P5: Påståendet om att brandväggens regler var verifierade markerades som ogrundat eftersom faktisk utdata från brandväggen ännu inte hade dokumenterats.

Den fullständiga rättelseloggen finns i rattelselogg.md.

Utelämningslista: vad som medvetet inte matades in, och varför
Lösenord utelämnades för att skydda inloggningsuppgifter.
Privata nycklar och tokens utelämnades av säkerhetsskäl.
Färdig SELinux-policyfil matades inte in enligt instruktionerna.
Eventuella hemliga flaggor och privata adresser utelämnades för att skydda informationen.
