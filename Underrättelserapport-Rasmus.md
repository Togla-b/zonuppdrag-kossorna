### Underrättelserapport

## Teorin bakom problemet
Ett ganska stort fel har upptäcks, det handlar om hur internet litar på webbplatser.
Det handlar om hur HTTPS-certifikat fungerar

När man öppnar en webbplats med https kontrollerar webläsaren ett certifikat som bevisar att servern faktiskt är den som den utger sig för.
Webbläsare och operativsystem har en lista över betrodda CA:er.
CA:er använder ofta (intermediate certificates) Ett mellanliggande certifikat är signerat av en betrodd rot-CA
Dem kan signera certifikat för vilken webbplats som helst. 
Mellanliggande certifikat är så känsligt eftersom den som kontrollerar privata nyckel kan utfärda certifikat som webbläsaren litar på.

## eMudhra
Den indiska CA:n eMudhra hade åtta mellanliggande certifikat vars privata nycklar som skulle ha cirka 384 bits eftersom den skyddas med en stark nyckel för p-384
Det ger ungefär 2^384 möjliga nycklar. Som är omöjligt att gissa. Men i eMudhras fall var nycklarna bara 3-8 bitar långa. Någon som göra ett angrepp kan söka igenom dem kombinationerna på ett par sekunder.

Dem hittade felet kunde bevisa att dem hade fått kontroll över nyckelen genom att signera meddelandet "We have a problem here - Wayne" med en av nycklarna. 
Det betyder att nyckelen blivit kompromitted och att någon kan använda den metoden för att signera falska certifikat.

## Vilka effekter har detta
En angripare kan skapa falska certifikat för vilken webbplats som helst, till exempel bankens eller googles. Eftersom dem verkar vara en betrodd CA litar hemsidan på dem.
Med detta verktyget kan en angripare enkelt utföra en (MITM) attack. Angriparen står mellan trafiken och kan även lyssna på crypterad trafik eftersom dem liknar trovärdiga.
Det kräver fortfarande att angriparen måste ha tillgång till nätverkstrafiken för att kunna avlyssna eller styra. Mest riskabelt för den som anävnder VPN i vissa länder eftersom dem länderna har andra regler kring avlyssning.

## Vad som redan gjorts, vad som behöver göras
Olika webbläsare som chrome och firefox har blockerat alla åtta underliggande certifikat. Windows 10 och microsoft edge var ett undantag när artikelen publicerades.
Certificate Transperacy-loggar är publika register över alla utfärdade certifikat
De kan avslöja falska certifikat, men bara i efterhand och bara om någon övervakar dem.
Det svåra är allt som inte är en webbläsare: Linux-distributioner, IoT-enheter, Docker-containrar, gamla verktyg och program som har egna certifikatlistor, till exempel i Python. Alla måste uppdateras, och många kommer att göra det långsamt eller aldrig.

## Sammanfattning
Situationen jämförs med 2014 Hearthbleed, men menar att det här kan bli ännu svårare att städa upp.

Vad: Åttå mellanliggande certifikat från eMudhra med för svaga privata nycklar
Varför: Nycklarna kan återksapas och användas för att signera falska certifikat som litas på globalt
Påverkan: Främst MITM-attacker, särskilt mot VPN och i nätverk som angriparen kan kontrollera. Webbläsare påverkas mindre tack vare blockeringen.
Åtgärder: Blockering i webbläsare, uppdatering av trust stores och program. Granska egna systemet och tjänster som litar på dem certifikaten.