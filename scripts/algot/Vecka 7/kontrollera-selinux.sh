#!/bin/bash

echo "Kontrollerar SELinux..."

# Kontrollera aktuellt SELinux-läge
if [ "$(getenforce)" = "Enforcing" ]; then
    echo "[OK] SELinux kör i Enforcing."
else
    echo "[FEL] SELinux kör inte i Enforcing."
    exit 1
fi

# Kontrollera konfigurationen inför omstart
if grep -Eq '^[[:space:]]*SELINUX=enforcing([[:space:]]|$)' /etc/selinux/config; then
    echo "[OK] SELinux är konfigurerat för Enforcing efter omstart."
else
    echo "[FEL] SELinux är inte konfigurerat för Enforcing."
    exit 1
fi

echo "Kontrollen är klar."
