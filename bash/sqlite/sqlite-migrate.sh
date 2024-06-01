#!/bin/bash
# Name: sqlite-migrations.sql
# Author: Alex Petros
#
# This is a bash-based sqlite migrations mechanism. To run it, you need:
# a) sqlite3 in the environment
# b) to specify DEFAULT_DB_FILEPATH and MIGRATIONS_DIRECTORY
# b) a database with a "_migrations" table
#
# THe next line of SQL will get you everything you need:
# CREATE TABLE _migrations (filename TEXT, timestamp INTEGER DEFAULT CURRENT_TIMESTAMP) STRICT;
#
# This script will look in the migrations directory (which needs to be
# specified below) and get all the files that end in .sql, in numberical order.
# Then it will check the _migrations table to see if a file with that name has
# been applied. It will error out if any of the files in that directory have
# whitespace in their name.

set -euo pipefail

DEFAULT_DB_FILEPATH=""
MIGRATIONS_DIRECTORY=""

# If there's a DB FILEPATH in the env, initialize it there, otherwise use the default
if [[ -z ${DATABASE_FP+x} ]]; then
  DATABASE_FP="$DEFAULT_DB_FILEPATH"
fi

function quit {
  >&2 echo "$1"
  exit 1
}

# Check whether or not the migration has already been applied
# This will fail with an exit code if the migration has not been applied
function check_migration {
  migration_name=$1
  query="SELECT EXISTS (SELECT filename FROM _migrations WHERE filename = '$migration_name')"
  sqlite3 -list -noheader "$DATABASE_FP" "$query" 2>/dev/null | grep 1
}

function apply_migration {
  migration_filepath="$1"
  # Run the migration inside of a transaction
  # The -bail option makes the CLI exit on the first error
  sqlite3 -bail "$DATABASE_FP" << EOF
  BEGIN; $(cat "$migration_filepath") ; COMMIT;
EOF
  # Save the migration's name if it was successfully applied
  sqlite3 "$DATABASE_FP" "INSERT INTO _migrations(filename) VALUES ('$migration_name');"
}

# Exit if any of the file names in this directory have spaces in them
! find "$MIGRATIONS_DIRECTORY" -type f | grep ' ' ||
  quit "Error: do not put filenames with spaces in them in the migration directory"

# Get the filepaths
migration_filepaths=$(find "$MIGRATIONS_DIRECTORY" -type f -name '*.sql' -print0 | sort -zV | tr '\0' ' ')

for filepath in $migration_filepaths; do
  migration_name=$(basename $filepath)

  # Skip the migration if it's already been applied, otherwise run it
  if [[ $(check_migration "$migration_name") ]]; then
    >&2 echo "Migration $migration_name has already been applied"
  else
    >&2 echo "Applying $migration_name"
    apply_migration "$filepath"
  fi
done

