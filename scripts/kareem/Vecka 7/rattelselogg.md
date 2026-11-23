Rättelselogg – Milstolpe 7

Namn: Kareem
Elevnummer: 06
Vecka: 7

Påst. nr	Påstående (kort)	Dom	Kommando som avgjorde	Faktiskt utfall	Feltyp	Ändrat till
P1	SELinux är i enforcing-läge.	Stämmer	getenforce	Enforcing	–	Behålls.
P2	Zonvakt kör i domänen zonvakt_t.	Stämmer	`ps -eZ	grep zonvakt`	Zonvakt kör i zonvakt_t.	–
P3	Zonvakt kan skriva otillåtna filer i /etc.	Fel	`echo overtrad	nc -w2 127.0.0.1 7506`	Permission denied	Förväxlat system
P4	Verifieringsskriptet fungerar efter omstart.	Stämmer	sudo /usr/local/bin/verifiera-hardning	Fem kontroller visade GÄLLER och slutkoden var 0.	–	Behålls.
P5	Brandväggens regler är verifierade.	Ogrundat	sudo nft list ruleset	Faktisk utdata har ännu inte dokumenterats.	Ogrundat	Brandväggens regler behöver kontrolleras och dokumenteras.
Sammanfattning

AI-utkastet granskades mot faktiska kommandon och testresultat från elevservern.

Ett felaktigt påstående rättades: Zonvakt kan inte genomföra det otillåtna skrivförsöket eftersom SELinux nekar det.

Ett påstående om brandväggen markerades som ogrundat eftersom den faktiska brandväggsutdatan ännu inte har dokumenterats.
