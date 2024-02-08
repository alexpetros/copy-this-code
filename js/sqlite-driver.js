import fs from 'node:fs'
import Database from 'better-sqlite3'

export default class DatabaseConnection {
  #db

  constructor(fileName) {
    const dbName = fileName || ':memory:'
    try {
      this.#db = new Database(dbName, { fileMustExist: true })
    } catch (err) {
      console.error(err)
      if (err.code === 'SQLITE_CANTOPEN') {
        throw new Error(`Failed to open db ${dbName}. Did you remember to initialize the database?`)
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
}
