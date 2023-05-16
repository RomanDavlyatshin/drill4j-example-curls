#!/usr/bin/env sh

# Description:
# Starts the new global session
# Default session name is "global-*current time in unix seconds*". Make sure to save if for later use in ./stop-global-session.sh
#
# When to use: call before launching tests
#
# Example call:
# ./start-global-session.sh drill-admin.somehost.com 8090 mygroup

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
SESSION_ID=${4-"global-$(date +%s)"}

TOKEN=$(curl -s -X POST $RETRY_OPTIONS http://$ADMIN_SERVER_ADDRESS:$ADMIN_SERVER_PORT/api/login \
    -H 'accept: */*' -H 'Content-Type: text/plain' \
    -d '{"name":"guest","password":""}' | jq -r .token \
)

curl --request POST -sS -i -v $RETRY_OPTIONS "http://$ADMIN_SERVER_ADDRESS:$ADMIN_SERVER_PORT/api/groups/$GROUP_NAME/plugins/test2code/dispatch-action" \
  -H "Authorization: Bearer $TOKEN" \
  --data-raw '{"type":"START","payload":{"sessionId":"$SESSION_ID", "testType":"background", "isRealtime":false,"isGlobal":true}}'

echo $SESSION_ID