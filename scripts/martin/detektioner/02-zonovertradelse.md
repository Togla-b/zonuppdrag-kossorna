# Detektion 2 – Zonöverträdelse (utgående)

## Händelse
En post i paketfiltrets logg för utgående trafik som flödestabellen stoppar.
Servern ska aldrig försöka nå något som inte står i flödestabellen, så varje
sådan post kan tyda på felkonfiguration eller på att något på servern
försöker ringa ut.

## Nedbrytning

| Del | Innehåll |
|---|---|
| Loggkälla | nftables kärnlogg → rsyslog över TLS (6514) → loggservern → `wazuh-archives-*` |
| Fält | `data.action`, `location` |
| Värden | `data.action` = `ZON-UT-DROP`, `location` = `/var/log/remote/elev-36/syslog.log` |
| Gränsfall som inte ska träffa | Tillåten utgående trafik, t.ex. https på tcp/443 (D7). Den släpps igenom av nftables och loggas inte |

### Faktisk post

    ZON-UT-DROP IN= OUT=eth0 SRC=2.28.100.109 DST=1.1.1.1 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=6673 DF PROTO=TCP SPT=39372 DPT=8080 WINDOW=64240 RES=0x00 SYN URGP=0

## Monitor

| Inställning | Värde |
|---|---|
| Namn | Zonöverträdelse elev-36 |
| Typ | Per query monitor, visual editor |
| Schema | Var 1 minut |
| Index | `wazuh-archives-*` |
| Tidsfält | `timestamp` |
| Metrik | Count of documents |
| Tidsfönster | Senaste 5 minuterna |
| Datafilter | `data.action` is `ZON-UT-DROP`, `location` is `/var/log/remote/elev-36/syslog.log` |
| Trigger | IS ABOVE 0, severity 2 |

## Brusmätning

| Fönster | Längd | Träffar | Kommentar |
|---|---|---|---|
| Senaste dygnet | 24 h | 6 | Alla egna framkallade tester mot 1.1.1.1:8080 |
| Hela verifierade fönstret | 168 h | 20 | Ca 0,1 per timme. Alla framkallade tester mot 1.1.1.1 på port 81 och 8080 |

## Falsklarmsrisk
Låg. Under 168 timmar gav filtret 20 träffar, och alla var framkallade tester.
Utgående trafik som inte står i flödestabellen förekommer alltså inte i normal
drift, och därför larmar monitorn vid minst en träff. En ny tjänst som behöver
nå internet utan att ha lagts in i flödestabellen skulle ge larm. Det är då ett
tecken på att flödestabellen behöver uppdateras.

## Verifiering

| Händelse framkallad (UTC) | Larm (UTC) | Kommando |
|---|---|---|
| HH:MM | HH:MM | `timeout 3 bash -c 'exec 3<>/dev/tcp/1.1.1.1/8080'` |

## Lärdom
Monitorn gav först noll träffar, eftersom värdet i datafiltret var skrivet med
små bokstäver. Fältet är skiftlägeskänsligt. Felet hittades genom att ta bort
ett villkor i taget tills träffarna dök upp.