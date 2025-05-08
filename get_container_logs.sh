#!/bin/bash

CONTAINER_NAME="$1"

LOGS=$(docker logs "$CONTAINER_NAME" 2>&1)

ESCAPED_LOGS=$(echo "$LOGS" | jq -Rs .)

# TODO configurable tail interval
echo "{
  \"rerun\": 3,
  \"response\":$ESCAPED_LOGS,
  \"footer\": \"Logs are updated every 3 seconds\",
  \"behaviour\": {
    \"scroll\": \"end\",
  }
}"
