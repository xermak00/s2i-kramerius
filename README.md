Kramerius - Docker image
========================================

This repository contains the source for building of [Kramerius application](https://github.com/ceskaexpedice/kramerius) as a Docker image using
[source-to-image](https://github.com/openshift/source-to-image).
The resulting image can be run using [Docker](http://docker.io).

Installation
---------------
To build a Kramerius builder image from scratch, run:
```
$ git clone https://github.com/moravianlibrary/sti-kramerius.git
$ docker build -t kramerius-builder .
```

Usage
---------------
To build Kramerius from your own repo using standalone S2I and then run the resulting image with Docker execute:
```
$ s2i build --incremental=true https://github.com/MartinRumanek/kramerius.git kramerius-builder kramerius
$ docker-compose up -d
```

**Accessing the application:**
```
http://localhost:8080/
```
