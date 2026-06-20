---
name: pr-walkthrough
description: >
  Guide me through a PR I have checked out locally so I reach merge-confidence
  faster. Not a bug hunt — a structured, top-down narrated tour of the changes
  with surrounding context, building my understanding step by step, fixing
  problems in the loop, and tracking progress in a resumable state file. Use
  when I want to walk through / understand / get confidence on a PR or branch
  before merging, rather than have it reviewed for me.
---

<what-this-is>

I am the Chief Entropy Officer of this project. I merge a PR only when *I*
understand it well enough to trust it — not when an agent declares it good. The
bottleneck is my own reading speed on large PRs. Your job is to shrink the time
it takes me to reach that confidence threshold.

This is **not** a code review. A review finds problems and hands me a verdict.
A walkthrough builds *my* mental model of the change: it tours the code in a
sensible order, surfaces the context I'd otherwise have to dig up myself, and
explains every new concept until it's in my head. Even if the PR is perfect, the
job is not done until I'm convinced.

Bug-hunting is secondary. Flag correctness, simplicity, architecture,
readability, test-value, and performance concerns *as they naturally arise in a
step* — but do not run an exhaustive review pass. If I want that, I'll run
`/code-review` separately.

</what-this-is>

<workflow>

## Phase 0 — Setup (do this silently, then report a one-paragraph summary)

1. **Identify the change.** The PR branch is already checked out locally and
   already mapped to a GitHub or Forgejo PR. Determine the base branch
   (usually `main`) and build the diff:
   - `git merge-base HEAD <base>` then `git diff <merge-base>...HEAD` for the
     full changeset (use `--stat` first for the shape).
   - Pull the PR description for intent: try `fj pr view <n>` (Forgejo) or
     `gh pr view` (GitHub). If the mapping isn't obvious, ask me for the PR
     number/URL rather than guessing.

2. **Read for real.** Read the changed files *and* whatever context is needed to
   actually understand them. That starts with the surrounding code the changes
   touch — callers, callees, the types and modules they interact with — but it
   often reaches further: the important parts of *this* project that the change
   leans on (core abstractions, conventions, the subsystem it plugs into), and
   sometimes a **sibling project / repo** when the PR depends on a shared
   library, a protocol/schema defined elsewhere, or a contract another repo
   relies on. The whole point is that the GitHub diff view hides all of this;
   you are the replacement for that context. Follow the threads as far as you
   must, and don't walk me through code you don't yet understand.

3. **Open or resume the state file.** See "Resuming" below. If one already
   exists for this branch, load it and pick up where we left off instead of
   starting over.

## Phase 1 — High-level layout (the warm-up)

Before any line-by-line tour, give me a high-level map so I have somewhere to
hang the details:

- What the PR is trying to accomplish, in my terms (one or two sentences).
- The new concepts it introduces — classes, methods, operations, data shapes,
  files — each with a one-line "what it is". This is the glossary for the tour.
- How the changed files group together (by subsystem / layer / responsibility),
  not just an alphabetical file list.

Write this into the state file. Keep it tight — it's orientation, not the tour.

## Phase 2 — Plan the tour order

The *order* of explanation is where you earn your keep. Decide a route that
flows naturally, generally **top-down**: start at the entrypoint of the new
behavior, then follow the call/data flow into the pieces it depends on.

> "Here's the entrypoint — it does A, B, C. In A it calls `Foo` in the new `D`
> subsystem, which we'll cover in step 4. Let's start at the top."

Turn that route into an ordered list of **steps** in the state file, each step
scoped to one coherent idea (an entrypoint, a subsystem, a tricky algorithm, a
set of tests). Show me the planned route before diving in so I can reorder it.

## Phase 3 — Walk it, one step at a time

For each step, in order:

1. **Show the change with its context.** Show the relevant diff hunks *plus*
   enough surrounding existing code that I don't have to go look it up. Quote
   `file:line` so I can click through.
2. **Explain it.** What it does, why it's here, how it connects to the steps
   before and after. Define any term/concept — pre-existing or
   yet-to-come — that isn't already in my head.
3. **Tie it to what I care about** *when relevant* (don't force all six every
   step): is a new concept earning its place? Does the abstraction's name tell
   me what it is without reading call sites? Is logic where it belongs (SRP)?
   Edge cases? Do the tests assert real invariants or just exercise mocks? Any
   performance cost that bleeds out of its local spot?
4. **Discuss.** Stop and let me ask questions. Then handle any problem we find
   (next section) before moving on.
5. **Mark the step reviewed/approved** in the state file, then move to the next.

**Ask for my go-ahead between steps. One step per turn — never dump the whole
tour at once.** The pacing is the product.

</workflow>

<handling-problems>

When a step surfaces something worth changing, size it first:

- **Small fix** (rename, a few lines, a local tweak): do it in the loop, right
  now, and show me the edit. Keep momentum.

- **Big change** (restructuring, new abstraction, cross-file refactor):
  **plan first, then delegate.** Write a precise change-plan — exactly which
  files/functions change and how — and get my approval on it. *Then* hand it to
  a subagent (via the Agent tool) to execute, so the detail doesn't pollute your
  main context and I'm not blocked watching it work. Crucially, because I
  approved the plan, I already know what the result should look like, and our
  walkthrough progress is preserved in the state file across the detour.

Record every fix and every delegated task in the state file (what, why,
status). When a delegated subagent finishes, briefly walk me through *its* diff
as its own step before we continue — never silently fold it in.

Keep going on the original tour after the detour resolves; the state file is
what lets us resume the exact spot.

</handling-problems>

<state-file>

Maintain one resumable Markdown file per branch so progress survives context
compaction and me stepping away. Use the format in
[WALKTHROUGH-FORMAT.md](./WALKTHROUGH-FORMAT.md).

- **Location:** `.pr-walkthrough/<branch-slug>.md` at the repo root. Ensure
  `.pr-walkthrough/` is git-ignored (add it to `.gitignore` if missing) — this
  is my working scratchpad, not a committed artifact.
- **Update it inline as we go**, not in a batch at the end: tour steps and their
  status, the concept glossary, open questions, fixes made, and delegated tasks.
- **Resuming:** at the start of a session, if the file exists for the current
  branch, read it, give me a two-line "here's where we are" recap, and continue
  from the first unfinished step. Re-verify the diff hasn't moved under us
  (new commits) before trusting old step boundaries.

</state-file>

<principles>

- Confidence is the goal, not throughput. If I'm not convinced, the step isn't
  done — re-explain, add context, or go deeper.
- You are my context engine. Surface the surrounding code I'd otherwise have to
  hunt for; that hunting is the slow part you're removing.
- Favor my priorities, in order: simplicity > readability > correctness >
  test-value > performance, trading performance for simplicity when the gain is
  marginal. New concepts must earn their place; bad names usually signal a bad
  abstraction, not just a bad label.
- Never run ahead. One step, then wait.

</principles>
