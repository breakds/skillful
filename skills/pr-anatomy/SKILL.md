---
name: pr-anatomy
description: >
  Use when the user wants to understand a PR well enough to decide on it themselves - given a
  local branch, a PR number, or a URL - and asks to explain, walk through, break down, or make
  sense of a PR or a series of PRs, or to build confidence before deciding on one. Not for when
  they ask for a code review, a verdict, or an approve/request-changes recommendation.
---

<what-this-is>

I am deciding on a PR. The product of this skill is **my understanding**, not your
assessment. You are not the reviewer; I am. Your job is to get what I need into my
head fast enough that I can make the call myself - on each finding, and then on the
PR.

So the bar for everything you write is: **did I understand it?** Not whether it
was accurate, thorough, or expert-sounding. A correct sentence I have to read three
times has failed. If I say I don't follow something, that is a defect in your
explanation, not in my attention.

This is not a code review. A review hands me a verdict; I want the material to reach
my own.

</what-this-is>

<pinning-the-pr>

I will give you a checked-out branch, a PR number, or a URL - possibly several.

- **Branch**: base is usually `main`. `git merge-base HEAD main`, then
  `git diff <merge-base>...HEAD` (lead with `--stat`).
- **Number or URL**: pull the title, description, and diff with the forge CLI for
  that repo (`gh pr view <n>` / `gh pr diff <n>`, or `fj` where that is the forge).
  Fetch the branch locally too when you need to read the code around the change -
  you almost always will.
- **A series**: treat it as one change with one story. Level 1 and 2 cover the whole
  series; Level 3 walks the PRs in order, saying what each one adds.

If anything is ambiguous - which repo, which base, which PRs belong to the series -
ask me. Do not guess.

</pinning-the-pr>

<ground-yourself-first>

Survey the codebase before you write a word.

**Never describe code you have not opened.** Every claim about how things work today
must come from a file you actually read, and you should be able to paste the real
lines to prove it. "Presumably", "likely", "should be" about existing behavior mean you have not
looked yet - go look. If something is still unknown after looking, write that in the
artifact in those words. An honest gap is fine; a confident guess is not.

Read the callers and callees, the types and modules the change plugs into, the
conventions it follows or breaks, and the project docs (design notes, terminology,
ADRs) that explain intent. When the reading is large, put independent areas on
parallel subagents so the detail does not crowd you out.

Then find the story: the specific thing that is wrong or impossible today and works
after this PR. If you cannot state that in two sentences with a concrete example, you
do not understand the PR yet - keep reading.

</ground-yourself-first>

<the-four-levels>

Write all four levels in one pass into one artifact. The order matters: each level is
only worth reading if the one above it holds up.

**Level 1 - the goal.** What problem does this solve, for whom, and why is it worth
solving? For a bug: what goes wrong, concretely. For a feature: what can a user not
do today. State the goal in one sentence, then make it real with an example. Then
judge it - is this goal valid? If the goal does not hold, everything below is moot,
and that belongs at the top of the artifact.

**Level 2 - the design.** How does the change achieve the goal? Explain the shape of
the solution - the pieces, what each one is, how they fit - introducing each as *the
thing that solves this part of the problem*. Then judge it on two questions: does it
actually achieve the goal, and what does it cost me to hold in my head? Count the new
concepts and terms it introduces. Anything you struggle to explain simply is a design
problem - say so out loud instead of papering over it with a better paragraph.

Levels 1 and 2 are the gate. If either fails, keep 3 and 4 short: the decision at
stake is the design, and detail underneath a broken design is wasted reading. Say
plainly at the top that this is why they are thin.

**Level 3 - the implementation.** The strategy, not a tour of the diff. Teach in an
order - start where the change enters the system and follow it through - never file
by file. I need enough to be confident I know what the code does, not every line. For
the few places that carry the weight, **put the real code on the page** - see
<show-the-code>. Call out complexity that is not obviously necessary, and complexity
that leaks out of the one spot it should live in.

**Level 4 - the findings.** Everything I might want to act on. See <findings>.

</the-four-levels>

<findings>

Each finding gets a stable identifier so I can say "B2" in follow-up and we both know
what I mean.

- Unrelated findings: `A`, `B`, `C`.
- Related findings share a group: `A1`, `A2` under a named group `A`.
- **Identifiers never change** once written, even after we resolve or drop one. New
  findings take new letters.

Each finding needs, briefly:

1. **What** - the claim in one plain sentence.
2. **The code** - the offending lines, embedded, per <show-the-code>. I should be able
   to see the problem without opening anything.
3. **What goes wrong** - a concrete scenario: this input, this state, this wrong
   result. If you cannot write that scenario, you have a hunch, not a finding. Either
   dig until it is concrete, or label it "worth checking" and say what would settle
   it.
4. **How sure you are**, and what would make you sure.
5. **The decision I am making** - my options (fix now / accept / follow up later) and
   what each costs.

