#!/bin/bash

container_id="$1"

alfred_action_item() {
    local title="$1"
    local subtitle="$2"
    local arg="$3"
    local uid="$4"
    local action="$5"
    echo "  {
        \"title\": \"$title\",
        \"subtitle\": \"$subtitle\",
        \"arg\": \"$arg\",
        \"uid\": \"$uid\",
        \"autocomplete\": \"$title\",
        \"action\": \"$action\"
    }"
}
#todo handle when no param sooner
echo '{ "items": ['

# If a search term is provided, treat it as container ID
if [[ -n "$container_id" ]]; then
    match=$(docker ps -a --format '{{json .}}' | jq -c --arg term "$container_id" 'select(.ID | startswith($term))')

    if [[ -z "$match" ]]; then
        alfred_action_item "🔴Container with ID \"$container_id\" not found" "No such container exists" "" "notfound-$container_id" "none"
    else
      # todo jq installation
        name=$(echo "$match" | jq -r '.Names')
        id=$(echo "$match" | jq -r '.ID')
        status=$(echo "$match" | jq -r '.Status')

        running=false
        if [[ "$status" == Up* ]]; then
            running=true
        fi

        # Adds stop action
        if $running; then
            alfred_action_item "🛑Stop '$name'" "" "stop,$id" "stop-$id" "stop"
            echo ","
            # Adds restart action
            alfred_action_item "🔄Restart '$name'" "" "restart,$id" "restart-$id" "restart"
            echo ","
        else
            # Adds start action
            alfred_action_item "🟢Start '$name'" "" "start,$id" "start-$id" "start"
            echo ","
        fi

        # Adds Delete
        alfred_action_item "🗑Delete '$name'" "" "delete,$id" "delete-$id" "delete"
        echo ","
        
        # Logs tail
        alfred_action_item "📜Tail logs" "" "logs,$id" "logs-$id" "logs"
        echo ","
      
        # CLI into container
        if $running; then
          alfred_action_item "💻Connect to shell" "" "cli,$id" "cli-$id" "cli"
        fi
    fi

    echo ']}'
    exit 0
fi
