#!/bin//bash
# Download an S3 bucket, with timing
# Requires the aws CLI to be installed
set -euo pipefail

s3_bucket="s3://example-bucket/subdir"
dest="./out"
tmp_dest="$dest-tmp"

start=$SECONDS

# Get AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY from your .env
# If you already have these in your environment, comment this line out
export $(cat .env | xargs)

aws s3 cp "$s3_bucket" "$tmp_dest" --recursive
rm -rf "$dest"
mv "$tmp_dest" "$dest"

duration=$(( SECONDS - start ))
echo Finished downloading in $duration seconds