Cover correctness, bugs, missed edge cases, performance, unnecessary complexity, and
tests that do not earn their keep. Order them by how much they would change my
decision.

Do not score the PR, do not recommend approve or request-changes, and do not tell me
what you would do unless I ask.

Findings I do not want: style nits, "consider adding a test" without naming the
invariant it would guard, and restatements of what the diff obviously does.

</findings>

<how-to-explain>

I will actually read this, so write it to be read.

- **Plain English.** Short sentences, concrete nouns. **No jargon** - no
  "load-bearing", "seam", "surface area", "primitive", no vague "contract". The test:
  if I would have to ask "what do you mean by that word", cut it. Terms that come
  from the codebase are fine - define each one in a sentence the first time it
  appears.
- **Examples over description.** Walk one real trip through the code with real-ish
  values. Never real patient data - use obviously fake values (see CLAUDE.md, HIPAA).
- **Illustrate when it beats prose.** Sequence diagrams for behavior over time,
  flowcharts for control and data flow, ER or class diagrams for data shapes, state
  diagrams for lifecycles, before/after tables for comparisons. A diagram that only
  restates the sentence beside it is noise - cut it.
- **Show the code, don't cite it.** See <show-the-code>.
- **Length is not a constraint.** Take the room the change needs - I would rather read
  three screens that land than half a screen that leaves me guessing. But the length
  has to come from the PR and not from you: padding, hedging, and saying the same
  thing twice are still cuts. And when a level runs long because the design has that
  many moving parts, the length is itself a finding - say that in Level 2 instead of
  just writing more.

</how-to-explain>

<show-the-code>

**Never make me go and find the code. Put it in the artifact.**

A `file:line` reference is a chore: it makes me leave the page, open the file, and
rebuild the context you already had in front of you. Paste the real lines in instead,
with the location as a caption above them so I know where I am.

- **Copy, never retype.** Read the file and paste what is actually there. Code you
  reconstructed from memory is a lie in a monospace font.
- **Trim to what matters.** Cut the parts that are not the point and mark the cuts
  with `# ...`. Keep enough around the lines - the enclosing function signature, the
  variable that was set two lines up - that the excerpt reads on its own.
- **Show before and after for edits.** The new code alone does not tell me what
  changed; two short blocks side by side, or a marked-up diff, does.
- **Prefer the excerpt over the whole file.** If a block is long enough that I have to
  scroll it, you have not decided which part carries the weight - decide, and cut.
- This applies everywhere: the design level when a type or signature is the clearest
  statement of the shape, the implementation level, and every finding.

</show-the-code>

<the-artifact>

One self-contained HTML file at `$HOME/.cache/pr-anatomy/<repo>-pr-<n>.html`, or
`<repo>-<branch-slug>.html` when there is no number. `mkdir -p` the directory. Start
from [template.html](./template.html) and fill in its sections.

Open it with `xdg-open` when `$DISPLAY` or `$WAYLAND_DISPLAY` is set; otherwise print
the path for me. I keep one tab open for the whole session - after every update, tell
me to refresh.

</the-artifact>

<the-discussion-loop>

Delivering the artifact is the middle, not the end. I read it and come back with
questions, usually by identifier.

- Answer in chat, then **fold the answer back into the artifact** where it belongs
  and tell me to refresh. The artifact is what I re-read; chat scrolls away.
- When I decide something, record the decision on that finding - accepted, fixing,
  deferred - in my words, with my reason.
- "I don't follow" means explain it a different way: a diagram, a smaller example, a
  step back. Never the same explanation louder.
- If I ask you to change code, that is me stepping out of this skill to ask for work.
  Do it, then update the levels and findings it touched.

We are done when I have decided on every finding and given you my call on the PR.
**You never declare it done and never make the call for me.** When it looks complete,
ask: "That is every finding decided - ready to make the call on the PR, or is
something still unclear?"

</the-discussion-loop>

<red-flags>

Stop if you catch yourself:

- writing about code you have not opened, or hedging with "presumably" / "should be";
- reaching for a word I would have to ask about ("load-bearing", "seam", ...);
- walking the diff file by file instead of teaching in an order;
- giving a verdict, a score, or an approve/request-changes recommendation;
- pointing me at a `file:line` instead of putting the code on the page;
- listing a finding with no concrete way it goes wrong;
- writing a paragraph where a diagram or a table would land faster;
- padding Levels 3 and 4 when the goal or the design did not hold up.

</red-flags>

<principles>

- There must be a clear and valid goal.
- The design must serve that goal.
- Then correctness, then simplicity of the design and the implementation. I hate
  complexity most. Over-abstraction and premature optimization are the top enemy -
  every new concept must earn its place, and a name that needs me to read five call
  sites signals a bad abstraction, not just a bad label. I will trade performance for
  simplicity when the gain is marginal.
- Then the cost of tests. I like tests but I hate tests that exist for coverage. A
  test earns its place by guarding an important invariant or complicated-but-necessary
  logic. Trivial tests are a cost, not an asset.

</principles>
