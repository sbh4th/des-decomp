# Outline: Decomposing the Slope and Relative Index of Inequality

Short methods note, parallel to Wagstaff's (2003) regression
decomposition of the Concentration Index. Working title: "A Note on
Decomposing the Slope and Relative Index of Inequality." Candidate
format: `writing/sii-decomposition.qmd`, same style as
`gapclosing-explainer.qmd` (html, toc, worked numeric example).

## 1. Motivation

- CI, SII, and RII are all regression-on-rank summary measures of a
  socioeconomic gradient, but only CI has a published Wagstaff-style
  factor decomposition (@wagstaff2003).
- SII/RII come from a different tradition (Pamuk; Mackenbach & Kunst
  1997) focused on describing/comparing gradient magnitude, not
  explaining its composition — plausible reason the decomposition was
  never written up, not that it's hard.
- Claim of the note: the SII decomposition is *simpler* to derive than
  Wagstaff's CI decomposition, because SII doesn't require dividing by
  the mean of $y$ first.

## 2. Setup and notation

- Fractional rank / ridit score $R_i \in (0,1)$, same construction used
  for CI.
- SII: OLS/WLS slope from $y_i = a + b R_i + e_i$; $\text{SII} = b$.
- RII: $\text{RII} = \text{SII}/\mu_y$.
- Recall CI's "convenient regression" (Kakwani, Wagstaff & van
  Doorslaer 1997, `@kakwani1997`): regress $2\sigma_R^2(y_i/\mu_y)$ on
  $R_i$; slope $= C_y$.

## 3. The CI/SII relationship

- $C_y = 2\,\text{Cov}(y,R)/\mu_y$; $\text{SII} =
  \text{Cov}(y,R)/\text{Var}(R)$.
- So $C_y = \text{SII} \cdot 2\,\text{Var}(R)/\mu_y$ — a fixed
  rescaling (for continuous uniform rank, $\text{Var}(R) = 1/12$).
- Frame SII/RII decomposition as "the same covariance algebra, one
  normalization step removed."

## 4. Deriving the decomposition

- Start from a linear model $y_i = \sum_k \beta_k x_{ik} + \varepsilon_i$.
- Linearity of covariance:
  $$\text{Cov}(y,R) = \sum_k \beta_k\,\text{Cov}(x_k,R) + \text{Cov}(\varepsilon,R)$$
- Divide by $\text{Var}(R)$ to decompose **SII**:
  $$\text{SII}_y = \sum_k \beta_k\,\text{SII}_k + \text{SII}_\varepsilon,
  \qquad \text{SII}_k = \text{Cov}(x_k,R)/\text{Var}(R)$$
  (i.e., each covariate's own slope-on-rank; $\text{SII}_k$ is
  literally "the SII of $x_k$").
- Divide by $\mu_y$ as well to decompose **RII**:
  $$\text{RII}_y = \sum_k \frac{\beta_k}{\mu_y}\,\text{SII}_k +
  \frac{\text{SII}_\varepsilon}{\mu_y}$$
  Optionally re-express in Wagstaff-style elasticity terms,
  $\eta_k = \beta_k\bar{x}_k/\mu_y$, to make the contributions
  unit-free and comparable to a parallel CI decomposition on the same
  data:
  $$\text{RII}_y = \sum_k \eta_k \cdot \frac{\text{SII}_k}{\bar{x}_k} +
  \frac{\text{SII}_\varepsilon}{\mu_y}$$
- Note in passing: this is even more direct than Wagstaff's CI result,
  which needs the elasticity substitution *because* CI divides by
  $\mu_y$ inside the covariance; SII skips that, so the decomposition
  is one algebra step shorter. Cross-reference the Absolute/Generalized
  CI discussion (§6) to show the family relationship explicitly.

## 5. Percent-of-total contributions

- Define each term's share as $100 \times (\text{term}_k /
  \text{SII}_y)$, matching the convention already used on the CI and
  Oaxaca–Blinder slides in `des-decomp.qmd`.
- Flag the same caveat as Oaxaca/Kitagawa: shares can exceed 100% or
  flip sign when components partially offset (worth a sentence, not a
  proof).

## 6. Relationship to the absolute/generalized CI decomposition

- Show that $GC_y = \mu_y C_y = \sum_k \beta_k \bar{x}_k C_k +
  GC_\varepsilon$ is Wagstaff's own intermediate step before dividing
  by $\mu_y$ — i.e., the "absolute CI decomposition" already exists
  implicitly.
- Erreygers' corrected index for bounded outcomes (`@kessels2013`;
  `@erreygers2016`) is the applied case where this absolute/relative
  distinction was actually formalized.
- One diagram or table placing CI / GC / SII / RII in a 2x2 (relative
  vs. absolute) x (needs elasticity trick vs. doesn't) grid would tie
  §3–§6 together nicely.

## 7. Worked numeric example

- Reuse an existing dataset rather than building a new one — the
  ESS11 smoking/education data (`code/ess11-kbo-decomp.R` or the CI
  decomposition inputs in `data/rci-educ.rds`) already has the pieces:
  a rank variable, a binary/continuous outcome, and covariates.
- Compute SII, RII, and CI side by side on the same data; decompose
  all three; confirm components sum to the total in each case.
- A small table: rows = determinants, columns = contribution to CI /
  contribution to SII / contribution to RII, to make the parallel
  concrete.

## 8. Extensions

- Nonlinear outcome models: WLS on a transformed scale, or marginal
  effects at the rank level (parallel to the "nonlinear models via
  marginal effects" extension already listed on the CI summary slide).
- Two-population or two-time-point version: an Oaxaca-type split of
  the *change* in SII/RII, directly analogous to Wagstaff's 2003
  treatment of changing CI (§4 of that paper) — natural place to reuse
  the reference-group-matters discussion from the Kitagawa/Oaxaca
  sections.
- Structural-equation extension, following Erreygers & Kessels (2016).

## 9. Caveats

- Sensitivity to how the rank $R_i$ is constructed (population-average
  ridit vs. within-group, grouped vs. continuous) — same issue already
  flagged for CI.
- RII decomposition contributions are only comparable across
  determinants/models if $\mu_y$ is stable; framing shares as % of
  SII avoids this but loses direct comparability to CI shares.
- Same "explained is a normative choice, not causal" caveat as the CI
  section.

## 10. References to track down / add to `references.bib`

Already in `references.bib`: `@wagstaff2003`, `@kakwani1997`,
`@odonnell2008`, `@kessels2013`, `@erreygers2016`.

Not yet added — check before citing:

- Pamuk, E.R. (1985). "Social class inequality in mortality from 1921
  to 1972 in England and Wales." *Population Studies*, 39(1), 17–31.
  (coins RII/SII terminology, per Moreno-Betancur et al. 2015)
- Mackenbach, J.P. & Kunst, A.E. (1997). "Measuring the magnitude of
  socio-economic inequalities in health: an overview of available
  measures illustrated with two examples from Europe." *Soc Sci Med*,
  44(6), 757–771. DOI: 10.1016/s0277-9536(96)00073-1
- Moreno-Betancur, M., Latouche, A., Menvielle, G., et al. (2015).
  "Relative Index of Inequality and Slope Index of Inequality: A
  Structured Regression Framework for Estimation." *Epidemiology*,
  26(4), 518–527. DOI: 10.1097/ede.0000000000000311 (definitions,
  estimation options — useful for §2's setup)
