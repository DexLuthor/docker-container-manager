#!/bin/bash

alfred_action_item() {
    local title="$1"
    local subtitle="$2"
    local arg="$3"
    local uid="$4"
    echo "  {
        \"title\": \"$title\",
        \"subtitle\": \"$subtitle\",
        \"arg\": \"$arg\",
        \"uid\": \"$uid\",
        \"autocomplete\": \"$title\"
    }"
}

# Get all Docker containers (running and stopped)
containers=$(docker ps -a --format '{{json .}}')

# Begin JSON output
echo '{ "rerun": 1, "items": ['

alfred_action_item "🔨Stop the world" "Stop all running containers" "stop-all,$(docker ps -q | awk 'BEGIN { ORS="," } { print }' | sed 's/,$//;s/$/\n/')" "3c7e03d8-81a6-3592-a354-d0c5a036099b" "Stop all containers"
# Initialize counter

# Loop through containers
echo "$containers" | while read -r container_json; do
    # Use jq to parse needed fields
    name=$(echo "$container_json" | jq -r '.Names')
    id=$(echo "$container_json" | jq -r '.ID') 
    image=$(echo "$container_json" | jq -r '.Image')
    status=$(echo "$container_json" | jq -r '.Status')

    # Determine status prefix
    if [[ "$status" == Up* ]]; then
        container_health=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}{{end}}' "$name")
        if [[ "$container_health" == "unhealthy" ]]; then
            prefix="🟢🤒"
        else
            prefix="🟢"
        fi
    else
        prefix="🔴"
    fi

    echo ","

    # Output Alfred item
    alfred_action_item "$prefix $name" "ID: $id | Image: $image" "$id" "$id" "$name"

    count=$((count + 1))
done

# End JSON
echo ']}'
