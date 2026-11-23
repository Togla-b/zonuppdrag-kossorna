# Hardening – Algot

## 1. SELinux i Enforcing-läge

**Åtgärd:**
SELinux har aktiverats och konfigurerats för att köras i Enforcing-läge.

**Effekt:**
SELinux tillämpar säkerhetspolicyn och blockerar åtgärder som inte är tillåtna enligt policyn.

**Verifiering:**
Kontrollerat med följande kommandon:

- `getenforce` – visar Enforcing.
- `sestatus` – visar att både aktuellt läge och konfigurationen är Enforcing.

## 2. Zonvakt med egen SELinux-domän

**Åtgärd:**
Skapat och installerat en egen SELinux-policy för tjänsten zonvakt. Tjänsten körs i den egna domänen `zonvakt_t`.

**Effekt:**
Tjänsten får endast de behörigheter som behövs enligt den egna policyn. Det begränsar risken för att tjänsten kan utföra otillåtna åtgärder.

**Verifiering:**
Kontrollerat med följande kommandon:

- `systemctl status zonvakt` – visar att tjänsten är aktiv.
- `ps -eZ | grep zonvakt` – visar att processen kör i domänen `zonvakt_t`.
- `semodule -l | grep zonvakt` – kontrollerar att policyn är installerad.