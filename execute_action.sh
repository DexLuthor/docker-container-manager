#!/bin/bash

ACTION="$1"
CONTAINER="$2"

if [ -z "$CONTAINER" ]; then
  exit 1
fi

if [ "$ACTION" = "start" ]; then
  docker start "$CONTAINER" > /dev/null
  echo "Started $CONTAINER"
elif [ "$ACTION" = "stop" ]; then
  docker stop "$CONTAINER" > /dev/null
  echo "Stopped $CONTAINER"
elif [ "$ACTION" = "delete" ]; then
  docker rm "$CONTAINER" > /dev/null
  echo "Deleted '$CONTAINER'"
elif [ "$ACTION" = "restart" ]; then
  docker restart "$CONTAINER" > /dev/null
  echo "Restarted '$CONTAINER'"
fi
