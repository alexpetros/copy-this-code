#!/bin/bash
# Download the current litstream backup
set -euo pipefail

# Get AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY from your .env
# And put them in the shell environment
export $(cat .env | xargs)

db_name="sqlite.db"
s3_litestream_url="s3://litstream-bucket/backup"

if [[ -f "$db_name"-wal ]]; then
  echo "Database is still in use - make sure WAL is cleaned up."
  exit 1
fi

rm -f "$db_name"
litestream restore -o $"db_name" "$s3_litestream_url"

rm -f "$dn_name".tmp-wal
rm -f "$dn_name".tmp-shm

# I use this to copy the backup to a directory above this one
# You can comment it out if you want
filename="$(date -I)-backup.db"
cp "$db_name" "../backups/$filename"
