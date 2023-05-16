import test from 'node:test'
import assert from 'node:assert/strict'
import * as sleep from '../sleep.js'

test('it sleeps for 100 ms', async () => {
  const startTime = (new Date()).getTime()
  await sleep.sleep(100)
  const endTime = (new Date()).getTime()

  // Include 5ms of leeway
  const success = Math.abs(endTime - startTime - 100) < 5
  assert(success)
})
