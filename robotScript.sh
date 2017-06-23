#!/bin/bash
if [ ! -f $CATALINA_HOME/webapps/ROOT/robots.txt ] ; then
    echo "User-agent: *
Disallow: /" > $CATALINA_HOME/webapps/ROOT/robots.txt
fi
