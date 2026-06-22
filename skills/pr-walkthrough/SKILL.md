---
name: pr-walkthrough
description: >
  Build me merge-confidence on a PR I have checked out locally by collaboratively
  authoring a "visual book" — a single self-contained HTML file that tells the
  story of the problem the PR solves and then explains the change level by level,
  diagram-first, anticipating the questions I'd ask. Not a bug hunt and not a
  back-and-forth transcript: the book is the artifact, and finishing it together
  is how I come to understand the PR. Use when I want to walk through / understand
  / get confidence on a PR or branch before merging, rather than have it reviewed.
---

<what-this-is>

I am the Chief Entropy Officer of this project. I merge a PR only when *I*
understand it well enough to trust it — not when an agent declares it good. The
bottleneck is my own reading speed on large PRs. Your job is to shrink the time
it takes me to reach that confidence threshold.

We reach it by **building a visual book together**: one self-contained HTML file
that fully explains this PR. You author it; I read it in the browser, ask
questions, and steer. The *exercise of completing the book* is what lands the PR
in my head. Even if the PR is perfect, the job is not done until I'm convinced.

This is **not** a code review and **not** a chat transcript. A review hands me a
verdict; a transcript scrolls away. The book is a durable, navigable artifact
that builds my mental model: it tells the problem's story, tours the change in a
teaching order, visualizes data and behavior, and pre-answers the questions I
always end up asking. Bug-hunting is secondary — flag correctness, simplicity,
architecture, readability, test-value, and performance concerns *as they
naturally arise*, but don't run an exhaustive review pass. If I want that, I'll
run `/code-review`.

</what-this-is>

<the-book>

- **One self-contained HTML file** at `.pr-walkthrough/<branch-slug>.html`.
  Copy [template.html](./template.html) to start; it carries the CSS, the CDN
  includes (Mermaid + highlight.js), the callout styles, and the roadmap
  scaffold. Grow it by inserting sections — never rewrite from scratch.
- **`xdg-open` it once Chapter 1 exists**, then tell me to refresh after each
  update. I keep one tab open the whole session.
- **Ensure `.pr-walkthrough/` is git-ignored** (add to `.gitignore` if missing) —
  it's my scratchpad, not a committed artifact.
- **The roadmap chapter (Chapter 0) is the state.** It lists every planned
  section with a status badge (✅ done · ▶ in-progress · ☐ pending), plus open
  questions, fixes made, and delegated tasks. It doubles as the table of
  contents and as the resume point. See [VISUAL-BOOK-FORMAT.md](./VISUAL-BOOK-FORMAT.md)
  for the full anatomy and conventions.

</the-book>

<workflow>

## Phase 0 — Understand the change for real (silent; end with a one-paragraph summary)

Do not write a single line of the book until you genuinely understand the PR.

1. **Pin the change.** The branch is checked out and mapped to a GitHub/Forgejo
   PR. Find the base (usually `main`), then
   `git merge-base HEAD <base>` and `git diff <merge-base>...HEAD` (lead with
   `--stat`). Pull the PR description for intent via `fj pr view <n>` or
   `gh pr view`. If the mapping isn't obvious, ask me — don't guess.

2. **Read past the diff — this is the part the old version got wrong.** A PR is
   usually one piece of a larger system; read until you can place it in that
   system, not just describe its lines:
   - the surrounding code it touches (callers, callees, the types/modules it
     plugs into) and the core abstractions/conventions it leans on;
   - **sibling repos** when the PR depends on a shared library, a protocol/schema
     defined elsewhere, or a contract another repo (backend/frontend) relies on;
   - project docs (ADRs, terminology, design notes) that explain intent.
   Use subagents to research independent areas in parallel (e.g. one on the
   sibling repo, one on the subsystem) so the detail doesn't crowd your context.
   Don't explain code you don't yet understand.

3. **Find the story.** Most PRs exist to solve a *specific problem*. Pin that
   problem down — ideally a concrete example that goes wrong (or is impossible)
   today and works after the PR. That story, not a file list, is the high-level
   understanding I'm after.

4. **Open or resume the book.** If `.pr-walkthrough/<branch-slug>.html` exists,
   read its roadmap chapter, give me a two-line "here's where we are," and
   re-verify the diff hasn't moved (new commits) before trusting old sections.

Report a tight one-paragraph summary of what you found, then proceed to Phase 1.

## Phase 1 — Chapter 1: the problem and how the PR solves it

Create the book with **only Chapter 1** (plus the roadmap), then `xdg-open` it.

Chapter 1 is the backbone. It must:
- **Tell the problem's story first**, with at least one concrete example. Lead
  with a diagram, not paragraphs — the data/flow before and after the change.
- **Weave the high-level pieces into that story** — the new classes, modules,
  operations, data shapes — each introduced as *the thing that solves this part
  of the problem*, with a one-line "what it is." This is the skeleton; the lower
  levels hang off it.
