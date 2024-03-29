#!/bin/bash

set -e

disable_ssl ()
{
  until curl --output /dev/null --silent --head --fail http://localhost:8080
  do
      printf 'Waiting for webserver to start...\n'
      sleep 5
  done
  docker exec $(docker ps -q) bash -c "cd /opt/keycloak/bin && ./kcadm.sh config credentials --server http://localhost:8080 --realm master --user admin --password admin && ./kcadm.sh update realms/master -s sslRequired=NONE"
  echo "Disabled ssl check for keycloak realm master."
}

export -f disable_ssl
setsid bash -c disable_ssl >/home/mengelhardt/startup.log 2>&1 < /dev/null &
