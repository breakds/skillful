# Walkthrough state file format

One file per branch at `.pr-walkthrough/<branch-slug>.md`. It is the resumable
record of a PR walkthrough: where we are, what's been understood, what's still
open. Keep it terse and current — update it inline as the tour progresses, never
in a single batch at the end.

```markdown
# Walkthrough: <branch-name>

- PR: <link or "owner/repo #123"> (<github|forgejo>)
- Base: <base-branch> @ <merge-base-sha>
- Tip: <head-sha>          # update if new commits land mid-walkthrough
- Status: in-progress | done
- Updated: <YYYY-MM-DD>

## What this PR does

<one or two sentences, in my terms>

## Concept glossary

New things this PR introduces (the orientation map):

- `Name` — one-line what-it-is. (`file:line`)
- ...

## Tour

Ordered steps. Mark status as we go: ☐ pending · ▶ in-progress · ✅ approved.

1. ✅ <step title> — <files/symbols covered>
   - notes / what I needed to know
2. ▶ <step title> — <files/symbols>
3. ☐ <step title> — ...

## Open questions

- [ ] <question raised but not yet resolved, with the step it came from>

## Fixes made in the loop

- <what changed, why> (`file:line`) — step N

## Delegated tasks

- <task> → subagent — status: planned | approved | running | done
  - approved plan: <one-line of what the result should look like>
  - result reviewed in step: <N>
```

## Conventions

- **Status symbols** keep the tour scannable on resume; the first non-✅ step is
  where we continue.
- **Open questions** are the backlog — nothing reaches `done` with these unchecked
  unless I explicitly waive them.
- **Delegated tasks** record the *approved plan* so that when the subagent
  returns, I can check the result against what I signed off on.
- Refresh `Tip` and re-check step boundaries whenever new commits land on the
  branch during the walkthrough.
