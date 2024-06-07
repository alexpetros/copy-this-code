#!/bin/bash
# Download all the files from a list of URLs
set -euo pipefail

OUTPUT_DIR="./files"

function quit {
  echo >&2 $1
  exit 1
}

# Read each line from STDIN
while IFS='$\n' read -r line; do
  # Save the file as whatever the last file is
  filename=$(echo $line | awk -F '/' '{ print $NF }')
  curl $line > "$OUTPUT_DIR/$filename"
  sleep .3
done
