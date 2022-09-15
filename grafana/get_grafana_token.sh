#!/bin/bash
set -eo pipefail

eval "$(jq -r '@sh "CLIENT_ID=\(.client_id) CLIENT_SECRET=\(.client_secret) TENANT_ID=\(.tenant_id)"')"

RESP=$(curl -X POST -H 'Content-Type: application/x-www-form-urlencoded' \
-d "grant_type=client_credentials&client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}&resource=ce34e7e5-485f-4d76-964f-b3d2b16d1e4f" \
https://login.microsoftonline.com/${TENANT_ID}/oauth2/token)


TOKEN=$(echo $RESP | jq -r '.access_token')

jq -n --arg token "${TOKEN}" '{"token":$token}'