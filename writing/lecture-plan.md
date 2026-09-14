# Decomposition Techniques in Epidemiology: Why and How
Danish Epidemiology Conference — Day 1, September 22, 2026
15:45–17:00 (75 min), Moderator: Terese Høj Jørgensen

## Context

Earlier on the same day, 10:30–12:30, a session on DAGs and counterfactual
mediation covers foundational ground this talk can build on rather than
repeat:
- 10:30–11:15 — Directed Acyclic Graphs (Long Nguyen)
- 11:15–12:30 — Introduction to Counterfactual Mediation and commonly-used
  methods (Gemma Hammerton)

This means the audience already has DAG vocabulary and natural
direct/indirect effect machinery in hand by 15:45, so the causal-bridge
section of this talk can cite back to that morning rather than re-teach
mediation from scratch.

Moderator (2026-09) has proposed building in 1–2 short breaks plus a
little time at the end. The table below assumes 2 short breaks (3 min
each) at the two natural section seams, and expands the closing block
into a proper wrap-up + Q&A buffer. If the moderator settles on just
1 break, drop Break 2 (16:35–16:38) and give its 3 min back to the
causal-bridge block (10 → 13 min), which remains the primary flex block
if further trimming is ever needed.

## Structure (current working version, ~75 min, 2 breaks)

| Time | Block | Content |
|---|---|---|
| 15:45–15:51 (6 min) | Motivation | Open on a concrete disparity/trend; frame the talk explicitly against the morning's mediation session — this talk covers a parallel, older, often purely descriptive tradition of decomposing gaps/changes, and where it does/doesn't connect to what they just learned. Name the three decomposition targets: gap between groups at one time, change over time, gap in a demographic summary measure. |
| 15:51–16:05 (14 min) | Kitagawa rate decomposition / standardization | Kitagawa (1955) decomposition of a crude-rate difference into compositional and rate components; link to age-standardization; toy two-group/two-strata worked example on the board (Kitagawa table); flag the residual/interaction term and reference-weighting sensitivity; applied example (Sartorius et al. 2024, JAMA Netw Open) — Denmark vs. Austria excess neonatal mortality, same total gap, opposite decomposition. |
| 16:05–16:18 (13 min) | Oaxaca–Blinder | Regression decomposition of a mean gap into endowments (composition) vs. coefficients (returns/structural) components (Oaxaca 1973; Blinder 1973). Nonlinear-model complication for logistic/Poisson outcomes. Path-dependence/non-uniqueness problem with categorical covariates — good spot for a brief discussion prompt. |
| **16:18–16:21 (3 min)** | **Break 1** | After the two "two-group difference" methods (Kitagawa, Oaxaca–Blinder), before pivoting to inequality/CI material. |
| 16:21–16:33 (12 min) | Concentration index decomposition | Wagstaff, van Doorslaer & Watanabe (2003) linear decomposition of the concentration index: CI = Σ (βₖ x̄ₖ / μ) Cₖ + GCᵤ/μ — each covariate's contribution is its elasticity times its own concentration index, plus a residual generalized CI of the error term. Same nonlinear-model issue as Oaxaca–Blinder (marginal-effects workaround, van Doorslaer/Koolman-type approach). Likely the most directly applicable section for an SES/health-inequality audience — worth not rushing. |
| 16:33–16:35 (2 min) | Arriaga (compressed) | One slide: life-expectancy-gap decomposition (Arriaga 1984) is the same decomposition logic applied to survival curves rather than rates or means. Pointer citation only, no derivation. |
| **16:35–16:38 (3 min)** | **Break 2** | After the inequality/summary-measure methods (CI decomposition, Arriaga), before the causal section. |
| 16:38–16:48 (10 min) | Causal bridge | Jackson & VanderWeele (2018): Oaxaca-Blinder's "explained" component is a controlled/natural direct effect contrast under the same four mediation identification assumptions (exposure–outcome, exposure–mediator, mediator–outcome, no mediator–outcome confounder affected by exposure) covered that morning. Close on: most published decompositions (Kitagawa, Oaxaca-Blinder, CI-decomposition) are descriptive accounting, not causal effect estimates, unless those assumptions are defended. Two additions to land as closing insight rather than new method: (1) Jackson (2021) — choice of which covariates enter the "explained" component is a normative/equity judgment about what counts as an inequitable difference, not just a technical choice; (2) Lundberg's gap-closing estimand (2022/2024, *Sociological Methods & Research*) — reframes the same causal-decomposition logic as "how much would the gap close under a specific hypothetical intervention," sidesteps the "can race be a treatment?" objection, has off-the-shelf software (`gapclosing` R package). ~2 min for Lundberg, folded in as the coda to the J&V point, not a separate block. This is the primary flex block if the moderator wants 1 break instead of 2, or more Q&A time. |
| 16:48–16:54 (6 min) | Worked example | One dataset, one method (Oaxaca-Blinder or CI-decomposition, whichever has cleaner data available), shown as a single results slide given time constraints. |
| 16:54–17:00 (6 min) | Wrap-up + Q&A | Pitfalls list: non-uniqueness/path-dependence, reference-group sensitivity, descriptive-vs-causal distinction, CI-decomposition's nonlinearity issue, mediation's confounding assumptions. Reading list left up during Q&A. This block absorbs the moderator's "a little time at the end" — confirm with them whether it's meant as live Q&A, a soft buffer for runover, or both. |

