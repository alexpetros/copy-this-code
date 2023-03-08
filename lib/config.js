/**
 * Very simple file parser for environment variables.
 *
 * Parse a config file in KEY=VALUE format. The only restrictions iare that keys must be one line,
 * the KEY cannot contain an '=' character in it. Lines without '=' will be ignored.
 *
 * This is basically what dotenv does, minus the "startup" step. Instead it just parses the config
 * synchronously whenever the module is imported. That step is essentially part of your program's
 * "boot time".
 *
 * Dotenv is actually a great library, but parsing config files is also dead simple, and having your
 * own parser allows you quickly change things to meet your applications needs. Want to parse
 * "true" and "false" as booleans? Easy! And you can just write it instead of looking at docs.
 *
 */
import fs from 'node:fs'

// For a real app, I usually hardcode this to './.env'
const ENV_FILE_LOCATION = './test/test-env'

let configString = ''
try {
  configString = fs.readFileSync(ENV_FILE_LOCATION).toString()
} catch {
  throw new Error(`WARNING: Failed to open config file - ensure that ${ENV_FILE_LOCATION} is in the source root.`)
}

const config = configString
  .split(/\r?\n/)                         // Split the file on the newlines
  .filter((line) => line.includes('='))   // Filter out lines without =
  .map((line) => {                        // Split the line by the first =
    const splitPoint = line.indexOf('=')
    return [line.substring(0, splitPoint), line.substring(splitPoint + 1)]
  })
  .reduce((config, line) => ({ ...config, [line[0]]: line[1] }), {}) // Compile pairs into an object

export default config
