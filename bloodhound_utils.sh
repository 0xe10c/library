#/usr/bin/env bash

# Utility script for BloodHound Community Edition
# Usage: source the script, then call one of the functions
#
# . ./bloodhound_utils.sh
#
# bh_get /self


################# ADJUST INFO #######################
BLOODHOUND_API_BASE_URL=http://<Bloodhound IP>/api/v2

LOGIN_DATA=$(cat <<'EOF'
{
    "login_method": "secret",
    "username": "spam@example.com",
    "secret": "changeme"
}
EOF
)
####################################################


function bh_login() {
    res=$(curl -s -X POST \
        "${BLOODHOUND_API_BASE_URL}/login" \
        -H 'accept: application/json' \
        -H 'prefer: wait=30' \
        -H 'Content-Type: application/json' \
        -d ${LOGIN_DATA}
    )

    echo ${res} | jq .data.session_token -r
}

function bh_get() {
    curl -s \
        -H 'accept: application/json' \
        -H 'Prefer: wait=30' \
        -H "Authorization: Bearer ${AUTH_TOKEN}" \
        "${BLOODHOUND_API_BASE_URL}${1}" \
        | jq .
}

function bh_post() {
    if [[ $# -lt 2 ]]; then
        curl -s -X POST \
            "${BLOODHOUND_API_BASE_URL}${1}" \
            -H 'accept: application/json' \
            -H 'Prefer: wait=30' \
            -H 'Content-Type: application/json' \
            -H "Authorization: Bearer ${AUTH_TOKEN}" \
            | jq .
    else
        curl -s \
            "${BLOODHOUND_API_BASE_URL}${1}" \
            -H 'accept: application/json' \
            -H 'Prefer: wait=30' \
            -H 'Content-Type: application/json' \
            -H "Authorization: Bearer ${AUTH_TOKEN}" \
            -d ${2} \
            | jq .
    fi
}

# clears database information
function bh_clear_data() {
    DATA=$(cat <<'EOF'
    {
        "deleteCollectedGraphData": true,
        "deleteFileIngestHistory": true,
        "deleteDataQualityHistory": true,
        "deleteAssetGroupSelectors": [
            0
        ]
    }
EOF
    )

    bh_post /clear-database ${DATA}
}

# usage: bh_upload /path/to/zip/file
# uploads zompressed file containing BH data
function bh_upload() {
    ZIP_FILE=${1}
    UPLOAD_ID=$(bh_post /file-upload/start | jq .data.id)
    curl -s -X POST \
        "${BLOODHOUND_API_BASE_URL}/file-upload/${UPLOAD_ID}" \
        -H "Content-Type: application/zip" \
        -H "Authorization: Bearer ${AUTH_TOKEN}" \
        -H "X-File-Upload-Name: $(basename ${ZIP_FILE})" \
        --data-binary @"${ZIP_FILE}"

    bh_post /file-upload/${UPLOAD_ID}/end
}

if [[ -z "$AUTH_TOKEN" ]]; then
    echo "[!] unauthenticated: logging in"
    AUTH_TOKEN=$(bh_login)
    export AUTH_TOKEN
fi


