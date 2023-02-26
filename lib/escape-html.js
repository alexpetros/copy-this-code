/**
 * Sanitize HTML text with escape characters.
 *
 * Inserting HTML into the document dynamically creates securtiy risks, specifically the risk that a
 * malicious actor will insert script tags into user-supplied input. This kind of vulnerability is
 * called a Cross-Site Scripting (XSS) attack. In order to mitigate that, we escape certain control
 * characters so that HTML will know to render them, and not use them for control flow.
 *
 * Use this method to escape your strings so that you can safely insert them into HTML documents as
 * text. Only insert untrusted text, not untrusted attributes i.e. item in `<li>${item}` can be
 * untrusted, but not className in `<li class=${className}>`.
 *
 */
export function escapeHtmlText (value) {
  const stringValue = value.toString()
  const entityMap = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#x27;',
    '/': '&#x2F;',
    '`': '&grave;',
    '=': '&#x3D;'
  }

  // Match any of the characters inside /[ ... ]/
  const regex = /[&<>"'`=/]/g
  return stringValue.replace(regex, match => entityMap[match])
}

/*
 * Escape all HTML text values in a template string.
 *
 * Import this function and put it in front of your template strings (the ones with backticks) to
 * escape any values for example:
 *
 *   html`<ul>Shopping List <li>${item1}<li>${item2}</ul>`
 *
 * If item1 or item2 have unsafe HTML characters in them, they will be escaped and display safely
 * and correctly in the browser.
 *
 * Note that we don't escape the entire string, *just the values*. That's because we don't want to
 * escape the actual tags (<tr>, <p>, and so forth) that we're trying to build, only the parts that
 * someone could insert an unwanted tag.
 */
export function html (strings, ...values) {
  const sanitizedValues = values.map(escapeHtmlText)
  // Using the sanitized values, substitute the values into the string
  return String.raw({ raw: strings }, ...sanitizedValues)
}

