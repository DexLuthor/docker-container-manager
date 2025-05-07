container_id="$1"

# Function to output Alfred item
output_item() {
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

echo '{ "items": ['

# If a search term is provided, treat it as container ID
if [[ -n "$container_id" ]]; then
    match=$(docker ps -a --format '{{json .}}' | jq -c --arg term "$container_id" 'select(.ID | startswith($term))')

    if [[ -z "$match" ]]; then
        output_item "🔴 Container with ID \"$container_id\" not found" "No such container exists" "" "notfound-$container_id" "none"
    else
        name=$(echo "$match" | jq -r '.Names')
        id=$(echo "$match" | jq -r '.ID')
        image=$(echo "$match" | jq -r '.Image')
        status=$(echo "$match" | jq -r '.Status')

        running=false
        if [[ "$status" == Up* ]]; then
            running=true
        fi

        # Adds start/stop action
        if $running; then
            output_item "🛑 Stop container: $name" "ID: $id | Image: $image" "stop,$id" "stop-$id" "stop"
            echo ","
        else
            output_item "▶️ Start container: $name" "ID: $id | Image: $image" "start,$id" "start-$id" "start"
            echo ","
        fi

        # Adds Delete
        output_item "🗑 Delete container: $name" "ID: $id | Image: $image" "delete,$id" "delete-$id" "delete"
        
        # Adds compose actions if needed
        
    fi

    echo ']}'
    exit 0
fi