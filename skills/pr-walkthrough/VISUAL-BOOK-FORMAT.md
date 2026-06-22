# Visual book format

The walkthrough deliverable is **one self-contained HTML file** per branch at
`.pr-walkthrough/<branch-slug>.html`. Start from [template.html](./template.html)
— it already carries the layout, callout styles, CDN includes, roadmap scaffold,
and insertion markers. Grow it by inserting sections; never regenerate it whole.

## How to grow the file

The template has three things you edit each turn:

- `<ol id="nav">` — the sidebar. Add one `<li><a href="#chN">…</a></li>` per
  section so the growing book stays navigable.
- The **roadmap** `<section id="roadmap">` — update badges, the open-questions /
  fixes / delegated meta line, and the planned descent. This is the state.
- The `<!-- SECTIONS-END -->` marker — insert each new
  `<section class="chapter" id="chN">…</section>` immediately **above** it.

Use the Edit tool to splice; don't rewrite the file. After every edit, tell me to
refresh the browser tab.

## Roadmap chapter = the state

Chapter 0 is the resumable record — there is no separate state file. Keep it
terse and current:

```html
<section class="chapter roadmap" id="roadmap">
  <h2>Roadmap</h2>
  <ol>
    <li class="done"><span class="badge">✅</span> <a href="#ch1">The problem, as a story</a></li>
    <li class="now"><span class="badge">▶</span> <a href="#ch2">Data model: NewThing</a></li>
    <li class="todo"><span class="badge">☐</span> <a href="#ch3">Behavior: the hot path</a></li>
  </ol>
  <div class="meta">Open questions: 2 · Fixes made: 1 · Delegated: 1 running</div>
</section>
```

- **Badges** `✅ done · ▶ in-progress · ☐ pending`. The first non-✅ section is
  where we resume.
- **Open questions** are the backlog — nothing reaches *done* with these
  unresolved unless I explicitly waive them. Spell them out (a short list under
  the roadmap, or a `callout concern`), don't just keep a count.
- **Delegated tasks** record the *approved plan* so that when the subagent
  returns I can check the result against what I signed off on, plus the section
  where its diff was reviewed.
- Refresh the header's `tip` SHA and re-check section boundaries whenever new
  commits land on the branch mid-walkthrough.

## Anatomy of a section

Every bite-size section follows the same beats so the book reads consistently:

1. **A diagram first.** Lead with the visual, then prose. Pick the diagram that
   fits the idea (see below).
2. **Data model**, when the section introduces or changes one — a class/ER
   diagram plus a one-line "what it is" per field that isn't self-evident.
3. **Code logic** — highlighted excerpts in `<pre><code class="language-…">`,
   each preceded by a `<p class="codecap">file.ext:line</p>` caption so I can
   click through. Show *enough* surrounding existing code that I don't have to go
   look it up.
4. **Callouts** that apply the lenses and pre-answer my questions (below).
5. **Connect to neighbors.** One line tying this section to the thread the
   previous one left and the one the next picks up — consecutive sections must
   not feel disjoint.

## Callout types (the recurring lenses)

The template defines these classes; use the matching label text:

- `callout faq` — **Questions you'd ask.** The FAQ I'd otherwise raise, answered
  in advance. Use a `<dl class="faq">` of question/answer pairs. Aim for at least
  one per non-trivial section. This is the headline feature — don't skip it.
- `callout why` — **Why this earns its place.** Justify a new concept/abstraction,
  or admit it doesn't.
- `callout assume` — **Assumption.** A load-bearing assumption the design rests
  on.
- `callout complexity` — **Complexity watch.** Over-abstraction, premature
  optimization, complexity bleeding out of its local spot. My top concern —
  surface it loudly.
- `callout concern` — **Concern / smell.** Correctness, naming, SRP, weak tests,
  performance. Tie it to the open-questions list if unresolved.
- `callout example` — **Example.** A concrete input walked through the code.

```html
<div class="callout faq">
  <div class="label">Questions you'd ask</div>
  <dl class="faq">
    <dt>Why not reuse the existing Foo path?</dt>
    <dd>Because Foo assumes X, which this case violates — see ch4.</dd>
  </dl>
</div>
```

## Which Mermaid diagram for what

- **Behavior / call flow over time** → `sequenceDiagram`.
- **Control or data flow, before/after** → `flowchart`.
- **Data model / types / relationships** → `classDiagram` or `erDiagram`.
- **Lifecycle / status machine** → `stateDiagram-v2`.

Keep each diagram to one idea. Several small diagrams beat one sprawling one.
Diagrams render from CDN — if a panel is blank, it's a network issue, not a bug
in the book.
