/**
 * Tiny subset of Markdown implemented with regex.
 * Author: Alexander Petros
 *
 * I wanted a way to let the users add links and bold text to the tournament
 * description, but didn't want to deal with escaping for XSS scripting.
 *
 * This ended up becoming a half-featured regex-based markdown parser. Currently
 * it supports links (only absolute ones, as a user-simplicity measure), bold, italics,
 * unordered lists with a single indent, and new paragraphs.
 *
 * I might add some more stuff as I need it, but this is pretty good for the thing
 * I wanted, which is a text box that felt customizable, within limits.
 */
import { escapeHtmlText } from './escape-html.js'

export function markdownToHtml(str) {
  const rules = [
    // if a url matches the escaped version of https://
    // then return the URL with JUST the forward slashes unescaped
    [/\[([^\n]+)\]\((https?:&#x2F;&#x2F;[^\n]+)\)/gm, (_match, p1, p2) => {
      const unescapedUrl = p2.replace(/&#x2F;/g, '/')
      return `<a href="${unescapedUrl}">${p1}</a>`
    }],
    // same as above but the unescaped version
    [/\[([^\n]+)\]\((https?:\/\/[^\n]+)\)/g, (_match, p1, p2) => {
      return `<a href="${p2}">${p1}</a>`
    }],
    // if a newline starts with a bullet and a space, make it a list item
    // note the /m option at the end, which means to use ^ and $ as line-delimiting,
    // not string-delimiting markers
    [/^\* (.*)$/gm, (_match, p1) => {
      return `<li>${p1}</li>`
    }],
    // wrap all the consecutive <li>s in a <ul>
    // Because <ul>s end paragraphs, start a new one after
    [/(<li>[^\n]*<\/li>(?:\n|$))+/g, (match) => {
      return `<ul>\n${match}</ul>\n<p>\n`
    }],
    // wrap bold and italic characters
    [/\*\*([^\n]+)\*\*/g, '<b>$1</b>'],
    [/\*([^\n]+)\*/g, '<em>$1</em>'],
    [/\n\n/gm, '\n<p>\n']
  ]

  // Do the escaping
  let html = str
  rules.forEach(([regex, replacement]) => {
    html = html.replace(regex, replacement)
  })

  return '<p>\n' + html
}

// Convert unsafe markdown text to escaped, formatted HTML
export const convert = (str) => markdownToHtml(escapeHtmlText(str))
