import test from 'node:test'
import assert from 'node:assert/strict'
import * as escapeHtml from '../escape-html.js'

test('escapeHtmlText', () => {
  test('It properly escapes a script tag', () => {
    const maliciousString = '<script>alert()</script>'
    const escapedString = escapeHtml.escapeHtmlText(maliciousString)
    assert.equal(escapedString, '&lt;script&gt;alert()&lt;&#x2F;script&gt;')
  })
})

test('html template string', () => {
  test('It properly escapes a script tag', () => {
    const maliciousString = '<script>alert()</script>'
    const templateString = escapeHtml.html`<li>${maliciousString}`
    assert.equal(templateString, '<li>&lt;script&gt;alert()&lt;&#x2F;script&gt;')
  })
})
