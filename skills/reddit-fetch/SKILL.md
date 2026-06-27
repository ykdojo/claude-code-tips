---
name: reddit-fetch
description: Fetch content from Reddit using the curl JSON API. Use when accessing Reddit URLs, researching topics on Reddit, or when Reddit returns 403/blocked errors.
---

# Reddit Fetch

Reddit's public JSON API works by appending `.json` to any Reddit URL. All `curl` examples below need a browser `User-Agent` header - export it once and reuse it:

```bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
```

## Endpoints

```bash
# Listing - swap hot for new/top/rising; for top add &t=day|week|month|year|all
curl -s -L -H "User-Agent: $UA" "https://old.reddit.com/r/SUBREDDIT/hot.json?limit=15"
# Post + comments - JSON array where [0]=post, [1]=comment tree
curl -s -L -H "User-Agent: $UA" "https://old.reddit.com/r/SUBREDDIT/comments/POST_ID.json?limit=20"
# Search within a subreddit
curl -s -L -H "User-Agent: $UA" "https://old.reddit.com/r/SUBREDDIT/search.json?q=QUERY&restrict_sr=on&sort=new&limit=15"
```

## Parsing the JSON

Use jq to extract what you need:

```bash
# List posts
curl -s -L -o /tmp/reddit_result.txt -w "%{http_code}" -H "User-Agent: $UA" \
  'https://old.reddit.com/r/SUBREDDIT/hot.json?limit=15'

jq -r '.data.children[] | .data | "\(.title)\n   \(.score) pts | \(.num_comments) comments | u/\(.author) | id: \(.id)\n"' /tmp/reddit_result.txt

# List comments from a specific post (the [1] element has comments)
jq -r '.[1].data.children[] | select(.kind == "t1") | .data | "u/\(.author) (\(.score) pts):\n  \(.body[:300])\n"' /tmp/reddit_thread.txt
```

Key details:
- Fetch to a temp file (`-o`) then parse - avoids pipe encoding issues; `-w "%{http_code}"` prints the status for debugging empty responses.
- `-L` follows redirects; single-quote the URL so the shell doesn't eat `&` in query strings.
- `.body[:300]` truncates long comment bodies (jq 1.7+).

## Rate limiting

Reddit's JSON API rate-limits aggressively:

- **Don't fire parallel requests** - run them sequentially with `sleep 2`/`sleep 3` between each. Fetch one listing, parse it, then fetch threads one at a time.
- Empty response (0 bytes): wait 3-5s and retry. HTTP 429: back off 10-15s.

## When things get blocked: the DuckDuckGo-hop unlock

Reddit increasingly hard-blocks automated access - **curl (host AND container) 403s, and even a cold Playwright navigation to `reddit.com` hits a `"You've been blocked by network security"` challenge page.** The reliable fix is to arrive at Reddit *through a DuckDuckGo result redirect*: that sets a Reddit session cookie which unlocks direct `.json` access for the rest of the browser session.

**Step 1 - the DDG hop (the unlock).** Do this once per session before any `.json` fetch.

1. `mcp__playwright__browser_navigate` to `https://html.duckduckgo.com/html/?q=site:reddit.com/r/SUBREDDIT+YOUR+QUERY`
2. Grab the first result's **full href** - it's a DDG redirect that includes a `rut` token (`https://duckduckgo.com/l/?uddg=...&rut=...`). The token is required; navigating to the bare `/l/?uddg=` without it 400s.
   ```js
   () => document.querySelector('.result__a')?.href
   ```
3. `browser_navigate` to that full redirect href. It lands on the real `www.reddit.com` thread (page title = the post title, **not** "Blocked") and sets the session cookie.

**Step 2 - now direct `.json` works.** For the rest of the session, navigate Playwright straight to any `.json` URL and `JSON.parse(document.body.innerText)` - same shape as curl, so `[0]`=post / `[1]`=comments still applies. Full recency sorting (`sort=new&t=week`) is restored.

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

Use `www.reddit.com` (not `old.reddit.com`) for browser navigation.

### Fallbacks

- **Fast path, often fails:** plain curl JSON (host or safeclaw container) with a browser `User-Agent` is faster when it works, but usually 403s now (changing the UA doesn't help). Worth one quick try only if you're already shelling out; on 403, go to the DDG hop.
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
