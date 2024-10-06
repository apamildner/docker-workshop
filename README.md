# Docker workshop + shell scripting + lite linux
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
Detta ær det underliggande kommandot, som har noe dependencies:
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
1. Har python installert (https://hub.docker.com/_/python) (bruk gjerne python:3.12.7-alpine)
2. Har jq+curl installert (tip (kan bruka apt-get): `RUN apk update && apk add jq=1.7.1-r0 curl=8.10.1-r0`)
3. Har kopierat in "mapping.json", "main.py" och "entrypoint.sh" på riktig sted i docker imagen ( kan bruke feks /usr/src/app som working directory)

Testa att laga en fil som heter bara `Dockerfile`. Det ær hær i man skriver "oppskriften" på hvordan applikationen ska pakkes sammen. Till eksempel information om hvor filer ska ligga nær docker kør "imagen" och vilket kommanda som ska kjøres per default med mera.

Prøva att læsa docsen fra Docker før att få det till. De kommandoen dere trenger før att bygga docker imagen
ær kun "FROM","RUN","WORKDIR","COPY" og "CMD".
Se templaten `Dockerfile_template` som en bas.
# Hvordan testa att allt fungerar?
Kør `./build_image`. Hvis detta går igenom ær dere på god vei. Det ser då ut slikt:
```bash
...
Building image ...
[+] Building 2.9s (10/10) FINISHED                                                                                           docker:desktop-linux
 => [internal] load build definition from Dockerfile                                                                                         0.0s
 => => transferring dockerfile: 511B                                                                                                         0.0s
 => [internal] load metadata for docker.io/library/python:3.12.7-alpine                                                                      2.9s
 => [auth] library/python:pull token for registry-1.docker.io                                                                                0.0s
 => [internal] load .dockerignore                                                                                                            0.0s
 => => transferring context: 2B                                                                                                              0.0s
 => [1/4] FROM docker.io/library/python:3.12.7-alpine@sha256:e75de178bc15e72f3f16bf75a6b484e33d39a456f03fc771a2b3abb9146b75f8                0.0s
 => [internal] load build context                                                                                                            0.0s
 => => transferring context: 93B                                                                                                             0.0s
 => CACHED [2/4] RUN apk update && apk add jq=1.7.1-r0 curl=8.10.1-r0                                                                        0.0s
 => CACHED [3/4] WORKDIR /usr/src/app                                                                                                        0.0s
 => CACHED [4/4] COPY mapping.json main.py entrypoint.sh /usr/src/app                                                                        0.0s
 => exporting to image                                                                                                                       0.0s
 => => exporting layers                                                                                                                      0.0s
 => => writing image sha256:a459b5425211f17d28c0496943a4734e966b8abb2b742dd2f069e139c14f0540                                                 0.0s
 => => naming to docker.io/library/bysykkel:latest                                                                                           0.0s

What's next:
    View a summary of image vulnerabilities and recommendations → docker scout quickview 
Image bysykkel:latest successfully built!
```


# Om `./build_image` går igenom
Nå burde vi faktiskt køra scripten ved att bara gøra `docker run --rm bysykkel:latest`

Detta ær fordi var har lagat en default command `CMD [ "/bin/sh", "./entrypoint.sh" ]` som
exekverar entrypoint scripten. Men vi kan overrida den om vi vill se hva delarna gør var før sig

Vi kan också exekvera inuti docker imagen. Kør
```bash
# Startar "sh" shell interpreter i imagen genom att
# overridea CMD argumentet
docker run --rm -it bysykkel:latest /bin/sh
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
Da kan vi också se hva JQ faktiskt gør. Det ær bra att vara medveten om att jq existerar och ær ett kraftigt verktøy och vad man kan gøra med det. JQ docs (*eller chatGPT*) kan vara till hjælp hvis man vill laga en spørring sjælv. Nå brukte
vi det som en typisk "dependency" som kanske trengs i miljøet som din kod skall kjøre.



## Før den extra intresserade


### Under panseret - vilken image bygger vår image på?
Hær ær fila som vi bygger allt på [python:3.12.7-alpine](https://hub.docker.com/layers/library/python/3.12.7-alpine/images/sha256-2163c5b97d8aa257d70f5b13eed2b9ae7f261fd479c4b114ca88160c7f2e6409?context=explore)
Kan vara intressant att se hvordan den ser ut, trenger ikke førstå allt. Men vi kan se att den gør liknande
ting som vi gjorde och att den igen bygger på en annen image.

### Laga en fancier command line greie
Nå vill vi simplifisera allt, sån att vi bara kan kjøra "bysykkel" direkte fra kommandolinjen, och
att det magiskt fungerar utan att vi trenger att "huske" att vi faktiskt kør en docker image osv.

På deres maskin, så har man en $PATH som ær en lista med folders der som maskinen finner ting som kan exekveras når man skriver till exempel "docker/ls/python/git" osv. Hver kommando som du kjører kan man bruka "which {command}" før att se hvor maskinen tror att programmet ær nånstans. Det kule ær att i /usr/local/bin kan vi lægga våra egna scripts,
bara vi huskar att skriva en "#!" symbol som førteller vilket program som skall interpretera koden (med mindre det ær en faktiskt kjørbar fil, till exempel byggda Go/C program).
I detta tilfelle vill vi att bash, som ær vårat terminalprogram, skall køra docker kommandot. I.e føljande:

```
#! /bin/bash
docker run --rm --it bysykkel:latest
```
Nå kan vi installera detta i deres `/usr/local/bin`. Husk att dere må være sudo før att skriva i /usr/local/bin, så hvis
man må gør privelege escalation (grønne hengelåset) før att bli sudo så må man gøra det først.
```bash
echo '#! /bin/bash\ndocker run --rm -it bysykkel:latest' | sudo tee /usr/local/bin/bysykkel && sudo chmod +x /usr/local/bin/bysykkel
```

Nå burde du kunna køra kun  `bysykkel` og nyte frukten av ditt arbeid!

### Vill du laga en egen "mapping" før en annan stasjon?
Du kan finna all mulig information her: https://gbfs.urbansharing.com/oslobysykkel.no/station_information.json
All information finns her: https://oslobysykkel.no/apne-data/sanntid



