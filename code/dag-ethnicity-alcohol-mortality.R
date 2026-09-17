## DAG: candidate interventional-decomposition example for the Jackson &
## VanderWeele (2018) section -- non-Western immigrant/ethnic-minority
## status in Denmark, alcohol consumption as a candidate downstream
## mediator, and mortality as the outcome.
##
## Socioeconomic position (SES) is drawn as affected by ethnicity AND as
## a confounder of the alcohol-mortality relationship -- deliberately,
## since this is exactly the "mediator-outcome confounder affected by
## exposure" complication that breaks the simple four-way identification
## assumptions and motivates the more careful treatment in Jackson (2021).

library(here)
library(dagitty)
source(here("code", "dag-function.R"))

dag <- dagitty("dag {
  Ethnicity -> Alcohol
  Ethnicity -> Mortality
  Ethnicity -> SES
  SES -> Alcohol
  SES -> Mortality
  Age -> Alcohol
  Age -> Mortality
  Alcohol -> Mortality
}")

coordinates(dag) <- list(
  x = c(Ethnicity = 1, Alcohol = 2.6, Mortality = 4.3, SES = 2.3, Age = 2.3),
  y = c(Ethnicity = 1.5, Alcohol = 0.9, Mortality = 1.5, SES = -0.4, Age = 3.2)
)

png(here("figs", "dag-ethnicity-alcohol-mortality.png"),
    width = 8, height = 5.5, units = "in", res = 300, bg = "white")
dag_plot(dag, shrink = 0.2)
dev.off()
