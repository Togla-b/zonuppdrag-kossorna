#!/bin/bash

fel=0

# Kontroll 1: SELinux ska vara Enforcing
if [ "$(getenforce)" = "Enforcing" ]; then
    echo "GÄLLER: SELinux är Enforcing"
else
    echo "GÄLLER INTE: SELinux är inte Enforcing"
    fel=1
fi

# Kontroll 2: Zonvakt ska köra i rätt SELinux-domän
if ps -eZ | grep -q 'zonvakt_t:.*zonvakt'; then
    echo "GÄLLER: Zonvakt kör i domänen zonvakt_t"
else
    echo "GÄLLER INTE: Zonvakt kör inte i domänen zonvakt_t"
    fel=1
fi

# Kontroll 3: Webbserverns SELinux-etikett
if ls -Zd /srv/zonwebb 2>/dev/null | grep -q 'httpd_sys_content_t'; then
    echo "GÄLLER: Webbservern har rätt SELinux-etikett"
else
    echo "GÄLLER INTE: Webbservern saknar rätt SELinux-etikett"
    fel=1
fi

exit "$fel"
