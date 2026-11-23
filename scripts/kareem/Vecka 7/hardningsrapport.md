Härdningsrapport – Milstolpe 7

Namn: Kareem
Elevnummer: 06
Vecka: 7
Zonvakt-port: 7506

1. Syfte

Syftet med härdningsarbetet var att förbättra säkerheten på Linux-servern genom att använda SELinux i enforcing-läge och begränsa tjänsten zonvakt med en egen SELinux-policy.

Arbetet omfattade även brandväggskontroller och ett verifieringsskript som kontrollerar säkerhetsinställningarna.

2. Genomförda åtgärder
2.1 SELinux i enforcing-läge

SELinux kontrollerades för att säkerställa att systemet använder enforcing-läge både nu och efter omstart.

Verifieringskommandon:

getenforce
sestatus
grep ^SELINUX= /etc/selinux/config

Resultatet från verifieringsskriptet var:

GÄLLER: SELinux är i enforcing-läge

GÄLLER: SELinux är enforcing efter omstart

2.2 Egen SELinux-policy för zonvakt

En egen SELinux-policy skapades för zonvakt med domänen zonvakt_t.

Verifieringskommandon:

ps -eZ | grep zonvakt
sudo semodule -l | grep zonvakt

Verifieringen visade att zonvakt kör i zonvakt_t och att SELinux-modulen är installerad.

2.3 Skydd mot otillåtna skrivningar

Zonvakt testades med både ett tillåtet och ett otillåtet kommando.

Tillåtet test:

echo hej | nc -w2 127.0.0.1 7506

Resultat:

zonvakt elev-06 ok

Otillåtet test:

echo overtrad | nc -w2 127.0.0.1 7506

Resultat:

zonvakt elev-06 nekad: Permission denied

Detta visar att det tillåtna kommandot fungerar och att det otillåtna försöket nekas.

2.4 Kontroll av permissiva domäner

Kommandot sudo semanage permissive -l kördes.

Resultatet visade att zonvakt_t inte fanns bland de permissiva domänerna.

2.5 Verifieringsskript

Ett verifieringsskript skapades på:

/usr/local/bin/verifiera-hardning

Skriptet kontrollerar:

SELinux i enforcing-läge.
SELinux enforcing efter omstart.
Att zonvakt är aktiverad vid uppstart.
Att SELinux-modulen zonvakt är installerad.
Att zonvakt kör i zonvakt_t.

Vid testet visade samtliga fem kontroller GÄLLER.

Slutkod: 0.

3. Kontroll efter omstart

Servern startades om med:

sudo systemctl reboot

Efter omstart anslöts jag till elevservern igen och körde verifieringsskriptet.

Alla fem kontroller visade GÄLLER och slutkoden var 0.

Det visar att de kontrollerade inställningarna fortfarande gällde efter omstart.

4. Brandvägg

Brandväggens regler ska kontrolleras med:

sudo nft list ruleset

Reglerna för den avsedda trafiken till zonvakts port 7506 behöver dokumenteras med faktisk utdata.

5. Slutsats

Härdningsarbetet visar att SELinux är i enforcing-läge och att zonvakt kör under den egna SELinux-domänen zonvakt_t.

Testerna visade att tillåtna kommandon fungerar och att otillåtna skrivförsök nekas.

Verifieringsskriptet fungerade även efter omstart och avslutades med slutkod 0.

Brandväggens konfiguration behöver också verifieras och dokumenteras för att hela uppgiften ska vara komplett.
