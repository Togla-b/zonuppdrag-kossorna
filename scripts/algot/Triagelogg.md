# Triagelogg – Workshop 2

## 1. Brute force mot SSH

**Observation:**

I SSH-loggarna på `elev-13` har vi sett upprepade misslyckade inloggningsförsök. Exempelvis förekommer `Invalid user` från IP-adressen `172.20.1.10`, med olika användarnamn. Vi har även testat att framkalla flera misslyckade SSH-inloggningar.

**Slutsats:**

Aktiviteten liknar ett försök till lösenordsgissning eller användning av ogiltiga användarkonton. Eftersom försöken även har framkallats som en del av labbtestet behöver vi skilja på testaktivitet och okänd aktivitet.

**Vad hände?**

Flera misslyckade SSH-inloggningar gjordes mot servern. Försöken omfattade användarnamn som inte fanns på systemet.

**Vad berördes?**

Servern `elev-13`, SSH-tjänsten och de användarkonton som inloggningsförsöken riktades mot. Vi behöver även söka efter samma käll-IP på andra servrar.

**Vad ska göras?**

Kontrollera om någon lyckad inloggning följde efter de misslyckade försöken. Undersök käll-IP och berörda användarnamn. Kontrollera även att SSH-loggarna faktiskt når Wazuh.

**Status:** Behöver undersökas.

**Motivering:**

Vi har sett SSH-händelser i systemets loggar, men tidigare tester visade att `authpriv`-loggarna inte vidarebefordrades till Wazuh. Det innebär att det ännu inte är bekräftat att detektionen fungerar som den ska.

---

## 2. Zonöverträdelse – blockerad trafik

**Observation:**

Brandväggsreglerna i nftables blockerar trafik som inte är tillåten enligt zonens regler. Loggar från brandväggen används för att identifiera blockerade anslutningsförsök.

**Slutsats:**

En blockerad anslutning kan vara ett tecken på att någon försöker nå en tjänst utanför den tillåtna zonen. Det kan också vara legitim trafik som blockeras av säkerhetsreglerna.

**Vad hände?**

Trafik försökte passera en brandväggsregel som inte tillät anslutningen.

**Vad berördes?**

Den berörda servern, käll-IP, destinations-IP och den port som anslutningsförsöket riktades mot. Övriga servrar behöver också kontrolleras.

**Vad ska göras?**

Undersök vilken trafik som blockerades och jämför med nätverkets tillåtna kommunikation. Kontrollera om anslutningsförsöket var förväntat eller misstänkt.

**Status:** Behöver kompletteras med verifierat larm.

**Motivering:**

Vi behöver ett faktiskt loggutdrag med käll-IP, destinations-IP och port innan vi kan avgöra om händelsen var legitim eller misstänkt.

---

## 3. Kommando som körs som root

**Observation:**

Auditd används för att registrera kommandon som körs med root-behörighet. Regeln använder `execve`, `euid=0` och nyckeln `root_commands`. Händelserna skickas vidare genom audisp-syslog.

**Slutsats:**

Kommandon som körs med root-behörighet kan innebära en säkerhetsrisk om de utförs av obehöriga eller utan godkänd anledning. Samtidigt är det normalt att administratörer använder root för systemadministration.

**Vad hände?**

Ett kommando kördes med root-behörighet och registrerades av auditd.

**Vad berördes?**

Servern `elev-13`, root-kontot och det kommando som registrerades. Vi behöver även kontrollera om motsvarande aktivitet förekom på andra servrar.

**Vad ska göras?**

Kontrollera vilket kommando som kördes, när det kördes och vilken process eller användare som startade det. Jämför med godkänd administrativ aktivitet.

**Status:** Behöver bedömas utifrån det enskilda kommandot.

**Motivering:**

Att ett kommando körs som root är inte automatiskt skadligt. Det måste bedömas utifrån kommandots innehåll och sammanhang.

---

## 4. Skapande av nya användarkonton

**Observation:**

Den planerade detektionen ska identifiera när ett nytt lokalt användarkonto skapas på en Linux-server. Vi behöver kontrollera om Wazuh tar emot och identifierar en sådan händelse.

**Slutsats:**

Skapande av ett nytt användarkonto kan vara legitim administration, men kan också användas av en angripare för att behålla åtkomst till en server.

**Vad hände?**

Ett nytt användarkonto skapas på Linux-servern. Händelsen ska registreras och utlösa en detektion.

**Vad berördes?**

Servern där kontot skapades, det nya användarkontot och användaren eller processen som skapade kontot. Även andra servrar ska kontrolleras.

**Vad ska göras?**

Kontrollera vem som skapade kontot och om det var en godkänd administrativ åtgärd. Vid okänd kontoaktivitet ska händelsen eskaleras till ansvarig säkerhetsanalytiker.

**Status:** Planerad – behöver testas.

**Motivering:**

Detektionen är vald som gruppens fjärde händelse, men vi har ännu inte verifierat ett faktiskt larm i Wazuh.
