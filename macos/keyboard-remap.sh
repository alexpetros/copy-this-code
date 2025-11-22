#!/bin/bash
# Set my favorite modifier keys on a new keyboard.
# Making these permanent is left as an exercise for another time.
# Right now they will reset on restart
#
# Platform: MacOS (tested on 26.1)
# Requires: jq, fzf
#
# With some help from:
#   https://hidutil-generator.netlify.app/
#   https://gist.github.com/paultheman/808be117d447c490a29d6405975d41bd
#   https://developer.apple.com/library/archive/technotes/tn2450/_index.html
#
# This was not what I set out to do tonight lol
set -euo pipefail

usage() {
  echo "USAGE: $1 [COMMAND]"
  echo "valid commands are: get set reset"
  exit 1
}

select_product_name() {
  hidutil list --ndjson | \
    jq --raw-output 'select(."Built-In"!=true and .Product != null) | .Product' | \
    sort | uniq | fzf
}

select_field() {
  hidutil list --ndjson | jq -r "select(.Product == \"$1\") | .$2" | head -n 1
}

match_string() {
  product="$(select_product_name)"
  vendor_id="$(select_field "$product" VendorID)"
  product_id="$(select_field "$product" ProductID)"

  echo "{\"VendorID\":$vendor_id,\"ProductID\":$product_id}"
}

get() {
  hidutil property --match "$(match_string)" --get 'UserKeyMapping'
}

set() {
  # First one is caps lock -> left control
  # Second one is left option -> left command
  # Third one is left command -> left option
  hidutil property --match "$(match_string)" --set '
  {"UserKeyMapping":[
    {
      "HIDKeyboardModifierMappingSrc": 0x700000039,
      "HIDKeyboardModifierMappingDst": 0x7000000E0
    },

    {
      "HIDKeyboardModifierMappingSrc": 0x7000000E2,
      "HIDKeyboardModifierMappingDst": 0x7000000E3
    },

    {
      "HIDKeyboardModifierMappingSrc": 0x7000000E3,
      "HIDKeyboardModifierMappingDst": 0x7000000E2
    }
  ]}
  '
}

reset() {
  hidutil property --match "$(match_string)" --set '{"UserKeyMapping": []}'
}

if [[ $# != 1 ]]; then
  usage
fi
command -v $1 || usage

$@