- **Interrogate the high level out loud**, in callouts: Are there too many new
  concepts? Does each earn its place, or is something over-abstracted? What are
  the load-bearing assumptions this design rests on?

Keep it visual and tight. Then write the planned descent into the roadmap (see
Phase 2), `xdg-open` the file, and tell me to refresh. **Stop and wait.**

## Phase 2 — Plan the descent

After Chapter 1, lay out the route through the lower levels in the roadmap
chapter. How many levels depends on the PR's complexity; each level breaks into
**bite-size sections**, one coherent idea apiece (a data model, a hot path, a
tricky algorithm, a cluster of tests). Order can be depth-first, breadth-first,
or mixed — pick whatever teaches best, and make consecutive sections *connect*
(the disjointed jumps were a real failure of the old version: each section
should pick up a thread the last one left). Show me the planned roadmap and let
me reorder before you dive in.

## Phase 3 — Author the book, one section per turn

For each bite-size section, in roadmap order:

1. **Add a new `<section>` to the HTML** (insert above the `SECTIONS-END`
   marker; add a nav entry; flip the roadmap badge to ▶). Visualize first:
   the right Mermaid diagram for the job (sequence for behavior, flowchart for
   control/data flow, class/ER for data models, state for lifecycles), then the
   data model, then the code logic with highlighted excerpts captioned
   `file:line` so I can click through.
2. **Pre-answer my FAQ.** Embed the questions I reliably ask, answered, in a
   "Questions you'd ask" callout: why this approach over the obvious
   alternative, what happens at the edges, why this concept exists, is the
   naming honest, does this test assert a real invariant or just exercise a mock.
   Anticipating these is the whole point — don't make me ask.
3. **Apply my lenses** *where they bite* (don't force all six every section):
   simplicity first — call out over-abstraction, unnecessary concepts, and
   complexity that bleeds out of its local spot; then architecture, readability
   (the naming test: how much else must I read to know what this is?),
   correctness/edge cases, test-value, performance.
4. **`xdg-open` is already up — tell me to refresh, then wait.** I'll ask
   questions or say move on. Handle any problem we find (next section) before
   advancing. Then flip the roadmap badge to ✅ and continue.

**One section per turn. Never author the whole book at once — the pacing is the
product.**

## What marks the walkthrough done

You declare it — not the agent. The skill never auto-flips the roadmap `Status`
to done. When the mechanics below are green, *present them* and ask for my
confidence call; I decide whether we're at threshold.

1. **Every roadmap section is ✅** — none at ☐ or ▶.
2. **Open questions are resolved or explicitly waived by me** — never silently
   dropped. List any I waived.
3. **Delegated tasks are finished and their diffs were given their own section** —
   nothing folded in unreviewed.

Then ask plainly: *"Mechanics are green (or: these N questions are still open) —
are you confident the design and implementation are sound, correct, future-proof,
and free of over-abstraction?"* Only on my explicit yes do you mark it done. The
mechanics can be all-green and the answer can still be "not yet" — then the job
isn't done: go deeper, add context, or re-visualize whatever blocks my confidence.

</workflow>

<handling-problems>

When a section surfaces something worth changing, size it first:

- **Small fix** (rename, a few lines, a local tweak): do it now, show me the
  edit, update the relevant section of the book, keep momentum.

- **Big change** (restructuring, new abstraction, cross-file refactor):
  **plan first, then delegate.** Write a precise change-plan — exactly which
  files/functions change and how — and get my approval. *Then* hand it to a
  subagent (Agent tool) to execute, so the detail doesn't pollute your context
  and I'm not blocked watching. Because I approved the plan, I already know what
  the result should look like, and the book preserves our progress across the
  detour.

Record every fix and delegated task in the roadmap chapter (what, why, status,
and for delegations the approved plan). When a subagent finishes, **add its diff
as its own section** and walk me through it like any other — never silently fold
it in. Then resume the original route; the roadmap is what lets us pick up the
exact spot.

</handling-problems>

<principles>

- Confidence is the goal, not throughput. If I'm not convinced, the section
  isn't done — re-explain, add a diagram, go deeper.
- You are my context engine. The book exists to surface the surrounding and
  sibling-repo context I'd otherwise hunt for — that hunting is the slow part
  you're removing. A book that only restates the diff has failed.
- Visualize by default. Reach for a diagram before a paragraph; I refresh a tab,
  I don't read a transcript.
- I hate complexity most. Over-abstraction and premature optimization are the
  top enemy — every new concept must earn its place, and a name that needs me to
  read five call sites usually signals a bad abstraction, not just a bad label.
  Favor simplicity > readability > correctness > test-value > performance,
  trading performance for simplicity when the gain is marginal.
- Never run ahead. One section, then wait for me to refresh and respond.

</principles>
