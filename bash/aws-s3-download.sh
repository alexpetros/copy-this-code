#!/bin//bash
# This script requires the aws CLI to be installed

set -euo pipefail
start=$SECONDS

# Get AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY from your .env
# And put them in the shell environment
export $(cat .env | xargs)

aws s3 cp s3://example-bucket/logs ./new-logs --recursive
rm -rf ./logs
mv ./new-logs logs

duration=$(( SECONDS - start ))
echo Finished downloading in $duration

