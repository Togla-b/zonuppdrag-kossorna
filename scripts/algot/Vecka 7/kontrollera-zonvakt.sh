
#!/bin/bash

echo "Kontrollerar zonvakt..."

# Kontrollera att tjänsten kör
if systemctl is-active --quiet zonvakt; then
    echo "[OK] Zonvakt är aktiv."
else
    echo "[FEL] Zonvakt kör inte."
    exit 1
fi

# Kontrollera att processen kör i rätt SELinux-domän
if ps -eZ | grep -E 'system_u:system_r:zonvakt_t:s0.*zonvakt' >/dev/null; then
    echo "[OK] Zonvakt kör i sin egen SELinux-domän (zonvakt_t)."
else
    echo "[FEL] Zonvakt kör inte i rätt SELinux-domän."
    exit 1
fi

echo "Kontrollen är klar."
