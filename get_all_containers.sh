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

# Loop through containers
echo "$containers" | while read -r container_json; do
    name=$(echo "$container_json" | jq -r '.Names')
    id=$(echo "$container_json" | jq -r '.ID')
    image=$(echo "$container_json" | jq -r '.Image')
    state=$(docker inspect --format '{{.State.Status}}' "$id")
    health=$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$id")

    # Determine color and emoji
    case "$state" in
        running)
            if [[ "$health" == "unhealthy" ]]; then
                prefix="🟢🤒"
            else
                prefix="🟢"
            fi
            ;;
        paused)
            prefix="🟡"
            ;;
        exited | dead | created)
            prefix="🔴"
            ;;
        restarting)
            prefix="🔄"
            ;;
        *)
            prefix="⚪"
            ;;
    esac

    echo ","

    alfred_action_item "$prefix $name" "ID: $id | Image: $image" "$id" "$id"
done

# End JSON
echo ']}'
