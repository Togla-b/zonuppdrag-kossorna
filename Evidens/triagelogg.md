### Triage – Root-kommandon (elev-44)

**Observation:** Den 11/11 kl. 11:50 registrerade auditd att användaren `student` körde `/usr/bin/touch` med root-behörighet på `elev-44`.

**Slutsats:** Händelsen var ett planerat test av vår root-detektion och bedöms som legitim aktivitet.

**Åtgärd:** Larmet avfärdas som testaktivitet. Ingen ytterligare incidentåtgärd behövs.

#### Sökning och verifiering

- **Verktyg:** Wazuh → Discover
- **Index:** `wazuh-archives-*`
- **Sökspråk:** Lucene
- **Tidsintervall:** 2026-11-11 kl. 11:45–11:55 (svensk tid)

**Sökning 1 – Endast elev-44:**

`location:*elev-44* AND full_log:*root_commands*`

Resultat: 5 träffar.

**Sökning 2 – Alla servrar:**

`full_log:*root_commands*`

Resultat: 5 träffar.

**Verifiering:** Loggen visade `comm="touch"`, `auid=1000`, `euid=0` och `success=yes`. Händelsen jämfördes med vårt tidigare testkommando `sudo /usr/bin/touch /tmp/root-monitor-test`.
