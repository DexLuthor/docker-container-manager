#!/bin/bash

running_containers=$(docker ps -q)

if [ -z "$running_containers" ]; then
    echo "There are no running containers."
else
    # shellcheck disable=SC2086
    docker stop $running_containers > /dev/null
    
    # todo print names of stopped containers 
fi
