/**
 * Get a promise that resolves after the time in milliseconds has elapsed.
 *
 * You can combine this with async/await syntax to "wait" for a certain period of time the
 * sequential execution of your function. For instance:
 *   await sleep(3000)
 * will continue executing the function after 3 seconds.
 */
export function sleep (milliseconds) {
  return new Promise((resolve) => setTimeout(() => resolve(), milliseconds))
}
