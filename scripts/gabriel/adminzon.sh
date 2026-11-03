#!/usr/bin/env bash
# Milstolpe 4 - Admin-zon, 10.40.5.2
# Endast läsning och anslutningstester; ändrar inte brandvägg eller nät.
set -u

ADMIN_IP="10.40.5.2"
LOGG_IP="10.40.5.5"
CTF_IP="10.40.5.10"  # Bekräftad av Algot; avviker från Test.md (.9)
DRIFT_IP="10.40.5.33"
WEBB_IP="10.40.5.37"
ELEV_IPS=(10.40.5.17 10.40.5.18 10.40.5.19 10.40.5.20 10.40.5.21 10.40.5.22)

OUT_DIR="${1:-./admin_testresultat}"
mkdir -p "$OUT_DIR" || exit 1
STAMP="$(date +%Y%m%d_%H%M%S)"
CSV="$OUT_DIR/admin_resultat_$STAMP.csv"
LOG="$OUT_DIR/admin_fullkorning_$STAMP.log"
: > "$LOG"
printf 'TestID;Regel;Källa;Mål;Test;Förväntat;Faktiskt;Status;Detalj\n' > "$CSV"

say() { printf '%s\n' "$*" | tee -a "$LOG"; }
clean() { local s="$1"; s=${s//$'\n'/ }; s=${s//;/,}; printf '%s' "$s"; }
record() {
  local id="$1" rule="$2" source="$3" dest="$4" test="$5" expected="$6" actual="$7" status="$8" detail="$9"
  printf '%s;%s;%s;%s;%s;%s;%s;%s;%s\n' "$(clean "$id")" "$(clean "$rule")" "$(clean "$source")" "$(clean "$dest")" "$(clean "$test")" "$(clean "$expected")" "$(clean "$actual")" "$(clean "$status")" "$(clean "$detail")" >> "$CSV"
  say "[$status] $id ($rule) $source -> $dest | förväntat: $expected | faktiskt: $actual | $detail"
}

ping_test() {
  local id="$1" ip="$2" result
  result=$(ping -n -c 2 -W 2 "$ip" 2>&1)
  if [[ $? -eq 0 ]]; then
    record "$id" F1 "$ADMIN_IP" "$ip" 'ICMP echo-request' 'Svar' 'Svar' 'GODKÄND' '2 pingförsök'
  else
    record "$id" F1 "$ADMIN_IP" "$ip" 'ICMP echo-request' 'Svar' 'Inget bekräftat svar' 'EJ GODKÄND' "$(printf '%s' "$result" | tail -n 1)"
  fi
}

# Testar TCP-handshake, inte SSH-autentisering eller att syslog levererats.
tcp_test() {
  local id="$1" rule="$2" ip="$3" port="$4" label="$5" result
  result=$(timeout 4 bash -c 'exec 3<>/dev/tcp/"$1"/"$2"' _ "$ip" "$port" 2>&1)
  if [[ $? -eq 0 ]]; then
    record "$id" "$rule" "$ADMIN_IP" "$ip:$port" "$label TCP-anslutning" 'TCP-anslutning möjlig' 'TCP-anslutning möjlig' 'GODKÄND' 'Bekräftar inte autentisering eller applikationsfunktion'
  else
    record "$id" "$rule" "$ADMIN_IP" "$ip:$port" "$label TCP-anslutning" 'TCP-anslutning möjlig' 'TCP-anslutning misslyckades' 'EJ GODKÄND' "$(printf '%s' "$result" | tail -n 1)"
  fi
}

say "Milstolpe 4 – Admin-zon: $(date -Is)"
say "Värd: $(hostname); förväntad Admin-IP: $ADMIN_IP"
say 'Kontrollera att testfallslistan redan är incheckad i Git före första körningen.'
say '--- Nät / interface ---'
{ ip -br addr; ip route get "$LOGG_IP"; ip route get "$CTF_IP"; } 2>&1 | tee -a "$LOG"
if ip -4 -o addr show dev eth2 | grep -Fq "$ADMIN_IP/"; then
  record NET-01 Nät "$ADMIN_IP" eth2 'Admin-IP på eth2' '10.40.5.2 på eth2' '10.40.5.2 på eth2' 'GODKÄND' 'Adresskontroll'
else
  record NET-01 Nät "$ADMIN_IP" eth2 'Admin-IP på eth2' '10.40.5.2 på eth2' 'Inte bekräftad' 'EJ GODKÄND' 'Kontrollera ip -br addr'
fi

say '--- F1: Utgående ping från Admin ---'
ping_test F1-LOGG "$LOGG_IP"
ping_test F1-CTF "$CTF_IP"
ping_test F1-DRIFT "$DRIFT_IP"
ping_test F1-WEBB "$WEBB_IP"
for i in "${!ELEV_IPS[@]}"; do ping_test "F1-ELEV-$((i+1))" "${ELEV_IPS[i]}"; done

say '--- F2: SSH-port till Elev ---'
for i in "${!ELEV_IPS[@]}"; do tcp_test "F2-ELEV-$((i+1))" F2 "${ELEV_IPS[i]}" 22 SSH; done

say '--- F3: SSH-port till övriga zoner ---'
tcp_test F3-LOGG F3 "$LOGG_IP" 22 SSH
tcp_test F3-CTF F3 "$CTF_IP" 22 SSH
tcp_test F3-DRIFT F3 "$DRIFT_IP" 22 SSH
tcp_test F3-WEBB F3 "$WEBB_IP" 22 SSH

say '--- F5: Syslog TCP/514 ---'
tcp_test F5-TCP F5 "$LOGG_IP" 514 SYSLOG
record F5-LEVERANS F5 "$ADMIN_IP" "$LOGG_IP" 'Syslog-meddelande mottaget' 'Logg mottagen' 'Ej testat' 'MANUELL' 'Bekräfta på loggservern; TCP-test räcker inte'

say '--- Regler, moln och omstart: kräver särskild verifiering ---'
if command -v nft >/dev/null 2>&1 && sudo -n nft list table inet zon >/dev/null 2>&1; then
  say 'Aktiva nftables-regler:'
  sudo -n nft list table inet zon 2>&1 | tee -a "$LOG"
  record NFT-01 F14 "$ADMIN_IP" 'inet zon' 'Visa aktiva regler' 'Regelverk kan läsas' 'Regelverk kunde läsas' 'GODKÄND' 'Granska F/D-regler mot flödestabellen manuellt'
else
  record NFT-01 F14 "$ADMIN_IP" 'inet zon' 'Visa aktiva regler' 'Regelverk kan läsas' 'Ej läsbart utan sudo eller nft' 'MANUELL' 'Kör sudo nft -a list table inet zon separat'
fi
record F1-IN F1 'Övriga teamservrar' "$ADMIN_IP" 'Ping till Admin' 'Svar' 'Ej testat från motpart' 'MANUELL' 'Kör ping från respektive server'
record F10-IN F10 "$WEBB_IP" "$ADMIN_IP" 'Ny TCP-anslutning mot Admin' 'Blockerad' 'Ej testat från Webb' 'MANUELL' 'Testa från Webb mot en överenskommen, ofarlig testport'
record F11-IN F11 "$CTF_IP" "$ADMIN_IP" 'Ny TCP-anslutning mot Admin' 'Blockerad' 'Ej testat från CTF' 'MANUELL' 'Testa från CTF mot en överenskommen, ofarlig testport'
record F9-PUB F9 Internet "$ADMIN_IP" 'Publik SSH och molnregel' 'Enligt dokumentets källbegränsning' 'Ej testat' 'MANUELL' 'Kontrollera molnbrandvägg, publikt interface och SSH från rätt källa'
record F13-UT F13 "$ADMIN_IP" Internet 'DNS, HTTP/S, NTP' 'Tillåtet enligt flödestabellen' 'Ej fullständigt testat' 'MANUELL' 'Kräver valda externa testmål och separata DNS/NTP-kontroller'
record F14-DROP F14 "$ADMIN_IP" 'Övrig trafik' 'Default deny och molnbrandvägg' 'Blockerad' 'Ej testat' 'MANUELL' 'Kontrollera policy drop och negativt test mot lämplig testport'
record BOOT-01 'Persistens' "$ADMIN_IP" 'Efter omstart' 'Regler kvar efter omstart' 'Oförändrade' 'Ej testat' 'MANUELL' 'Planera säker omstart med återställningsväg; kör sedan om skriptet'

say '--- Sammanfattning ---'
awk -F';' 'NR>1 {count[$8]++} END {printf "GODKÄND: %d | EJ GODKÄND: %d | MANUELL: %d\n", count["GODKÄND"], count["EJ GODKÄND"], count["MANUELL"]}' "$CSV" | tee -a "$LOG"
say "CSV: $CSV"
say "Full körning: $LOG"
say 'OBS: Misslyckad TCP-anslutning kan bero på att tjänsten inte lyssnar eller på en annan brandvägg, inte enbart Admin-reglerna.'
