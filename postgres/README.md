# Alex's DB Mirror
This is a little docker compose project I use to run a local postgres database, often to mirror some
kind of production database.

The docker Postgres image has a directory where you can put initialization scripts that will run if
the database has no pre-existing data. Via the compose, that's mapped to `init` in this folder.

Compose will also create a `data` directory that persists the database.
