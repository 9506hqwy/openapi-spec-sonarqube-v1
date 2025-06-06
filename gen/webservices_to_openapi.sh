#!/bin/bash -eu
# Create OpenAPI schema from SonarQube web services API.
set -o pipefail

BASE_DIR="$(dirname "$(readlink -f "$0")")/.."
SCHEMA_DIR="${BASE_DIR}/schema"
TEMP_DIR="${BASE_DIR}/temp"

cat "${SCHEMA_DIR}/base.yml"

WEB_SERVICES="${TEMP_DIR}/api.json"

echo 'paths:'
jq -c '.webServices[]' "${WEB_SERVICES}" | while read -r CONTROLLER_OBJ
do
    CONTROLLER=$(echo "${CONTROLLER_OBJ}" | jq -r '.path')
    echo "${CONTROLLER_OBJ}" | jq -c '.actions[]' | while read -r ACTION_OBJ
    do
		KEY=$(echo "${ACTION_OBJ}" | jq -r '.key')
		HAS_RESPONSE_EXAMPLE=$(echo "${ACTION_OBJ}" | jq -r '.hasResponseExample')
		RESPONSE_FILE_NAME="${CONTROLLER////_}_${KEY}.yml"

		if ! "${HAS_RESPONSE_EXAMPLE}" || [[ -f "${BASE_DIR}/components/${RESPONSE_FILE_NAME}" ]]; then
			DESCRIPTION=$(echo "${ACTION_OBJ}" | jq -r '.description' | tr -s '\n' ' ')
			POST=$(echo "${ACTION_OBJ}" | jq -r '.post')
			PARAMS_OBJ=$(echo "${ACTION_OBJ}" | jq -c '.params')
			PARAMS_LEN=$(echo "${PARAMS_OBJ}" | jq -r 'length')

			echo "  /${CONTROLLER}/${KEY}:"
			if ${POST}; then
				echo "    post:"
			else
				echo "    get:"
			fi
			echo "      description: |2"
			echo "        ${DESCRIPTION}"
			echo "      operationId: ${CONTROLLER////-}-${KEY}"

			if [[ ${PARAMS_LEN} -gt 0 ]]; then
				echo "      parameters:"
				echo "${PARAMS_OBJ}" | jq -c '.[]' | while read -r PARAM_OBJ
				do
					PARAM_KEY=$(echo "${PARAM_OBJ}" | jq -r '.key')
					PARAM_DESC=$(echo "${PARAM_OBJ}" | jq -r '.description' | tr -s '\n' ' ')
					PARAM_REQUIRED=$(echo "${PARAM_OBJ}" | jq -r '.required')

					echo "        - name: ${PARAM_KEY}"
					echo "          in: query"
					echo "          description: |2"
					echo "            ${PARAM_DESC}"
					echo "          required: ${PARAM_REQUIRED}"
					echo "          schema:"
					echo "            type: string"
				done
			fi

			echo "      responses:"
			echo "        '200':"
			if "${HAS_RESPONSE_EXAMPLE}"; then
				echo "          \$ref: \"./${RESPONSE_FILE_NAME}\""
			else
				echo "          description: not provided"
			fi
		fi
    done
done
