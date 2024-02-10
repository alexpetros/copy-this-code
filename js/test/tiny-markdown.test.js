import { describe, it } from 'node:test'
import assert from 'node:assert/strict'

import * as md from '../tiny-markdown.js'

describe('tiny markdown', () => {
  it('returns strings with no markdown exactly as is', () => {
    const str = 'TEST STRING WITH NO MD'
    const expected = '<p>\nTEST STRING WITH NO MD'
    const res = md.markdownToHtml(str)
    assert.equal(res, expected)
  })

  it('converts fully-qualified http links', () => {
    const str = 'This [word](http:&#x2F;&#x2F;example.com) is a link'
    const expected = '<p>\nThis <a href="http://example.com">word</a> is a link'
    const res = md.markdownToHtml(str)
    assert.equal(res, expected)
  })

  it('converts fully-qualified https links', () => {
    const str = 'This [word](https:&#x2F;&#x2F;example.com) is a link'
    const expected = '<p>\nThis <a href="https://example.com">word</a> is a link'
    const res = md.markdownToHtml(str)
    assert.equal(res, expected)
  })

  it('converts fully-qualified https links with forward slashes', () => {
    const str = 'This [word](https:&#x2F;&#x2F;example.com&#x2F;test-resources) is a link'
    const expected = '<p>\nThis <a href="https://example.com/test-resources">word</a> is a link'
    const res = md.markdownToHtml(str)
    assert.equal(res, expected)
  })

  it('does not converts relative links', () => {
    const str = 'This [word](example.com) is a link'
    const expected = '<p>\nThis [word](example.com) is a link'
    const res = md.markdownToHtml(str)
    assert.equal(res, expected)
  })

  it('italic strings surrounded by *', () => {
    const str = 'This *word* should be italicized'
    const expected = '<p>\nThis <em>word</em> should be italicized'
    const res = md.markdownToHtml(str)
    assert.equal(res, expected)
  })

  it('italic strings surrounded by *, even if two * at the end', () => {
    const str = 'This *word** should be italicized'
    const expected = '<p>\nThis <em>word*</em> should be italicized'
    const res = md.markdownToHtml(str)
    assert.equal(res, expected)
  })

  it('bolds strings surrounded by **', () => {
    const str = 'This **word** should be bolded'
    const expected = '<p>\nThis <b>word</b> should be bolded'
    const res = md.markdownToHtml(str)
    assert.equal(res, expected)
  })

  it('does not bold strings with a newline', () => {
    const str = 'This **should\n not** be bolded'
    const expected = '<p>\nThis **should\n not** be bolded'
    const res = md.markdownToHtml(str)
    assert.equal(res, expected)
  })

  it('does not italic strings with a newline', () => {
    const str = 'This *should \n not* be italicized'
    const expected = '<p>\nThis *should \n not* be italicized'
    const res = md.markdownToHtml(str)
    assert.equal(res, expected)
  })

  it('leaves unfinished * alone', () => {
    const str = 'This word* should not be bolded'
    const expected = '<p>\nThis word* should not be bolded'
    const res = md.markdownToHtml(str)
    assert.equal(res, expected)
  })

  it('adds a paragrah in a double line break', () => {
    const str = `First line

Second line
`
    const expected = `<p>
First line
<p>
Second line
`
    const res = md.markdownToHtml(str)
    assert.equal(res, expected)
  })

  it('wraps one bullet in a <ul>', () => {
    const str = `Some text
* Test
`
    const expected = `<p>
Some text
<ul>
<li>Test</li>
</ul>
<p>
`
    const res = md.markdownToHtml(str)
    assert.equal(res, expected)
  })

  it('wraps two bullets in a <ul>', () => {
    const str = `Some things you need to know:
* First
* Second
`
    const expected = `<p>
Some things you need to know:
<ul>
<li>First</li>
<li>Second</li>
</ul>
<p>
`
    const res = md.markdownToHtml(str)
    assert.equal(res, expected)
  })

  it('makes a list if the list is the final character', () => {
    const str = `Some text
* First`
    const expected = `<p>
Some text
<ul>
<li>First</li></ul>
<p>
`
    const res = md.markdownToHtml(str)
    assert.equal(res, expected)
  })

  it('does not make a list if there is no space after the bullet', () => {
    const str = `Some text
*First
`
    const expected = `<p>
Some text
*First
`
    const res = md.markdownToHtml(str)
    assert.equal(res, expected)
  })

  it('makes two lists when the <li>s are separate', () => {
    const str = `
* First
Some non-list text
* Another list
`
    const expected = `<p>

<ul>
<li>First</li>
</ul>
<p>
Some non-list text
<ul>
<li>Another list</li>
</ul>
<p>
`

    const res = md.markdownToHtml(str)
    assert.equal(res, expected)
  })

  it('mixed test', () => {
    const str = `
*Test*

Some things you need to know:
* First
* Second
`
    const expected = `<p>

<em>Test</em>
<p>
Some things you need to know:
<ul>
<li>First</li>
<li>Second</li>
</ul>
<p>
`
    const res = md.convert(str)
    assert.equal(res, expected)
  })
})
