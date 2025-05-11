#!/bin/bash

./src/check_dependencies.sh

# Optional filter passed from Alfred ({query})
FILTER="$1"

# Get all Docker images in format: repo|tag|imageID|size
docker images --format "{{.Repository}}|{{.Tag}}|{{.ID}}|{{.Size}}" | sort | uniq > /tmp/docker_images_parsed.txt

# Extract unique repositories
repos=$(cut -d '|' -f1 /tmp/docker_images_parsed.txt | sort | uniq)

echo '{"items": ['

first=1
for repo in $repos; do
    # Apply filter if set
    if [[ -n "$FILTER" && "$repo" != *"$FILTER"* ]]; then
        continue
    fi

    # Get matching lines for this repo
    lines=$(grep "^$repo|" /tmp/docker_images_parsed.txt)

    # Count tags
    tag_count=$(echo "$lines" | wc -l)

    # Get unique image IDs
    image_ids=$(echo "$lines" | cut -d'|' -f3 | sort | uniq)

    # Count containers from all image IDs
    total_containers=0
    for imgid in $image_ids; do
        count=$(docker ps -a --filter "ancestor=$imgid" --format '{{.ID}}' | wc -l)
        total_containers=$((total_containers + count))
    done

    # Get size from first tag (or sum all sizes if desired)
    size=$(echo "$lines" | head -n1 | cut -d'|' -f4)

    if [ $first -eq 0 ]; then
        echo ','
    fi
    first=0

    echo '  {'
    echo '    "title": "'"$repo"'",'
    echo '    "subtitle": "Tags: '"$tag_count"', Containers: '"$total_containers"', Size: '"$size"'",'
    echo '    "arg": "'"$repo"'",'
    echo '    "icon": { "path": "icon.png" }'
    echo '  }'
done

echo ']}'
