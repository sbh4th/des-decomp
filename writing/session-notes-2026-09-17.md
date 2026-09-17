# Session notes — 2026-09-11 to 2026-09-17

Working notes from a long session on des-decomp.qmd (styling, DAGs, and
motivating examples for the Danish Epidemiological Society talk). Bring
this file into a new conversation to pick up where this one left off —
paste it in or just point Claude at `writing/session-notes-2026-09-17.md`.

Note: this covers *this* session's discussion. For the earlier
adv-soc-epi planning session, see `writing/lecture-plan.md` and
`writing/gapclosing-explainer-notes.md`.

---

## 1. Slide typography (settled, applied)

- `custom.scss`: `.reveal h2, .reveal h3 { font-weight: 400; }` — both were
  bold only by browser default, not by any rule in the theme. Regular
  weight reads more McElreath-like at this size.
- `des-decomp.qmd`: the four `# **N. Section**` section-divider titles had
  their `**...**` markdown bold stripped (h1 was never explicitly bold —
  the inline `**bold**` was the only thing making it heavy).
- MathJax `\color[HTML]{...}` does **not** work in this Quarto/revealjs
  setup — tried forcing the `color` package via `include-in-header`
  MathJax config, didn't fix it (Quarto's reveal.js math plugin likely
  clobbers the pre-set `window.MathJax` object). Reverted. Equations
  still use plain `\color{red}` / `\color{blue}` (named colors work
  fine, just not exact hex matches to the theme).

## 2. House DAG function — two real bugs fixed

`code/dag-function.R` defines `dag_plot()`, a base-R plotter for
dagitty objects (italic serif labels, no node circles, per-edge
color/curve control via `curve =` and `edge_col =` args). Two bugs
fixed this session:
1. The file was sourcing itself at the top (`source(here("code",
   "dag-function.R"))` inside its own file) — infinite recursion /
   stack overflow. Removed.
2. `edge_col[[key]]` threw "subscript out of bounds" for any key not
   already in `edge_col`, because `[[` on a plain named *vector*
   (unlike a list) errors instead of returning `NULL` for a missing
   name. Fixed by checking `key %in% names(edge_col)` first.

Prefer `dag_plot()` over ggdag/ggraph for any new DAGs in this deck —
it matches the plain-text, no-boxes look of the reference figures
better and is the established house style now.

## 3. DAG #1 — Income/Health confounders (built, inserted as 2 slides)

Motivation: illustrating confounding for the Concentration Index
section (replacing/supplementing a static `images/inc-health-dag.png`).

- `code/dag-income-health-confounders.R` — builds the dagitty object
  only (Education, Urban/rural, Income, Health, Gender, Age all →
  Income and/or Health); does **not** call `dag_plot()` itself, so
  different slides can call it with different `node_col`/`edge_col`.
- Already wired into `des-decomp.qmd` around line 833: first slide
  shows only `Income -> Health` (everything else whited out), second
  slide reveals the full DAG. Same `dag`/`coords`/`curve`/`shrink`
  across both slides so nothing jumps between them.
- **Not yet done**: the later slides in that section
  (`des-decomp.qmd` ~848, ~974) still reference the old static
  `images/inc-health-dag.png` — could be swapped to the new
  `dag_plot()` version for consistency, wasn't asked to yet.

## 4. Kitagawa historical background (discussed, not yet in deck)

