#!/bin/bash
# Basic framework for starting a shell script

set -euo pipefail

# Allow tracing with `TRACE=1 ./basic.sh`
if [[ "${TRACE-0}" == "1"  ]]; then set -o xtrace; fi

error() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S')]: $*" >&2
}

# Change script directory to script location
cd "$(dirname "$0")"

echo "This is the start of a basic bash script"
