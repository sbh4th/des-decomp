## DAG: confounders of the Income -> Health relationship
## Education, Urban/rural, Gender and Age each affect both Income and
## Health; Age -> Health is drawn as a curved edge to keep it visually
## distinct from the direct paths through Income.
##
## Builds the dag/coords/curve/shrink only -- plotting is left to the
## calling slide chunk, so an Income -> Health-only "before" slide and
## the full-DAG "after" slide can each call dag_plot() with their own
## node_col/edge_col while sharing identical layout (nothing shifts
## position between the two slides).

library(here)
library(dagitty)
source(here("code", "dag-function.R"))

dag <- dagitty("dag {
  Education -> Income
  Education -> Health
  \"Urban/rural\" -> Income
  \"Urban/rural\" -> Health
  Income -> Health
  Gender -> Income
  Gender -> Health
  Age -> Income
  Age -> Health
}")

coordinates(dag) <- list(
  x = c(Education = 2.5, "Urban/rural" = 3.5, Income = 2.5, Health = 4, Gender = 3.25, Age = 2.5),
  y = c(Education = -1, "Urban/rural" = -1, Income = 1,   Health = 1, Gender = 2.5,   Age = 3)
)

dag_nodes  <- names(coordinates(dag)$x)
dag_curve  <- list("Age->Health" = c(0.5, -1))
dag_shrink <- 0.2

