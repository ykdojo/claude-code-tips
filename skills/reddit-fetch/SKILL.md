---
name: reddit-fetch
description: Fetch content from Reddit via its JSON API using a browser session (DuckDuckGo-hop unlock). Use when accessing Reddit URLs, researching topics on Reddit, or when Reddit returns 403/blocked errors.
---

# Reddit Fetch

Reddit's public JSON API works by appending `.json` to any Reddit URL — but Reddit now hard-blocks automated access. **curl 403s essentially every time (host AND container, regardless of User-Agent), and even a cold Playwright navigation to `reddit.com` hits a `"You've been blocked by network security"` challenge page.** The reliable method is to arrive at Reddit *through a DuckDuckGo result redirect*: that sets a Reddit session cookie which unlocks direct `.json` access for the rest of the browser session.

## Primary method: the DuckDuckGo-hop unlock

**Step 1 - the DDG hop.** Do this once per session before any `.json` fetch.

1. `mcp__playwright__browser_navigate` to `https://html.duckduckgo.com/html/?q=site:reddit.com/r/SUBREDDIT+YOUR+QUERY`
2. Grab the first result's **full href** - it's a DDG redirect that includes a `rut` token (`https://duckduckgo.com/l/?uddg=...&rut=...`). The token is required; navigating to the bare `/l/?uddg=` without it 400s.
   ```js
   () => document.querySelector('.result__a')?.href
   ```
3. `browser_navigate` to that full redirect href. It lands on a real `www.reddit.com` page (title = the post/subreddit title, **not** "Blocked") and sets the session cookie. The result doesn't have to be the exact thread you want - landing on *any* real Reddit page sets the cookie.

If Playwright errors with `Browser is already in use`, a stale instance is holding the profile - `pkill -f ms-playwright-mcp` (or the profile dir named in the error) and retry.

**Step 2 - direct `.json` now works.** For the rest of the session, navigate Playwright straight to any `.json` URL and `JSON.parse(document.body.innerText)`. Use `www.reddit.com` (not `old.reddit.com`) for browser navigation. Full recency sorting (`sort=new&t=week`) is available.

1. `browser_navigate` to e.g. `https://www.reddit.com/r/SUBREDDIT/search.json?q=QUERY&restrict_sr=on&sort=new&t=week&limit=25`
2. `browser_evaluate`, **always wrapped in try/catch** (return `document.body.innerText.slice(0,200)` on failure so you can see a challenge page if the session lapsed - just re-do the hop):
   ```js
   () => {
     try {
       const data = JSON.parse(document.body.innerText);
       return data.data.children.map(c => ({
         t: c.data.title, s: c.data.score, n: c.data.num_comments, id: c.data.id
       }));
     } catch (e) { return document.body.innerText.slice(0, 200); }
   }
   ```
3. For a thread, navigate to `.../comments/POST_ID.json?limit=30&sort=top` and parse `data[0]` (post) and `data[1].data.children` (comments).

## JSON shapes (same for browser and curl)

```text
# Listing - swap hot for new/top/rising; for top add &t=day|week|month|year|all
/r/SUBREDDIT/hot.json?limit=15
# Post + comments - JSON array where [0]=post, [1]=comment tree
/r/SUBREDDIT/comments/POST_ID.json?limit=20
# Search within a subreddit
/r/SUBREDDIT/search.json?q=QUERY&restrict_sr=on&sort=new&limit=15
```

- Listings: `.data.children[].data` has `title`, `score`, `num_comments`, `author`, `id`.
- Threads: `[0].data.children[0].data` is the post; `[1].data.children[]` (filter `kind == "t1"`) are comments with `author`, `score`, `body`, and nested `replies` of the same shape.
- Truncate long comment bodies (e.g. `body.slice(0, 300)` in JS, `.body[:300]` in jq 1.7+) to keep output readable.

## Fallbacks

- **More comments per thread:** load the rendered thread page (after the hop) and scrape the `shreddit` DOM - it returns more comments than `.json?limit=`:
  ```js
  () => ({
    title: document.querySelector('shreddit-post')?.getAttribute('post-title'),
    comments: [...document.querySelectorAll('shreddit-comment')].map(c => ({
      author: c.getAttribute('author'),
      score:  c.getAttribute('score'),
      text:   c.querySelector('.md')?.innerText
    }))
  })
  ```
- **No Playwright at all:** use Claude for Chrome to open the thread / `.json` URL and read it off the page.
- **curl (last resort, expect 403):** direct curl with a browser User-Agent used to work and is faster when it does, but it now gets 403'd essentially always - changing the UA doesn't help. Only worth a single quick try if you're already shelling out and a browser isn't available; on 403, go straight to the DDG hop.
  ```bash
  UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
  curl -s -L -o /tmp/reddit_result.txt -w "%{http_code}" -H "User-Agent: $UA" \
    'https://old.reddit.com/r/SUBREDDIT/hot.json?limit=15'
  jq -r '.data.children[] | .data | "\(.title)\n   \(.score) pts | \(.num_comments) comments | u/\(.author) | id: \(.id)\n"' /tmp/reddit_result.txt
  ```
  Fetch to a temp file (`-o`) then parse; `-w "%{http_code}"` prints the status; `-L` follows redirects; single-quote the URL so the shell doesn't eat `&`.

## Rate limiting

Reddit rate-limits aggressively even once you're unblocked:

- **Don't fire parallel requests** - run them sequentially with `sleep 2`/`sleep 3` (or brief pauses between navigations). Fetch one listing, parse it, then fetch threads one at a time.
- Empty response (0 bytes): wait 3-5s and retry. HTTP 429: back off 10-15s. A challenge page mid-session means the cookie lapsed - re-do the DDG hop.
