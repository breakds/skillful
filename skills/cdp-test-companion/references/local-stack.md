# Bringing Up The Local psynk.ai Stack

The companion workflow normally attaches to a browser the user is already
driving. When instead you need to spin up a fresh, self-driven stack (no human
at the keyboard), use this. It is the autonomous mode: launch both servers plus
a headless Chromium with a debugging port, then attach over CDP as usual.

Prefer a higher-level driver (Playwright/Puppeteer with a CDP session) for the
launch and for multi-step form work — it keeps domain state and console/network
listeners alive across steps, which raw one-shot `websocat` probes lose.

## Components

| Component   | Detail                                                            |
|-------------|-------------------------------------------------------------------|
| Backend     | `python -m psynker.main` on port 9119 (in `../psynker`)           |
| Frontend    | `pnpm dev` on port 5173 (in `../psynk-ui`, needs `direnv exec .`) |
| Browser     | Headless Chromium, CDP port 9222                                  |
| Screenshots | `/tmp/psynk-testing/` (secondary to DOM)                          |
| Staff data  | `../psynker/data/mocks/staffs/*.yaml` (username + password)       |

## Startup

Kill stale processes first, then start each server as a background process
(Bash `run_in_background: true`):

```bash
lsof -ti:9119 | xargs kill -9 2>/dev/null  # backend
lsof -ti:5173 | xargs kill -9 2>/dev/null  # frontend
lsof -ti:9222 | xargs kill -9 2>/dev/null  # browser
```

- Backend: `cd ../psynker && python -m psynker.main`
- Frontend: `cd ../psynk-ui && direnv exec . pnpm dev`
  (`pnpm` only exists inside the psynk-ui nix shell, so `direnv exec .` is
  required.)
- Browser: launch headless Chromium with `--remote-debugging-port=9222`, or a
  Playwright launcher held open in a background process.

Poll readiness with `curl -sf http://localhost:9119/docs` (there is **no**
`/healthz`) and `curl -sf http://localhost:5173` until both respond (~30s
timeout). Vite lazy-compiles on first request, so the first navigation to
`localhost:5173` is slow — wait for network idle plus a known element before
proceeding.

## Login

Read the staff YAMLs to learn available users and roles, then pick by the test's
domain:

- Therapy / clinical notes / prescriptions → Doctor (`elizabeth.carter`, `priya.shah`)
- Nursing / vitals / intake → Nurse (`brick.bentley`, `samuel.lee`)
- Social work / discharge → SocialWorker (`angela.martinez`, `mia.thompson`)
- Intake coordination → IntakeCoordinator (`olivia.martinez`)
- General / unspecified → Doctor (`elizabeth.carter`)

Only ask the user when the choice is genuinely ambiguous.

The login form's labels are `<span>` inside `<label>` without `for` attributes,
so label-based selectors fail. Target by input type:

- username → `input[type='text']`
- password → `input[type='password']`
- submit → the "Sign in with credentials" button

## Local-stack gotchas

- **Vite lazy compile** — first load after launch is slow; wait for idle + a
  known element, not just navigation.
- **"Show only my patients" filter** — the patient list defaults to the
  logged-in doctor's patients only. Toggle it off to see all.
- **Modal overlays** — consent and other dialogs intercept pointer events.
  Interact with the modal first, or force the click.
- **`direnv exec .`** — required to reach `pnpm` for the frontend.
- **Teardown** — always kill ports 9119/5173/9222 and clear
  `/tmp/psynk-testing/`, even on error.
