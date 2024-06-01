#!/bin/bash
# Get all the URLs with a specific file extension from a list of web pages in STDIN
#
# Requires hq installed

set -euo pipefail

FILE_EXTENSION="pdf"
OUTPUT_FILENAME="all-urls"
TEMP_FILENAME="temp__$OUTPUT_FILENAME"

function cleanup {
  rm -f "$TEMP_FILENAME"
}
trap cleanup EXIT
cleanup

# Read each line from STDIN
while IFS='$\n' read -r line; do
  # Curl the URL, get all the links, and filter out the ones that don't have the file extension
  curl $line | hq a attr href | grep "\.$FILE_EXTENSION$" >> "$TEMP_FILENAME"
  sleep .5
done


mv "$TEMP_FILENAME" "$OUTPUT_FILENAME"

