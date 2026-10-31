# Writing Style

- Use sentence case for headers, not title case
- Never use em dashes (—). Use spaced hyphens ` - ` (space, hyphen, space) instead.
- Don't make up or add content I didn't say. Stick to what I've said. Rephrasing is okay, but don't embellish.

# About Me

- Name: YK
- GitHub: ykdojo
- Current year: 2026 (focus your research on the past three months)

# Behavior

Respond concisely. Lead with the answer or a recommendation, not a menu of options. Don't restate my question, recap work I can already see, append "one note" asides, or raise topics I didn't ask about. Aim for under ~100 words by default: lead with the key facts, then use short bullet points instead of a paragraph per point. Expand only when I ask for depth or the task genuinely needs it.

Double-check before claiming something as fact. Don't state things confidently without a source - if you can't verify it, say so or go verify it first. Trust verified evidence over a single conflicting source.

When I paste large content with no instructions, just summarize it.

# Git

- Run commit and push as **separate** commands, never chained (`git commit && git push`). Auto mode may reject the push, and a chained command makes the rejection kill the commit too. Commit first so it always lands, then push as its own step (which I can approve separately).

# Publishing to npm

My npm account has 2FA set to `auth-and-writes`, so `npm publish` requires 2FA. The web login (`npm login --auth-type=web`) signs in but does NOT satisfy publish-time 2FA, and `npm publish` then fails with a 403.

Reliable path - use a Classic Automation token (they bypass 2FA):
1. npmjs.com - Access Tokens - Generate New Token - Classic Token - type Automation - Generate.
2. Publish from the package dir: `npm publish --//registry.npmjs.org/:_authToken=npm_...`
3. Revoke the token afterward.

Avoid Granular Access Tokens for this - they are fiddly: they error if org permissions are set without selecting an org (I have no orgs), and a brand-new unscoped package can't be individually selected, so it needs "All packages".

Before publishing: `npm publish --dry-run` to confirm the file list, and gitignore generated artifacts so they don't ship.

# AWS deployment security

Never expose Swagger UI, OpenAPI docs, or an admin UI directly on a public ALB/ELB. A real stack got flagged by an AWS security scan (`DyePack.ExposedSwaggerUI`) because the LiteLLM gateway's internet-facing ALB served Swagger UI on its raw IPs over 80/443, even with CloudFront in front.

Check before every deploy (`deploy.sh`, `cdk deploy`, `terraform apply`, CloudFormation, `sam deploy`):
- Public ALBs are reachable only through CloudFront: security group ingress from the CloudFront managed prefix list (`com.amazonaws.global.cloudfront.origin-facing`), never `0.0.0.0/0`, plus a secret origin header and a fixed 403 as the default action.
- Audit listener rules that skip the header check (health check exceptions etc.). They must never match `/` or docs paths - many apps serve Swagger UI at `/`. That exact rule caused the incident above.
- Disable docs and admin pages in deployed stacks (`/docs`, `/redoc`, `/openapi.json`; e.g. LiteLLM `DISABLE_SWAGGER_PAGE="true"`, `DISABLE_ADMIN_UI="true"`).
- After deploy, curl the ALB DNS name and public IPs on 80/443 for `/`, `/docs`, `/redoc`, `/openapi.json`. Each must be refused, while the CloudFront URL works.
- If a template defaults to a public load balancer with docs enabled, stop and flag it before deploying.

## Containers

Use [safeclaw](https://github.com/ykdojo/safeclaw) containers (local: `/Users/yk/Desktop/projects/safeclaw`). Containers are named `safeclaw-<session-name>` (e.g., `safeclaw-work`, `safeclaw-research`).

To list running safeclaw containers: `docker ps --filter "name=safeclaw-"`

To create a new container: `cd /Users/yk/Desktop/projects/safeclaw && ./scripts/run.sh -s <name> -n`

For read-only `gh` API calls on public repos, use a running safeclaw container: `docker exec safeclaw-<name> bash -c 'gh api <endpoint>'`. If container `gh` lacks permissions, fall back to host `gh`.

## URL Fetching

Always fetch individual URLs through a safeclaw container:
`docker exec safeclaw-<name> curl -sL <url>`

If the page is JavaScript-heavy (curl returns minimal or empty content), use Playwright instead (safeclaw containers have Playwright installed).

## Tmux

For interactive Claude Code sessions:

```bash
tmux new-session -d -s <name> '<command>'
tmux send-keys -t <name> '<input>' Enter  # don't forget Enter!
tmux capture-pane -t <name> -p
```

Note: For Claude Code sessions, you may need to send Enter again after a short delay to ensure the prompt is submitted.

## Long-running Jobs

If you need to wait for a long-running job, use sleep commands with manual exponential backoff: wait 1 minute, then 2 minutes, then 4 minutes, and so on.

# Claude for Chrome

- Use `read_page` to get element refs from the accessibility tree
- Use `find` to locate elements by description
- Click/interact using `ref`, not coordinates
- NEVER take screenshots unless explicitly requested by the user