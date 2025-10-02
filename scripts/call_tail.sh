#!/usr/bin/env bash
set -euo pipefail
: "${BASE_URL:?Set BASE_URL}"
: "${LIST:=a,b,c}"
N="${N:-2}"
AUTH_HEADER="${AUTH_HEADER:-}"

JSON_LIST=$(printf '%s' "$LIST" | awk -F, '{printf "["; for(i=1;i<=NF;i++){printf "%s"%s"", (i>1?",":""), $i} printf "]"}')
DATA=$(printf '{"list": %s, "n": %s}' "$JSON_LIST" "$N")

curl -s -X POST "$BASE_URL/v1/list/tail"   -H "Content-Type: application/json"   ${AUTH_HEADER:+-H "$AUTH_HEADER"}   -d "$DATA" | jq .
