#!/bin/bash -eu
# Convert response examples to OpenAPI response schema.
set -o pipefail

BASE_DIR="$(dirname "$(readlink -f "$0")")/.."
SCHEMA_DIR="${BASE_DIR}/schema"
TEMP_DIR="${BASE_DIR}/temp"

function dump_schema() {
    local EXAMPLE_PATH=$1
    local SCHEMA_PATH=$2
    local QUERY=$3
    local INDENT=$4

    OBJECT_TYPE=$(jq -r "${QUERY} | type" "${EXAMPLE_PATH}")

    if [[ "${OBJECT_TYPE}" == 'number' ]]; then
        printf "%${INDENT}stype: integer\n" " " >> "${SCHEMA_PATH}"
        return
    fi

    if [[ "${OBJECT_TYPE}" == 'string' ]]; then
        printf "%${INDENT}stype: string\n" " " >> "${SCHEMA_PATH}"
        return
    fi

    if [[ "${OBJECT_TYPE}" == 'boolean' ]]; then
        printf "%${INDENT}stype: boolean\n" " " >> "${SCHEMA_PATH}"
        return
    fi

    if [[ "${OBJECT_TYPE}" == 'object' ]]; then
        printf "%${INDENT}stype: object\n" " " >> "${SCHEMA_PATH}"
        printf "%${INDENT}sproperties:\n" "" >> "${SCHEMA_PATH}"
        INDENT=$((INDENT + 2))
        jq -c "${QUERY} | keys_unsorted" "${EXAMPLE_PATH}" | jq -r '.[]' | while read -r PROPERTY
        do
            FORMAT="%${INDENT}s%s:\n"
            if [[ "${PROPERTY}" =~ ^[0-9]+$ ]]; then
                FORMAT="%${INDENT}s\"%s\":\n"
            fi

            printf "${FORMAT}" " " "${PROPERTY}" >> "${SCHEMA_PATH}"
            dump_schema "${EXAMPLE_PATH}" "${SCHEMA_PATH}" "${QUERY/%./}.\"${PROPERTY}\"" $((INDENT + 2))
        done
        return
    fi

    if [[ "${OBJECT_TYPE}" == 'array' ]]; then
        printf "%${INDENT}stype: array\n" " " >> "${SCHEMA_PATH}"
        printf "%${INDENT}sitems:\n" " " >> "${SCHEMA_PATH}"
        dump_schema "${EXAMPLE_PATH}" "${SCHEMA_PATH}" "${QUERY}[0]" $((INDENT + 2))
        return
    fi

    echo "Unknown object type: ${OBJECT_TYPE} in ${EXAMPLE_PATH} at query ${QUERY}"
}

for EXAMPLE in "${TEMP_DIR}"/*.json
do
    if [[ $EXAMPLE =~ /api.json ]]; then
        continue
    fi

    SCHEMA_FILE=$(basename "${EXAMPLE}")
    SCHEMA_PATH="${BASE_DIR}/components/${SCHEMA_FILE%.json}.yml"

    cat "${SCHEMA_DIR}/response.yml" > "${SCHEMA_PATH}"
    dump_schema "${EXAMPLE}" "${SCHEMA_PATH}" '.' 6

    MERGE_PATH="${BASE_DIR}/schema/${SCHEMA_FILE%.json}.yml"
    if [[ -f "${MERGE_PATH}" ]]; then
        TEMP_PATH="${BASE_DIR}/temp/${SCHEMA_FILE%.json}.yml.tmp"
        mv -f "${SCHEMA_PATH}" "${TEMP_PATH}"
        yq ". *d load(\"${MERGE_PATH}\")" "${TEMP_PATH}" > "${SCHEMA_PATH}"
    fi
done
