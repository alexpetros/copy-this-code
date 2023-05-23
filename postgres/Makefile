.PHONY: db
db: kill
	docker compose up

.PHONY: bg
bg: kill
	docker compose up -d

.PHONY: psql
psql:
	PGPASSWORD=password psql -d postgres -h localhost -p 5432 -U root

# You need to write a script (pg_dump of some sort) that loads your database
.PHONY: dump
dump:
	@echo 'Write a script that dumps your database to BACKUPS_DIR' && exit 1
	find ./BACKUPS_DIR -type f | sort -nr | head -1 | xargs -I {} cp {} ./init/1-load-db.sql

.PHONY: clean
clean:
	rm -rf data

kill:
	docker ps | awk '/postgres/{print $$1}' | xargs docker kill
