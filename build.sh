#!/bin/bash
docker build -t kramerius-builder .
s2i build --incremental=true --exclude="" https://github.com/ceskaexpedice/kramerius.git kramerius-builder moravianlibrary/kramerius_s2i
if hash docker-squash 2>/dev/null; then
  docker-squash moravianlibrary/kramerius_s2i -t moravianlibrary/kramerius_s2i
fi
