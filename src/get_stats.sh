#!/bin/bash

./src/check_dependencies.sh

# Get docker stats with desired fields
data=$(docker stats --no-stream --format "{{.ID}}|{{.Name}}|{{.CPUPerc}}|{{.MemUsage}}|{{.NetIO}}")

# Start JSON
echo '{ "rerun": 1, "items": ['

first=true

# Read each line and convert to Alfred JSON format
while IFS='|' read -r id name cpu mem net; do
    # Skip empty lines
    [ -z "$name" ] && continue

    # Handle comma separation
    if [ "$first" = true ]; then
        first=false
    else
        echo ','
    fi

    # Output JSON object
    echo '  {'
    echo "    \"title\": \"$name\","
    echo "    \"subtitle\": \"CPU: $cpu | Memory: $mem | Network: $net\","
    echo "    \"arg\": \"$id\","
    echo "    \"icon\": { \"path\": \"icon.png\" }"
    echo -n '  }'
done <<< "$data"

# End JSON
echo ''
echo '] }'
