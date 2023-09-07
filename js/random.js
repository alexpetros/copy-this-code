async function getRandomKey () {
  return new Promise((resolve, reject) => {
    crypto.randomBytes(256, (err, buf) => {
      if (err) reject(err)
      resolve(buf.toString('hex'))
    })
  })
}
