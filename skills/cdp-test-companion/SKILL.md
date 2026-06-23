---
name: cdp-test-companion
description: Canonical browser-testing workflow for the psynk.ai app — test, debug, investigate, and improve the product through a Chrome DevTools Protocol browser session plus local codebase access. Use when the user wants to manually test or verify a UI flow, starts or references a CDP-enabled browser/remote debugging port, and wants the assistant to propose test scenarios, watch their browser activity, drive browser steps on request, collect console/network/DOM/storage/screenshot evidence, investigate frontend/backend issues in the code, record findings, fix small issues immediately, or delegate larger issues while continuing exploratory testing. Default mode attaches to a browser the user is already driving; it can also bring up a fresh self-driven headless stack (see references/local-stack.md).
---

# CDP Test Companion

## Operating Mode

Act as a product-testing partner, not only as an automation script. Keep the
user in the loop, preserve their ability to drive the browser, and use CDP plus
the local codebases to turn observations into actionable fixes or investigation
records.

Prefer non-destructive exploration. Before clicking controls that create,
update, delete, submit, sign, bill, notify, or otherwise mutate product state,
state what will happen and wait for explicit approval unless the user already
asked for that exact action.

## Start Of Session

There are two entry modes. **Attach mode** (default) connects to a browser the
user is already driving — keep them in the loop and preserve their control.
**Autonomous mode** brings up a fresh headless stack and drives it yourself when
no human is at the keyboard; follow `references/local-stack.md` to launch the
psynk.ai servers and a debugging-port Chromium, then attach over CDP as below.

1. Ask for or confirm the CDP port if the user has not provided it.
2. Discover browser targets:

   ```bash
   curl -s http://127.0.0.1:<port>/json/version
   curl -s http://127.0.0.1:<port>/json/list
   ```

3. Choose the relevant `type: "page"` target. If several page targets exist,
   ask which one to use or infer from URL/title when obvious.
4. Attach to the page target's `webSocketDebuggerUrl`.
5. Run a smoke probe with `Runtime.evaluate` to capture title, URL,
   `document.readyState`, visible text, viewport, local/session storage keys,
   and obvious alert/error text.
6. Identify the app stack from local code before deeper investigation. For this
   repo family, expect `opera` for Rust/Axum backend, `../psynk-ui` for Vite UI,
   and `../psynker` for legacy backend/workflows.

Read `references/cdp-command-patterns.md` when raw CDP command syntax,
one-shot `websocat` probes, or persistent-session tradeoffs are needed.

## Propose Test Scenarios

When the user asks what to test, propose scenarios at the product-workflow
level. Include:

- Preconditions: route, logged-in role/provider, data setup, backend services.
- Steps: concise UI actions the user can perform or ask the assistant to perform.
- Expected signals: visible UI state, API calls, websocket messages, console
  silence/errors, database/backend log implications.
- Risk: whether the scenario mutates state and how to clean up or identify test
  data.

Prefer scenarios that cover real workflows across UI and backend boundaries:
registration, patient detail navigation, legal-status flows, e-sign callbacks,
MAR actions, telehealth/listening, websocket/intercomm behavior, auth/session
expiry, and permission-tag gates.

## Watch Or Drive

If the user drives the browser, periodically inspect:

- Current route and page title.
- Visible headings, alert regions, dialogs, focused element, and key controls.
- Console/runtime errors if available.
- Recent resource timing and relevant API/websocket activity.
- Screenshots when visual state matters.

If asked to drive, use rendered UI interaction first:

- Use `Runtime.evaluate` to list visible controls and bounding boxes.
- Use `Input.dispatchMouseEvent` for clicks.
- Use normal text/keyboard input for forms.
- Verify each step with `Runtime.evaluate`.

Use `Page.navigate` or `history` jumps for setup/restoration, but prefer real
input clicks when validating UI behavior.

## Debugging Workflow

When a test hits a problem:

1. Freeze the observation: URL, route/search params, visible state, screenshot
   if useful, user action that triggered it, and timestamp if relevant.
2. Collect browser evidence: console/log events, failed network calls, response
   status/body snippets, websocket lifecycle, storage keys, selected DOM.
3. Correlate with code:
   - Search frontend routes/components/hooks/API clients in `../psynk-ui`.
   - Search Opera routers/services/repositories in this repo.
   - Search `../psynker` when the workflow still belongs to legacy backend,
     auth, websocket/intercomm, or shared endpoint behavior.
4. Classify the issue:
   - product bug,
   - backend/API contract mismatch,
   - missing data/setup,
   - permission/auth problem,
   - frontend render/state bug,
   - flaky dev environment,
   - unclear expected behavior.
5. Decide with the user whether to fix now, record and continue, or delegate.

For small, localized bugs with clear expected behavior, implement and verify the
fix. For broad or uncertain issues, write an investigation note with evidence
and next steps so testing can continue.

## Recording Findings

Record nontrivial sessions in a repo-local markdown file when the user asks, or
when the investigation produces reusable evidence. Use `docs/plans/` for
runbooks, smoke-test notes, and issue investigations unless the repo has a more
specific location.

Include:

- Browser/CDP setup: port, page URL, target title.
- Scenario and expected behavior.
- Actual behavior with concrete evidence.
- Commands or CDP probes used, summarized rather than dumping huge payloads.
- Code areas inspected.
- Decision: fixed now, delegated, needs product decision, or no issue found.
- Follow-up owner/action if known.

Do not paste sensitive tokens, full localStorage values, PHI-like data beyond
what the local mock/test context requires, or large base64 screenshots.

## Delegation

Use subagents for independent work when helpful: one can inspect frontend code,
another backend code, another docs/history. In Claude Code, reach for `Explore`
for read-only code search across `../psynk-ui`, this repo, and `../psynker`, and
`general-purpose` for parallel implementation research. Keep prompts scoped and
provide raw evidence, not conclusions. Reconcile their findings yourself before
reporting to the user.

Delegate rather than interrupt live testing when:

- the issue needs a larger implementation,
- multiple codebase areas must be researched independently,
- the user wants to keep exploring,
- the evidence is enough for a focused follow-up task.

## Safety And Practical Notes

Treat the CDP port as browser-root access. Keep it on localhost, avoid exposing
it over the network, and prefer throwaway browser profiles for testing.

Raw CDP one-shot commands are good for learning and quick probes. For sustained
sessions, keep one persistent WebSocket session or use Playwright/Puppeteer with
a CDP session so events and domain state are not lost between connections.

Persistent session in Claude Code: a one-shot `websocat -n1` drops every CDP
domain it enabled the moment it exits, so `Network.*`/console/`Performance`
events collected across steps are lost. Hold the session open instead by running
the long-lived websocket (a `websocat` loop or a small Playwright/Python script)
as a background process — `Bash` with `run_in_background: true` — and read its
streamed output across turns. This is also how the autonomous-mode browser and
servers stay alive between steps.

CDP domain state is session-specific. If `Network.enable` or
`Performance.enable` is called on one WebSocket connection, do not assume a new
connection has the same enabled state.

Use `Runtime.evaluate` primarily for observation. Avoid directly mutating React
state, calling internal app functions, or bypassing UI paths unless the user is
explicitly debugging internals and understands the tradeoff.
