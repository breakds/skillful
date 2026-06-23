# CDP Command Patterns

Use these patterns when working directly with a Chrome DevTools Protocol page
target. Replace `<port>` and `<page-websocket-url>` with values from
`/json/list`.

## Discover

```bash
curl -s http://127.0.0.1:<port>/json/version
curl -s http://127.0.0.1:<port>/json/list
```

Choose a `type: "page"` target and use its `webSocketDebuggerUrl`.

## Smoke Probe

```bash
printf '%s\n' \
  '{"id":1,"method":"Runtime.evaluate","params":{"expression":"(() => ({ title: document.title, url: location.href, readyState: document.readyState, viewport: { width: innerWidth, height: innerHeight, dpr: devicePixelRatio }, text: document.body.innerText.slice(0, 600), localStorageKeys: Object.keys(localStorage), sessionStorageKeys: Object.keys(sessionStorage), alerts: Array.from(document.querySelectorAll(\"[role=alert], .error, .text-error, [data-error]\")).map(e => e.innerText || e.textContent || e.outerHTML).slice(0, 20) }))()","returnByValue":true}}' \
  | websocat -n1 --buffer-size 1048576 <page-websocket-url>
```

## List Visible Controls

```bash
printf '%s\n' \
  '{"id":2,"method":"Runtime.evaluate","params":{"expression":"(() => Array.from(document.querySelectorAll(\"a,button,ds-button,input,select,textarea,[role=button],[tabindex]\")).map((e, i) => { const r = e.getBoundingClientRect(); return { i, tag: e.tagName, role: e.getAttribute(\"role\"), type: e.getAttribute(\"type\"), text: (e.innerText || e.getAttribute(\"aria-label\") || e.getAttribute(\"placeholder\") || e.title || e.getAttribute(\"href\") || \"\").trim().slice(0, 100), href: e.getAttribute(\"href\"), x: Math.round(r.x), y: Math.round(r.y), w: Math.round(r.width), h: Math.round(r.height), visible: r.width > 0 && r.height > 0 && getComputedStyle(e).visibility !== \"hidden\" && getComputedStyle(e).display !== \"none\" }; }).filter(x => x.visible).slice(0, 120))()","returnByValue":true}}' \
  | websocat -n1 --buffer-size 1048576 <page-websocket-url>
```

## Click A Rendered Coordinate

```bash
printf '%s\n' \
  '{"id":10,"method":"Input.dispatchMouseEvent","params":{"type":"mouseMoved","x":116,"y":125,"button":"none"}}' \
  '{"id":11,"method":"Input.dispatchMouseEvent","params":{"type":"mousePressed","x":116,"y":125,"button":"left","clickCount":1}}' \
  '{"id":12,"method":"Input.dispatchMouseEvent","params":{"type":"mouseReleased","x":116,"y":125,"button":"left","clickCount":1}}' \
  | websocat --max-messages-rev 3 --buffer-size 1048576 <page-websocket-url>
```

Verify the result afterward with a separate route/text probe. Some one-shot
`websocat` invocations print only the first acknowledgement even when Chrome
receives all messages.

## Type Text

Focus the field with a click, then insert text:

```bash
printf '%s\n' \
  '{"id":20,"method":"Input.insertText","params":{"text":"Avery"}}' \
  | websocat -n1 --buffer-size 1048576 <page-websocket-url>
```

Specialized controls such as date inputs may not accept `Input.insertText` as a
human would. Prefer normal keyboard events or a higher-level driver when form
fidelity matters.

## Navigation History

```bash
printf '%s\n' \
  '{"id":30,"method":"Page.getNavigationHistory"}' \
  | websocat -n1 --buffer-size 1048576 <page-websocket-url>
```

```bash
printf '%s\n' \
  '{"id":31,"method":"Page.navigateToHistoryEntry","params":{"entryId":48}}' \
  | websocat -n1 --buffer-size 1048576 <page-websocket-url>
```

## Screenshot

```bash
printf '%s\n' \
  '{"id":40,"method":"Page.captureScreenshot","params":{"format":"jpeg","quality":35}}' \
  | websocat -n1 --buffer-size 10485760 <page-websocket-url> \
  | jq -r '{id, base64Length: (.result.data | length)}'
```

To save the screenshot, decode `.result.data` to a file (e.g. under
`/tmp/psynk-testing/`). Do not paste large base64 payloads into chat or markdown
notes. In Claude Code, `Read` the saved image file to actually view it — the
Read tool renders images, so the screenshot becomes usable visual evidence
rather than an opaque blob.

## Resource Timing

```bash
printf '%s\n' \
  '{"id":50,"method":"Runtime.evaluate","params":{"expression":"performance.getEntriesByType(\"resource\").slice(-40).map(r => ({ name: r.name, type: r.initiatorType, duration: Math.round(r.duration), transferSize: r.transferSize, decodedBodySize: r.decodedBodySize, responseStatus: r.responseStatus || null }))","returnByValue":true}}' \
  | websocat -n1 --buffer-size 1048576 <page-websocket-url>
```

Resource timing is not a full substitute for the `Network` domain; it is a quick
page-visible summary. Use a persistent CDP session with `Network.enable` for
complete request/response evidence.

## Persistent Sessions

One-shot shell commands are useful for quick checks, but CDP domain state is
per session. Keep a persistent WebSocket or use Playwright/Puppeteer when:

- collecting `Network.*` events,
- collecting console/log events,
- waiting for asynchronous app behavior,
- driving multi-step form workflows,
- preserving `Performance.enable` or similar domain state.
