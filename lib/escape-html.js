/**
 * Sanitize HTML content with escape characters.
 *
 * Inserting HTML into the document dynamically creates securtiy risks, specifically the risk that a
 * malicious actor will insert script tags into user-supplied input. This kind of vulnerability is
 * called a Cross-Site Scripting (XSS) attack. In order to mitigate that, we escape certain control
 * characters so that HTML will know to render them, and not use them for control flow.
 *
 * This function is safe for all HTML content between tags, such as: `<li>${content}</li>`, and
 * *some* attributes (`<li class=${className}</li>`) but not all. That is because some attributes
 * will parse as pure text (like "id") and others will parse as JavaScript (like "onclick"). There's
 * a section on "Safe Sinks" in the link below that explains this, with a list of the safe
 * attributes to insert dynamic text into.
 *
 * For more information on mitigating XSS:
 * https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html#output-encoding-for-html-contexts
 */

/**
 * Replace any characters that could be used to inject a malicious script in an HTML context.
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

