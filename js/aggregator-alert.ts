/*
 * This is a snippet that I made on val.town to test it out when I was considering a job there.
 * It tells me when one of my sites appears on either HackerNews or Lobste.rs
 *
 * As of this writing, it still works (to Val's credit!). I would like to port this to a self-hosted
 * solution, though.
 */
import { fetch } from "https://esm.town/v/std/fetch";
import { email, IAddress } from "https://esm.town/v/std/email";
import { DOMParser, Element } from "jsr:@b-fuze/deno-dom";

const WATCHED_HOSTS = new Set([
  'alexanderpetros.com',
  'unplannedobsolescence.com',
  'thefloatingcontinent.com',
  'wemakeinter.net',
])

export default async function (interval: Interval) {

  const matchedStories = []
  await checkHN(matchedStories)
  await checkLobsters(matchedStories)

  if (matchedStories.length < 1) {
    return new Response("None found");
  }

  const html = `
<p>
One (or more) of your posts was spotted on the aggregators:

<ul>
${matchedStories.map(story => `<li>
  <a href="${story.story_url}">${story.title}</a> - ${story.host}
  (<a href="${story.agg_url}">${story.agg_name} comments</a>)`)}
</ul>
-
  `
  const from: IAddress = { email: 'alexpetros.bots@valtown.email', name: 'ValBot'}
  await email({ subject: "Aggregator Sightings", from, html });
  return new Response("Found");
}

async function checkHN(matchedStories) {
  // Get the title of the top story on Hacker News
  const res = await fetch("https://hacker-news.firebaseio.com/v0/topstories.json")
  const topStories = await res.json()
  const frontPage = topStories.slice(0, 50)

  const promises = frontPage.map(async storyId => {
    const res = await fetch(`https://hacker-news.firebaseio.com/v0/item/${storyId}.json`)
    const story = await res.json()
    try {
      const host = (new URL(story.url)).host
      const agg_url = `https://news.ycombinator.com/item?id=${story.id}`
      const matchedStory = {  story_url: story.url,  title: story.title, host, agg_url, agg_name: 'HN'  }
      if (WATCHED_HOSTS.has(host)) matchedStories.push(matchedStory)
    } catch {} // Ignore unparseable URLs
  })

  await Promise.all(promises)
}

async function checkLobsters(matchedStories) {
  const res = await fetch(`https://lobste.rs`)
  const text = await res.text()

  const dom = new DOMParser().parseFromString(text, "text/html")

  const stories =  dom.querySelectorAll('li.story')
  for (const story of stories) {
    const link = story.querySelector('a.u-url')
    try {
      const url = new URL(link.getAttribute("href"))
      const host = url.host
      const title = link.innerText

      const agg_local = story.querySelector('.comments_label a').getAttribute("href")
      const agg_url = `https://lobste.rs` + agg_local

      const matchedStory = { story_url: url.href,  title, host, agg_url, agg_name: 'Lobsters'  }
      if (WATCHED_HOSTS.has(host)) matchedStories.push(matchedStory)
    } catch {} // Ignore invalid URLs

  }

}
