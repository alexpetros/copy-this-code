#!/bin/bash
set -euo pipefail

echo "Starting daily backup for $(date -I)" >&2

aws_bucket_path="s3://YOUR_BUCKET_HERE"
temp_filename="./temp-backup.db"
new_backup="$(date -I)-backup.db.gz"

# Get the backup file from 30 days ago that we need to delete
# This only only works with GNU date, which is what the fly.io servers have
backup_to_delete="$(date -I -d '30 days ago')-backup.db.gz"
# This commented-out function works on MacOS
# backup_to_delete="$(date -I -v -30d)-backup.db.gz"

# This $DATABASE_FP should be in the environment already
sqlite3 "$DATABASE_FP" ".backup $temp_filename"
gzip "$temp_filename"
aws s3 cp "$temp_filename".gz "$aws_bucket_path/$new_backup"
aws s3 rm "$aws_bucket_path/$backup_to_delete"
