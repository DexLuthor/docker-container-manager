#!/bin/bash

# Configuration
ID="docker"
KIND="images"
URL="https://hub.docker.com"
SEARCH_URL="https://index.docker.io/v1/search?q="
MIN_QUERY_LENGTH=2
MAX_RETURN=10

# Function to check if the query length is sufficient
has_min_query_length() {
  [[ ${#1} -ge $MIN_QUERY_LENGTH ]]
}

# Function to perform the search
search_docker() {
  local query="$1"

  if ! has_min_query_length "$query"; then
    echo '{"items":[]}'
    return
  fi

  # Query the Docker Hub API
  response=$(curl -s "${SEARCH_URL}${query}")
  if [[ -z "$response" ]]; then
    echo '{"items":[]}'
    return
  fi

  # Parse and display results
  echo "$response" | jq --arg url "$URL" --arg id "$ID" '
    {
      items: (
        .results[:'"$MAX_RETURN"'] | map({
          title: .name,
          url: "\($url)/\((.is_official | if . then "_" else "r" end))/\(.name)",
          subtitle: "\(.description) ~ \(.star_count)★",
          arg: "\($url)/\((.is_official | if . then "_" else "r" end))/\(.name)",
          icon: { path: "icon-cache/\($id).png" }
        })
      )
    }
  '
}

# Main
if [[ -z "$1" ]]; then
  echo "Usage: $0 <search_query>"
  exit 1
fi

search_docker "$1"
