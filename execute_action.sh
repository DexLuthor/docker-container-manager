#!/bin/bash

ACTION="$1"
CONTAINER="$2"

if [ -z "$CONTAINER" ]; then
  echo "Usage: $0 <container_name_or_id>"
  exit 1
fi

STATUS=$(docker inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null)

if [ "$ACTION" = "start" ]; then
  docker start "$CONTAINER"
  echo "Started container: $CONTAINER"
elif [ "$ACTION" = "stop" ]; then
  docker stop "$CONTAINER"
  echo "Stopped container: $CONTAINER"
elif [ "$ACTION" = "delete" ]; then
  docker rm "$CONTAINER"
  echo "Container '$CONTAINER' was deleted"
fi