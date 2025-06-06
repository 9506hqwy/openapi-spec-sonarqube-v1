#!/bin/bash -eu
# Dump response examples from SonarQube web services API.
set -o pipefail

URL='http://127.0.0.1:9000/api/webservices'
USERNAME='admin'
PASSWORD='admin'

BASE_DIR="$(dirname "$(readlink -f "$0")")/../temp"
WEB_SERVICES="${BASE_DIR}/api.json"
curl -fsSL -o "${WEB_SERVICES}" -u "${USERNAME}:${PASSWORD}" "${URL}/list"

jq -c '.webServices[]' "${WEB_SERVICES}" | while read -r CONTROLLER_OBJ
do
    CONTROLLER=$(echo "${CONTROLLER_OBJ}" | jq -r '.path')
    echo "${CONTROLLER_OBJ}" | jq -c '.actions[]' | while read -r ACTION_OBJ
    do
		HAS_RESPONSE_EXAMPLE=$(echo "${ACTION_OBJ}" | jq -r '.hasResponseExample')
		if ${HAS_RESPONSE_EXAMPLE}; then
            ACTION=$(echo "${ACTION_OBJ}" | jq -r '.key')
		    RET_OBJ=$(curl -fsSL -u "${USERNAME}:${PASSWORD}" "${URL}/response_example?action=${ACTION}&controller=${CONTROLLER}")

            FORMAT=$(echo "${RET_OBJ}" | jq -r '.format')
            if [[ "${FORMAT}" == "json" ]]; then
                FILE_NAME="${CONTROLLER////_}_${ACTION}.json"
                echo "${RET_OBJ}" | jq -r '.example' > "${BASE_DIR}/${FILE_NAME}"
            else
                echo "Skipping ${CONTROLLER}/${ACTION} as the response format is not JSON (format: ${FORMAT})"
            fi
        fi
    done
done