## Explicitly out of scope for this talk (too technical/estimation-focused for a 75-min conference slot)

- Jackson's weighting-framework identification proofs (2021, technical estimand/identification detail beyond the normative point above)
- Jackson, Chang, Meche & Nguyen (2026, arXiv preprint) — estimation strategies with allowability specifications
- Yu & Elwert (2023) / nonparametric multiply-robust decomposition (four-part decomposition with efficient influence functions, doubly/multiply robust ML estimators)
- Lundberg's extension to categorical treatments (occupational segregation, 2025) — good for a methods audience, not needed here

## Reading list (for a closing slide)

- Kitagawa, E.M. (1955). Components of a difference between two rates. *JASA*, 50(272), 1168–1194.
- Oaxaca, R. (1973). Male-female wage differentials in urban labor markets. *International Economic Review*.
- Blinder, A.S. (1973). Wage discrimination: reduced form and structural estimates. *Journal of Human Resources*.
- Arriaga, E.E. (1984). Measuring and explaining the change in life expectancies. *Demography*, 21(1), 83–96.
- Wagstaff, A., van Doorslaer, E., & Watanabe, N. (2003). On decomposing the causes of health sector inequalities with an application to malnutrition inequalities in Vietnam. *Journal of Econometrics*, 112(1), 207–223.
- Jackson, J.W. & VanderWeele, T.J. (2018). Decomposition analysis to identify intervention targets for reducing disparities. *Epidemiology*, 29(6), 825–835.
- Jackson, J.W. (2021). Meaningful causal decompositions in health equity research: definition, identification, and estimation through a weighting framework. *Epidemiology*, 32(2), 282–290.
- Lundberg, I. (2022/2024). The gap-closing estimand: A causal approach to study interventions that close disparities across social categories. *Sociological Methods & Research*, 53(2), 507–570.

## Open items

- Confirm with moderator: 1 break or 2? (Table above assumes 2 — see the
  note under Context for how to collapse to 1.)
- Confirm what "a little time at the end" is for — live Q&A, runover
  buffer, or both — since that changes whether the wrap-up block needs
  a hard content cutoff.
- Decide which dataset/method for the worked example (16:48–16:54) based on cleanest available data. (Sartorius DK/AT example now covers this need for the Kitagawa section specifically, so this line is really about Oaxaca-Blinder/CI.)
- Possible slide deck / handout as next step.
