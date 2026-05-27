# Debug Localhost with Chrome MCP

You are helping me debug a local web app using the `user-chrome-devtools` MCP server.

## Goal

Open a localhost URL, inspect runtime/browser failures, and return a clear root-cause summary with concrete fix suggestions.

## Invocation Inputs

Accept optional free-text input when this command is called:
- Full URL, for example: `http://localhost:5173` or `http://127.0.0.1:8080`
- Port only, for example: `5173` (convert to `http://localhost:5173`)
- Optional extra context after URL/port (what is broken, repro steps, priority area)

## Steps

1. Gather inputs before acting:
   - Parse target from command input:
     - If full URL is provided, use it as-is.
     - If only a numeric port is provided, build `http://localhost:<port>`.
     - If no target is provided, default to `http://localhost:3000`.
   - What to debug first (blank page, API failures, console errors, performance, interaction bug)
   - Repro steps (if any)

2. Validate MCP readiness:
   - Confirm `user-chrome-devtools` tools are available.
   - If the server is unavailable, stop and tell me exactly what to fix first.

3. Open and inspect the app:
   - Open a new page and navigate to the target URL.
   - Wait briefly for page load and dynamic requests.
   - Capture a snapshot/screenshot for context.

4. Collect debugging evidence:
   - Console: list all error/warning messages and key stack frames.
   - Network: list failed/slow requests and inspect details of the most relevant failures.
   - Runtime: evaluate script when needed to inspect app state, globals, or DOM conditions.

5. Reproduce and narrow down:
   - Follow provided repro steps.
   - For each failing behavior, map symptom -> likely source (frontend, backend/API, config, auth, CORS, routing).
   - Avoid repeating the same failed action without new evidence.

6. Provide actionable output:
   - Root cause hypothesis with confidence level.
   - Top 1-3 fixes in priority order.
   - Minimal verification steps to confirm the fix.

## Output

- URL tested
- Key errors (console + network)
- Most likely root cause(s)
- Recommended fixes and verification checklist

## Important Rules

- Be concise and evidence-driven.
- Use MCP tools, not guesses.
- Do not perform destructive actions.
- Ask for missing repro details when needed.
- If localhost is unreachable, report it immediately and stop.
