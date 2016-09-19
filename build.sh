#!/bin/bash
docker build -t kramerius-builder .
s2i build --incremental=true --exclude="" https://github.com/ceskaexpedice/kramerius.git kramerius-builder moravianlibrary/kramerius_s2i
