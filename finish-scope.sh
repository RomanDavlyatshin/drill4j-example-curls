#!/usr/bin/env sh

# Description:
# Equivalent to pressing "Finish scope" in Drill4J Admin UI
# It forcefuly finishes all running sessions and saves all data collected in the scope
#
# When to use: call before deploying new application version
#
# Example call:
# ./finish-scope.sh drill-admin.somehost.com 8090 mygroup

if [ $# -eq 0 ]
  then
    echo "ERROR: please, specify drill4j host"
    exit 1
fi

# Define variables
ADMIN_SERVER_ADDRESS=$1
ADMIN_SERVER_PORT=$2
GROUP_NAME=$3
RETRY_OPTIONS="--retry-connrefused --retry 3 --retry-delay 5"

TOKEN=$(curl -s -X POST $RETRY_OPTIONS http://$ADMIN_SERVER_ADDRESS:$ADMIN_SERVER_PORT/api/login \
    -H 'accept: */*' -H 'Content-Type: text/plain' \
    -d '{"name":"guest","password":""}' | jq -r .token \
)

curl --request POST -sS -i -v $RETRY_OPTIONS "http://$ADMIN_SERVER_ADDRESS:$ADMIN_SERVER_PORT/api/groups/$GROUP_NAME/plugins/test2code/dispatch-action" \
  -H "Authorization: Bearer $TOKEN" \
  --data-raw '{"type":"SWITCH_ACTIVE_SCOPE","payload":{"scopeName":"","prevScopeEnabled":true,"savePrevScope":true,"forceFinish":true}}'
