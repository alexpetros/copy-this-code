#!/bin/bash
# Download all the files from a list of URLs
set -euo pipefail

URLS_LIST="urls.txt"
OUTPUT_DIR="./files"

function quit {
  echo >&2 $1
  exit 1
}

urls=$(cat "$URLS_LIST")

for url in $urls; do
  # Save the file as whatever the last file is
  filename=$(echo $url | awk -F '/' '{ print $NF }')
  curl $url > "$OUTPUT_DIR/$filename"
  sleep .3
done

