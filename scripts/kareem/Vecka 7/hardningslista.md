Härdningslista – Milstolpe 7

Namn: Kareem
Elevnummer: 06
Vecka: 7
Zonvakt-port: 7506

Härdningsåtgärder
1. SELinux i enforcing-läge
Åtgärd: SELinux ska vara i enforcing-läge både nu och efter omstart.
Motivering: Om SELinux inte är enforcing kan obehöriga processer utföra handlingar som säkerhetspolicyn annars skulle stoppa.
Förväntad effekt: SELinux blockerar otillåtna handlingar och fortsätter göra det efter omstart.
Verifiering: getenforce, sestatus och grep ^SELINUX= /etc/selinux/config.
Skript: Ja.
2. Egen SELinux-policy för zonvakt
Åtgärd: Zonvakt ska köras under en egen SELinux-policy med domänen zonvakt_t.
Motivering: Om zonvakt körs utan begränsningar kan tjänsten få onödigt stora behörigheter.
Förväntad effekt: Zonvakt får endast de behörigheter som behövs för tjänstens funktion.
Verifiering: ps -eZ | grep zonvakt och sudo semodule -l | grep zonvakt.
Skript: Ja.
3. Skydda systemets konfigurationsfiler
Åtgärd: Zonvakt ska inte kunna skriva otillåtna filer i /etc.
Motivering: Om tjänsten kan ändra systemets konfigurationsfiler kan systemets säkerhet och stabilitet påverkas.
Förväntad effekt: SELinux nekar försök att skriva till skyddade filer i /etc.
Verifiering: echo overtrad | nc -w2 127.0.0.1 7506 och kontroll av AVC-loggar.
Skript: Ja.
4. Brandvägg
Åtgärd: Brandväggen ska endast tillåta avsedd trafik till zonvakts port 7506.
Motivering: Öppen nätverkstrafik kan ge obehöriga möjlighet att ansluta till tjänsten.
Förväntad effekt: Endast tillåten trafik når zonvakt.
Verifiering: sudo nft list ruleset.
Skript: Nej.
5. Verifieringsskript
Åtgärd: Ett verifieringsskript ska kontrollera härdningsinställningarna.
Motivering: Utan automatiserad kontroll kan felaktiga säkerhetsinställningar förbli oupptäckta.
Förväntad effekt: Det blir enklare att kontrollera att säkerhetsinställningarna fortfarande gäller efter omstart.
Verifiering: sudo /usr/local/bin/verifiera-hardning och kontroll av slutkod.
Skript: Ja.
Sammanfattning

Målet med härdningen är att förbättra serverns säkerhet genom att använda SELinux i enforcing-läge, begränsa zonvakt med en egen SELinux-policy, skydda systemets konfigurationsfiler och kontrollera brandväggsreglerna.

Verifieringsskriptet ska kontrollera att säkerhetsinställningarna fortfarande gäller efter omstart utan att ändra serverns konfiguration.
