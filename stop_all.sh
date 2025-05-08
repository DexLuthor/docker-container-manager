#!/bin/bash

running_containers=$(docker ps -q)

if [ -z "$running_containers" ]; then
    echo "There are no running containers."
else
    container_names_before=$(docker ps --filter "id=$running_containers" --format "{{.Names}}")

    docker stop "$running_containers"

    container_names_after=$(docker ps --filter "status=exited" --format "{{.Names}}")

    stopped_containers=$(comm -13 <(echo "$container_names_before" | sort) <(echo "$container_names_after" | sort))

    if [ -z "$stopped_containers" ]; then
        echo "No containers were stopped."
    else
        echo "The following containers were just stopped:"
        echo "$stopped_containers"
    fi
fi
