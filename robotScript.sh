#!/bin/bash
if [ ! -f $CATALINA_HOME/webapps/ROOT/robots.txt ] ; then
  if [ $ROBOTS == "true" ] ; then  
  echo "User-agent: *
Disallow: /" > $CATALINA_HOME/webapps/ROOT/robots.txt
  fi
fi
