import fs from 'node:fs'
import Database from 'better-sqlite3'

// Match all files with names like 3-migration-name.sql
const MIGRATION_REGEX = /[0-9]+-.*\.sql/

export default class DatabaseConnection {
  #db

  constructor(fileName) {
    const dbName = fileName || ':memory:'
    try {
      this.#db = new Database(dbName, { fileMustExist: true })
    } catch (err) {
      if (err.code === 'SQLITE_CANTOPEN') {
        console.log(`Note: database ${dbName} does not exist; starting new one`)
        this.#db = new Database(dbName)
        // Add the migrations table to the new database
        this.run(`
          CREATE TABLE _migrations (
            filename TEXT NOT NULL,
            timestamp INTEGER DEFAULT CURRENT_TIMESTAMP
          );
        `)
      } else {
        throw err
      }
    }

    this.#db.pragma('journal_mode = WAL')
    this.#db.pragma('foreign_keys = ON')
    console.log(`Starting sqlite database from file: ${this.getDatabaseFile()}`)
  }

  getDatabaseFile() {
    return this.#db.pragma('database_list')[0].file
  }

  stop() {
    this.#db.close()
    this.#db = undefined
  }

  execFile(filePath) {
    const statements = fs.readFileSync(filePath).toString()
    return this.#db.exec(statements)
  }

  get(query, ...params) {
    return this.#db.prepare(query).get(...params)
  }

  all(query, ...params) {
    return this.#db.prepare(query).all(...params)
  }

  allRaw(query, ...params) {
    const statement = this.#db.prepare(query).raw(true)
    const columns = statement.columns()
    const results = statement.all(...params)
    return { columns, results }
  }

  run(query, ...params) {
    return this.#db.prepare(query).run(...params)
  }

  prepare(query) {
    return this.#db.prepare(query)
  }

  transaction(fn) {
    return this.#db.transaction(fn)
  }

  runMany(query, values) {
    const statement = this.#db.prepare(query)
    values.forEach(parameters => {
      // Spread an array if using ? parameters
      if (Array.isArray(parameters)) {
        statement.run(...parameters)
        // Otherwise use named parameters
      } else {
        statement.run(parameters)
      }
    })
  }

  runMigrations(dirName) {
    const migrations = fs.readdirSync(dirName, { withFileTypes: true })
      .filter(item => !item.isDirectory() && MIGRATION_REGEX.test(item.name))
      .map(item => {
        // Get the leading number of the migration so that we know what order to run them in
        const num = parseInt(item.name.match('[0-9]+')?.at(0))
        const filepath = `${item.path}/${item.name}`
        // Check whether the migration has been applied before
        const isApplied = this.get(
          `SELECT EXISTS (SELECT filename FROM _migrations WHERE filename = ?) as is_applied`,
          item.name
        ).is_applied === 1

        return { num, filepath, isApplied, ...item }
      })
      .sort((a, b) => (a.num - b.num))

    const unappliedMigrations = migrations.filter(migration => !migration.isApplied)
    const appliedMigrationsCount = migrations.length - unappliedMigrations.length

    console.log(`Migrations that were previously applied: ${appliedMigrationsCount}`)
    console.log(`Migrations to apply: ${unappliedMigrations.length}`)

    // Run all the unapplied migrations together in a single transaction
    // If any of them fail, the database should stay in the same state
    this.transaction(() => {
      for (const migration of unappliedMigrations) {
        console.log(`Applying migration ${migration.name}`)
        this.execFile(migration.filepath)
        this.run('INSERT INTO _migrations (filename) VALUES (?)', migration.name)
      }
    })()

  }
}