Traced the history of rate standardization (source: Keiding & Clayton
2014, *Statistical Science*; Keiding 1987, *Int Stat Review*):
pre-history in 18th-c. actuarial math → Neison/Farr (England, 1840s–
1859) → **Ogle institutionalized direct standardization in 1883**
(same year G. Koch did it independently in Hamburg — good "no single
inventor" point) → Yule (1934) critiqued indirect standardization's
comparability problems. Kitagawa (1955) isn't inventing
standardization — she's adding the algebraic decomposition into
compositional vs. rate components.

Also pulled ~10 papers citing Kitagawa (1955) in 2026 across health
equity, labor econ, criminology, demography — useful if you want a
"why does a 1955 identity still get reused" slide. Not written up as
slide content yet, just discussed in chat.

## 5. Updated Danish smoking-by-education chart (built, standalone, NOT inserted)

You wanted to replace the Osler (2000) 1982–1992 motivating chart with
something current, and pointed out the original Osler data is Danish.

- Pulled real numbers from the actual **Den Nationale Sundhedsprofil**
  (Danish National Health Profile) PDF reports — 2025 wave (`Tabel
  3.1.3`) and 2010 wave (`Tabel 4.1.1`) — via `pdftotext` on the
  downloaded PDFs (WebFetch can't parse PDF binaries directly).
- `code/dk-smoking-education-update.R` → `figs/dk-smoking-education-update.png`:
  a slope/dumbbell chart, daily smoking % by education, 2010 vs. 2025.
  Total population: 20.9% (2010) → 10.5% (2025).
- **Caveat flagged and kept in the script comments**: education
  category labels changed between waves (2010 used "Ingen
  erhvervsuddannelse"/"Kort uddannelse"; 2025 uses "Grundskole"/
  "Gymnasial/erhvervsfaglig uddannelse"). Top 3 tiers
  (Kort/Mellemlang/Lang videregående) have identical labels both
  years and are a clean comparison; bottom 2 are the closest match,
  not a certified identical operationalization.
- Only 2010 and 2025 pulled as exact numbers — 2013/2017/2021 exist in
  the 2025 report only as an unlabeled bar chart image
  (`Figur 3.1.2`), not as text. Would need to pull those individual
  report PDFs for the full 5-wave trend.
- **You explicitly said**: don't replace the existing Osler chart yet,
  just wanted to see how the new one looks. It's sitting standalone,
  not wired into `des-decomp.qmd`.

## 6. New motivating example for Jackson & VanderWeele section (built, standalone)

You wanted a *potential* application (not an existing published
decomposition) for the interventional-decomposition section — Danish
ethnicity/immigration health inequality, with a downstream/modifiable
mediator to intervene on.

- Landed on **alcohol**, not smoking — smoking-by-ethnicity isn't
  documented in Danish data (checked: the 2025 Sundhedsprofil report
  doesn't stratify by ethnicity/origin at all), but alcohol is:
  - Hansen, Ekholm & Kjøller (2008), *Scand J Public Health*: non-Western
    immigrants in Denmark are "healthier in terms of alcohol and
    vegetable consumption."
  - Hoffmann, Pisinger & Nørredam (2020), *Alcohol and Alcoholism*:
    ethnic Danish high-schoolers with more non-Western classmates are
    themselves substantially less likely to drink/binge drink.
- Ties back to a genuinely interesting hook from earlier in the
  session: Jervelund (2016) and Nørredam (2023) both found non-Western
  immigrants in Denmark have **higher morbidity but lower mortality**
  than ethnic Danes — lower alcohol consumption is a real, evidenced
  candidate piece of *that* puzzle. Frames decomposition as explaining
  a protective gap, not just a harmful one — good discussion hook.
- `code/dag-ethnicity-alcohol-mortality.R` → `figs/dag-ethnicity-alcohol-mortality.png`:
  DAG with Ethnicity (exposure) → Alcohol (mediator) → Mortality
  (outcome), Age as a plain baseline confounder, and **SES deliberately
  drawn as affected by Ethnicity AND confounding Alcohol→Mortality** —
  i.e. the "mediator-outcome confounder affected by exposure" case
  that breaks the simple 4-assumption identification in Jackson &
  VanderWeele (2018) and motivates Jackson (2021)'s weighting
  framework. This DAG doubles as a setup for that identification
  discussion, not just a motivating picture.
- Also standalone — not inserted into the deck yet.

## Open items / natural next steps

- Decide where in `des-decomp.qmd` the two new standalone DAGs
  (income/health confounders is already in; ethnicity/alcohol/mortality
  is not) and the updated Danish smoking chart should actually go.
- If keeping the Danish smoking chart: decide whether to pull
  2013/2017/2021 for the full 5-wave trend, and/or build a two-slide
  reveal like the Income→Health DAG got.
- The ethnicity/alcohol/mortality DAG could get the same "reveal in
  two slides" treatment if useful (though there's no obvious "simple
  first slide" the way Income→Health had one).
- Old static `images/inc-health-dag.png` references later in the
  Concentration Index section could be swapped for the new
  `dag_plot()` version for visual consistency.

## Key file map

| File | What |
|---|---|
| `des-decomp.qmd` | Main deck |
| `custom.scss` | Theme (h1/h2/h3 weight rules here) |
| `code/dag-function.R` | House `dag_plot()` function (bugs fixed this session) |
| `code/dag-income-health-confounders.R` | DAG #1 (builds only; used in 2 slides already in deck) |
| `code/dag-ethnicity-alcohol-mortality.R` | DAG #2 (standalone, not in deck) |
| `code/dk-smoking-education-update.R` | Updated Osler-style chart (standalone, not in deck) |
| `figs/*.png` | Rendered outputs of the above |
| `writing/lecture-plan.md` | Original 75-min talk structure (from prior session) |
