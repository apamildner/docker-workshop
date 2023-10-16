# Docker workshop + shell scripting
Pre-requisites: `Docker`

Testa att køra `docker --version`


## Workshop
Det som vi vill gøra ær føljande. Vi vill køra denna linjen
i en maskin, før att få tillbaka resultaten om bysykklarnas status. Vi gidder ikke installera noe dependencies och vi har kun Docker some dependency:
```bash
❯ bysykkel
...
😊 LANGKAIA:
------------------------
 Sykkler: 5, Plasser: 6


😎 BANKPLASSEN:
------------------------
 Sykkler: 0, Plasser: 38


🤓 BEKK EAST:
------------------------
 Sykkler: 0, Plasser: 12


😜 BEKK WEST:
------------------------
 Sykkler: 3, Plasser: 27
```
Detta ær det undeliggande kommandot, som har noe dependencies:
```bash
curl -s https://gbfs.urbansharing.com/oslobysykkel.no/station_status.json | jq '[.data.stations[] | {station_id, num_bikes_available, num_docks_available}]' | python main.py
```
Tenk ikke før mye på argumenterna til JQ akkurat nå, bara vet att det ær ett sorts "SQL før JSON" som kan extrahera delar av en JSON struktur gitt en spørring.
Detta ær lite artificiellt "vanskligt" (hade kunnat bruka kun python till allt) men touchar några viktiga koncepter.

ℹ️ Snacka med din gruppmedlem - hva ær det som skjer her? Hva betyr '|' symbolen? Hvar gør "curl" kommandoen?

Dere kan sannsynligvis ikke køra denna kommandoen på maskinen, och du kan i hvert fall ikke vara sikker på
att den kan køras av alla dina vænner i kantinen på Skuret som du vill dele denne med. Det ær på
tide att vi packar in hela greia i Docker!

# Dokka må ju bruke Dokka (Docker)
Vi kanske varken har curl/jq eller python på maskinen. Detta går ju ikke! Nå kan vi laga en docker image som faktiskt kan køra detta.
Vi ska laga en docker image som:
1. Har python installert (https://hub.docker.com/_/python)
2. Har jq+curl installert (tip (kan bruka apt-get): `apt-get update && apt-get install -y jq && apt-get install -y curl && rm -rf /var/lib/apt/lists/*`)
3. Har kopierat in "mapping.json", "main.py" och "entrypoint.sh" på rætt stælle i fila.

Testa att laga en fil som heter bara `Dockerfile`. Det ær hær i man skriver "oppskriften" på hvordan applikationen ska pakkes sammen. Till eksempel information om hvor filer ska ligga nær docker kør "imagen" och vilket kommanda som ska kjøres per default med mera.

Prøva att læsa docsen fra Docker før att få det till. De kommandoen dere trenger før att bygga docker imagen
ær kun "FROM","RUN","WORKDIR","COPY" og "CMD".
Se templaten `Dockerfile_template` som en bas.
# Hvordan testa att allt fungerar?
Kør `./build_and_test.sh`. Hvis detta går igenom ær dere på god vei. Det ser då ut slikt:
```bash
...
===================================
============= RESULTS =============
===================================
Passes:      4
Failures:    0
Duration:    355.209923ms
Total tests: 4
```


# Om `./build_and_test.sh` går igenom
Nå kan vi faktiskt køra scripten ved att bara gøra `docker run --rm bysykkel:latest`

Detta ær fordi var har lagat en default command `CMD [ "/bin/sh", "./entrypoint.sh" ]` som
exekverar entrypoint scripten. Men vi kan overrida den om vi vill se hva delarna gør var før sig

Vi kan också exekvera inuti docker imagen. Kør
```bash
# Startar "bash" shell interpreter i imagen genom att
# overridea CMD argumentet
docker run -it /bin/bash
# Kør nå feks `ls` før att se vad som finns der i
```
Man kan också køra delar av kommandoet før att se hur det fungerar
Eg (inuti container):
```bash
root@a93138440da3:/usr/src/app# curl -s https://gbfs.urbansharing.com/oslobysykkel.no/station_status.json | jq '[.data.stations[] | {station_id, num_bikes_available, num_docks_available}]'`
...
  {
    "station_id": "744",
    "num_bikes_available": 4,
    "num_docks_available": 5
  },
  {
    "station_id": "485",
    "num_bikes_available": 12,
    "num_docks_available": 9
  }
  ...
```
Da kan vi också se hva JQ faktiskt gør. Det ær bra att vara medveten om att jq existerar och ær ett kraftigt verktøy och vad man kan gøra med det. JQ docs (*eller chatGPT*) kan vara till hjælp hvis man vill laga en spørring sjælv.



## Før den extra intresserade


### Under panseret - vilken image bygger vår image på?
Hær ær fila som vi bygger upp på (beroende på vilken python du brukte): https://github.com/docker-library/python/blob/master/3.11/slim-bullseye/Dockerfile
Kan vara intressant att se hvordan den ser ut, trenger ikke førstå allt. Men vi kan se att den gør liknande
ting som vi gjorde och att den igen bygger på en annen image.

### Container structure test
Vi bruke container structure tests her før att verifisera att vi var på rett spor, og vi brukte docker før att køra testerna. Så det ær lite inception. Den CSR ær noe jag har snublet øver i det siste, og det kan vara lurt att bruka det till att få en viss "Test-driven development" når man prøver att konstruera en Docker image. https://github.com/GoogleContainerTools/container-structure-test


### Vill du laga en egen "mapping" før en annan stasjon?
Du kan finna all mulig information her: https://gbfs.urbansharing.com/oslobysykkel.no/station_information.json
All information finns her: https://oslobysykkel.no/apne-data/sanntid