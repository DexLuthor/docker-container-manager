#!/bin/bash

# Get all Docker containers (running and stopped)
containers=$(docker ps -a --format '{{json .}}')

# Begin JSON output
echo '{ "rerun": 1, "items": ['

# Initialize counter
count=0

# Loop through containers
echo "$containers" | while read -r container_json; do
    # Use jq to parse needed fields
    name=$(echo "$container_json" | jq -r '.Names')
    id=$(echo "$container_json" | jq -r '.ID')
    image=$(echo "$container_json" | jq -r '.Image')
    status=$(echo "$container_json" | jq -r '.Status')

    # Determine status prefix
    if [[ "$status" == Up* ]]; then
        container_health=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}{{end}}' $name)
        if [[ "$container_health" == "unhealthy" ]]; then
            prefix="🟢🤒"
        else
            prefix="🟢"
        fi
    else
        prefix="🔴"
    fi

    # Add comma if not the first item
    [ $count -ne 0 ] && echo ","

    # Output Alfred item
    echo "  {
        \"title\": \"$prefix $name\",
        \"subtitle\": \"ID: $id | Image: $image\",
        \"arg\": \"$id\",
        \"uid\": \"$id\",
        \"autocomplete\": \"$name\",
	    \"action\": \"Alfred is Great\"
    }"

    count=$((count + 1))
done

# End JSON
echo ']}'
