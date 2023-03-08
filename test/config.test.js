import test from 'node:test'
import assert from 'node:assert/strict'
import config from '../lib/config.js'

test('it included the first item', async () => {
  assert.equal(config.TEST_API_KEY, 'thisisnotarealkey' )
})

test('it included the second item', async () => {
  assert.equal(config.IMPORTANT_BOOLEAN, 'true' )
})

test('it ignored lines without an "="', async () => {
  assert.equal(Object.keys(config).length, 2)
})

