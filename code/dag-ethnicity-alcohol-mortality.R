## DAG: candidate interventional-decomposition (CDA) example for the Jackson
## & VanderWeele (2018) section -- ethnicity/immigration status in Denmark,
## binge drinking as a candidate downstream mediator, and accidental death
## (not all-cause mortality) as the outcome.
##
## Outcome choice: accidental death, not all-cause mortality. Alcohol's
## mechanistic story only holds for the acute, behavior-driven causes --
## Udesen et al. (2023, Lancet Reg Health Eur) found accidents accounted
## for 82% of alcohol-related deaths in Danish 15-24-year-olds, and
## alcohol was implicated in 16% of all fatal accidents (54% of drownings,
## 40% of falls). All-cause mortality would dilute this with disease
## deaths alcohol has no plausible acute pathway to.
##
## Mediator choice: binge drinking, not socioeconomic position (SES), even
## though Kruckow & Tolstrup (2024, BMJ Medicine) show SES partly explains
## ethnic differences in mortality (particularly homicide) in the same
## Danish 15-24 cohort. SES is not a well-defined hypothetical
## intervention in Jackson's (2021) sense -- "intervene on someone's
## socioeconomic position" doesn't correspond to a coherent policy lever
## the way "reduce binge drinking prevalence" does. Udesen et al. make
## this intervention explicit themselves: "reducing binge drinking is an
## urgent target for preventive strategies," specifically naming
## adolescents and young adults with low socioeconomic background.
##
## Empirical anchor for the gap being decomposed: Kruckow & Tolstrup
## (2024) report an incidence rate ratio of 0.63 (95% CI 0.43-0.94) for
## accidental death in second-generation immigrants vs. Danish-born
## 15-24-year-olds, adjusted for family income -- a real, cohort-based
## (not case-control) ethnicity gap in exactly this outcome category.
##
## SES is still drawn in the DAG -- as affected by ethnicity AND as a
## confounder of the binge drinking-accidents relationship -- deliberately,
## since this is exactly the "mediator-outcome confounder affected by
## exposure" complication that breaks the simple four-way identification
## assumptions and motivates the more careful weighting-based treatment in
## Jackson (2021), even though SES itself is not the mediator being
## intervened on here.

library(here)
library(dagitty)
source(here("code", "dag-function.R"))

dag <- dagitty("dag {
  Ethnicity -> Alcohol
  Ethnicity -> Accidents
  Ethnicity -> SES
  SES -> Alcohol
  SES -> Accidents
  Age -> Alcohol
  Age -> Accidents
  Alcohol -> Accidents
}")

coordinates(dag) <- list(
  x = c(Ethnicity = 1, Alcohol = 2.6, Accidents = 4.3, SES = 2.3, Age = 2.3),
  y = c(Ethnicity = 1.5, Alcohol = 0.9, Accidents = 1.5, SES = -0.4, Age = 3.2)
)

png(here("figs", "dag-ethnicity-alcohol-mortality.png"),
    width = 8, height = 5.5, units = "in", res = 300, bg = "white")
dag_plot(dag, shrink = 0.2)
dev.off()

## -----------------------------------------------------------------------
## Alternative layout (experimental): a mostly-horizontal "saturated chain"
## version, in the style of the Lundberg-type DAGs discussed elsewhere in
## this deck. Ethnicity -> CSEP -> Alcohol -> Accidents sits on a single
## line (CSEP = childhood socioeconomic position, matching how Udesen
## et al. actually measured it -- parents' education and employment).
## Every earlier node on the chain also gets a direct curved edge to every
## later non-adjacent node (Ethnicity->Alcohol, Ethnicity->Accidents,
## CSEP->Accidents), i.e. the chain is fully saturated rather than assuming
## no direct/skip paths. Age and Sex are drawn as a confounder pair for
## the Alcohol -> Accidents step specifically (one above the line, one
## below), matching Udesen et al.'s finding that alcohol-related deaths
## were heavily concentrated in young men and skewed toward weekend
## nights.

## Single-letter node names -- as in McElreath-style DAGs -- so that
## `shrink` (a fixed fraction of node-to-node coordinate distance, with
## no knowledge of rendered text width) comfortably clears every label
## without needing an oversized shrink value. Semantic meaning is
## restored via colored italic side-annotations placed in open space
## near each node, added after dag_plot() with plain text() calls.
## E = Ethnicity, C = Childhood SEP, A = Alcohol, D = accidental Death,
## G = aGe, S = Sex.

dag2 <- dagitty("dag {
  E -> C
  C -> A
  A -> D
  E -> A
  E -> D
  C -> D
  G -> A
  G -> D
  S -> A
  S -> D
}")

coordinates(dag2) <- list(
  x = c(E = 1, C = 2.8, A = 4.6, D = 6.4, G = 5.5, S = 5.5),
  y = c(E = 1.5, C = 1.5, A = 1.5, D = 1.5, G = 0.3, S = 2.7)
)

curve2 <- list(
  "E->A" = c(0, 0.6),
  "C->D" = c(0, -0.6),
  "E->D" = c(0, -1.3)
)

png(here("figs", "dag-ethnicity-alcohol-accidents-chain.png"),
    width = 10, height = 5, units = "in", res = 300, bg = "white")
dag_plot(dag2, curve = curve2, shrink = 0.2, pad = 1.3)
text(1,   -0.85, "Ethnicity",     col = "firebrick", font = 3, cex = 1.3)
text(2.8, -0.85, "Childhood SEP", col = "firebrick", font = 3, cex = 1.3)
text(4.6, -0.85, "Alcohol",       col = "firebrick", font = 3, cex = 1.3)
text(7.3, -1.5,  "Accidents",     col = "firebrick", font = 3, cex = 1.3)
text(5.5,  0.15, "Age",           col = "firebrick", font = 3, cex = 1.3)
text(5.5, -3.15, "Sex",           col = "firebrick", font = 3, cex = 1.3)
dev.off()
