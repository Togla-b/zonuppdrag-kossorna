#!/usr/bin/env python3
"""Testa utgående trafik från driftservern. Ändrar inga brandväggsregler.

Testar ping till .2 och .37 samt ett blockerat SSH-försök till .2.
Checka in CSV-listan före körning. Fånga samtidigt trafiken med tcpdump
och kontrollera ZON-UT-DROP för SSH-försöket. Detta är inte ett komplett test
av inkommande regler, molnbrandvägg, DNS, NTP eller DHCP.
"""
import csv
from datetime import datetime, timezone
import errno
from pathlib import Path
import socket
import subprocess
import sys


KÄLLA = "10.40.5.33"
MAPP = Path(__file__).resolve().parent


def testa(rad):
    mål = rad["destination"]
    if rad["protokoll"] == "icmp":
        try:
            svar = subprocess.run(
                ["ping", "-n", "-I", KÄLLA, "-c", "1", "-W", "3", mål],
                capture_output=True, text=True, timeout=4,
            )
        except subprocess.TimeoutExpired:
            return "tyst", "Timeout; kontrollera paketfångsten"
        if svar.returncode == 0:
            return "oppen", "Echo reply mottaget"
        # Ett misslyckat ping kan också innehålla ett uttryckligt ICMP-fel.
        return "oklart", "Kontrollera PCAP för tyst drop eller ICMP-fel: " + (
            svar.stdout + svar.stderr
        ).strip().replace("\n", " | ")

    if rad["protokoll"] != "tcp":
        return "testfel", "Endast TCP och ICMP stöds"
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as anslutning:
            anslutning.settimeout(3)
            anslutning.bind((KÄLLA, 0))
            anslutning.connect((mål, int(rad["port"])))
        return "oppen", "TCP-handskakning klar"
    except (socket.timeout, TimeoutError):
        return "tyst", "Inget svar före timeout; kontrollera PCAP och brandväggslogg"
    except OSError as fel:
        if fel.errno == errno.ECONNREFUSED:
            return "avvisad", "Snabbt nej; kan vara filter eller saknad lyssnare"
        return "testfel", str(fel)


def main():
    with (MAPP / "driftzon_testfall.csv").open(encoding="utf-8-sig", newline="") as fil:
        fall = list(csv.DictReader(fil))
    if not fall or any(rad.get("kalla") != KÄLLA for rad in fall):
        raise SystemExit("Testlistan måste innehålla tester från " + KÄLLA)
    if sys.argv[1:] != ["--kör"]:
        for rad in fall:
            print(rad["id"], rad["destination"], rad["protokoll"], rad["port"], "förväntat:", rad["forvantat"])
        print("Ingen trafik skickad. Granska förutsättningarna i CSV och checka in den.")
        print("Kör sedan: python3 driftzon_test.py --kör")
        return
    # Förhindra körning från fel maskin. TCP och ping binds också till samma adress.
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as kontroll:
            kontroll.bind((KÄLLA, 0))
    except OSError:
        raise SystemExit("Kör på driftservern där adressen " + KÄLLA + " finns.")
    tid = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    resultat = MAPP / ("driftzon_resultat_" + tid + ".csv")
    with resultat.open("x", encoding="utf-8", newline="") as fil:
        kolumner = list(fall[0]) + ["tid_utc", "faktiskt", "bedömning", "detalj"]
        skriv = csv.DictWriter(fil, fieldnames=kolumner)
        skriv.writeheader()
        for rad in fall:
            try:
                utfall, detalj = testa(rad)
            except (OSError, ValueError) as fel:
                utfall, detalj = "testfel", str(fel)
            bedömning = ("ej_verifierat" if utfall in ("oklart", "testfel") else
                         "matchar_förväntat" if utfall == rad["forvantat"] else "avvikelse")
            skriv.writerow(dict(rad, tid_utc=datetime.now(timezone.utc).isoformat(),
                                faktiskt=utfall, bedömning=bedömning, detalj=detalj))
            fil.flush()
            print(rad["id"], utfall, bedömning, flush=True)
    print("Sparat:", resultat)
    print("Jämför med PCAP och loggar. En timeout bevisar inte ensam var trafiken stoppades.")


if __name__ == "__main__":
    main()
