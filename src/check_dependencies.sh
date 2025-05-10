#!/bin/bash

missing=false
if [ -z "$(which docker)" ]; then
    missing=true
    echo '{ "items": [{"title": "Missing dependency", "subtitle": "Ensure docker or jq are installed"}] }'
fi

if [ -z "$(which jq)" ]; then
    missing=true
    echo '{ "items": [{"title": "Missing dependency", "subtitle": "Ensure docker or jq are installed"}] }'
fi

if [ "$missing" = true ]; then
    exit 1
fi

