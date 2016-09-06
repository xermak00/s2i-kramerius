#!/bin/bash
docker build -t kramerius-builder .
s2i build --incremental=true --ref=openshift https://github.com/moravianlibrary/kramerius.git kramerius-builder moravianlibrary/kramerius_s2i
