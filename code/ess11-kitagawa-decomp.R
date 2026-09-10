# =============================================================================
# Kitagawa (1955) Decomposition of the Smoking-Rate Gap
# Data: European Social Survey Round 11 (ESS11e04_1), Finland vs Norway
# Method: two-factor decomposition of a crude-rate difference into a
#         composition effect and a rate effect, stratified by education
#
# NOTE: Denmark (DK) is not included in ESS Round 11. Finland (FI) and
# Norway (NO) are used as the two comparison countries for this example —
# this pair gives a more balanced composition/rate split (~23%/77%) than
# FI vs Sweden (~5%/95%), which makes for a better board example.
#
# Outcome    : current smoking (cgtsmok 1-3 = smoker, 4-5 = non-smoker)
# Stratifier : education in three categories (educ3), a refinement of the
#              two-category low_ed split used in ess11-smoking-decomp.R:
#                Low    = eisced 1-2  (low_ed's "low" bucket, split further)
#                Medium = eisced 3-4  (low_ed's "low" bucket, split further)
#                High   = eisced 5-7  (same as low_ed's "high" bucket)
#
# The `smoke` definition is identical to ess11-smoking-decomp.R, so the two
# scripts' samples are directly comparable.
# =============================================================================

library(tidyverse)
library(here)
library(glue)

# ── 0. Settings ───────────────────────────────────────────────────────────────

DATA_PATH <- here("data", "ESS11_slim.csv")
COUNTRY_A <- "FI"   # group A
COUNTRY_B <- "NO"   # group B

# ── 1. Load & clean ───────────────────────────────────────────────────────────

raw <- read_csv(DATA_PATH, show_col_types = FALSE)

ess <- raw |>
  filter(cntry %in% c(COUNTRY_A, COUNTRY_B)) |>
  transmute(
    cntry,
    smoke = case_when(
      cgtsmok %in% 1:3 ~ 1L,
      cgtsmok %in% 4:6 ~ 0L,
      TRUE             ~ NA_integer_
    ),
    educ  = if_else(eisced %in% 1:7, as.integer(eisced), NA_integer_),
    educ3 = case_when(
      educ %in% 1:2 ~ "Low",
      educ %in% 3:4 ~ "Medium",
      educ %in% 5:7 ~ "High",
      TRUE          ~ NA_character_
    ),
    wt    = pspwght
  ) |>
  drop_na()

message(glue(
  "{COUNTRY_A}: N = {sum(ess$cntry == COUNTRY_A)}   ",
  "{COUNTRY_B}: N = {sum(ess$cntry == COUNTRY_B)}"
))

# ── 2. Stratum-specific rates and composition shares ──────────────────────────
# R_k = weighted smoking rate within education stratum k
# P_k = weighted share of the population in stratum k

strata <- ess |>
  mutate(educ3 = factor(educ3, levels = c("Low", "Medium", "High"))) |>
  group_by(cntry, educ3) |>
  summarise(
    R    = weighted.mean(smoke, wt),
    n    = n(),
    wsum = sum(wt),
    .groups = "drop_last"
  ) |>
  mutate(P = wsum / sum(wsum)) |>
  ungroup() |>
  rename(stratum = educ3)

wide <- strata |>
  select(cntry, stratum, R, P) |>
  pivot_wider(names_from = cntry, values_from = c(R, P), names_sep = "_") |>
  arrange(stratum)

names(wide) <- str_replace(names(wide), COUNTRY_A, "A")
names(wide) <- str_replace(names(wide), COUNTRY_B, "B")

# Crude (overall) weighted rate for each country, as a check that
# sum_k P_k * R_k reproduces the observed crude rate
crude_A <- weighted.mean(ess$smoke[ess$cntry == COUNTRY_A], ess$wt[ess$cntry == COUNTRY_A])
crude_B <- weighted.mean(ess$smoke[ess$cntry == COUNTRY_B], ess$wt[ess$cntry == COUNTRY_B])
check_A <- with(wide, sum(P_A * R_A))
check_B <- with(wide, sum(P_B * R_B))

stopifnot(all.equal(crude_A, check_A), all.equal(crude_B, check_B))

total_gap <- crude_A - crude_B

# ── 3. Kitagawa two-factor decomposition (symmetric / average weights) ────────
# Kitagawa's original formula avoids picking either country as the
# "reference" by averaging the two countries' rates and shares. It
# generalizes directly to more than two strata — summing over k = 1..3
# education categories here instead of the usual two:
#
#   Delta_R = sum_k (P_Ak - P_Bk) * (R_Ak + R_Bk)/2     [composition effect]
#           + sum_k (R_Ak - R_Bk) * (P_Ak + P_Bk)/2     [rate effect]
#
# This identity is exact (sums to the total gap) with no residual term.

kitagawa <- wide |>
  mutate(
    dP = P_A - P_B,
    dR = R_A - R_B,
    Rbar = (R_A + R_B) / 2,
    Pbar = (P_A + P_B) / 2,
    composition_effect = dP * Rbar,
    rate_effect         = dR * Pbar
  )

comp_total <- sum(kitagawa$composition_effect)
rate_total <- sum(kitagawa$rate_effect)

# ── 4. Reference-weighting sensitivity ─────────────────────────────────────────
# The symmetric formula above is a compromise. If instead we pick ONE
# country's structure as the reference, the split between "composition"
# and "rate" shifts, even though the total gap does not. Two common
# one-sided choices, both exact (no residual) on their own:
#
#   Using B's rates for composition, A's shares for the rate term:
#     Delta_R = sum_k (P_Ak - P_Bk) * R_Bk  +  sum_k P_Ak * (R_Ak - R_Bk)
#
#   Using A's rates for composition, B's shares for the rate term:
#     Delta_R = sum_k (P_Ak - P_Bk) * R_Ak  +  sum_k P_Bk * (R_Ak - R_Bk)

ref_B <- wide |>
  summarise(
    composition_effect = sum((P_A - P_B) * R_B),
    rate_effect         = sum(P_A * (R_A - R_B))
  )

ref_A <- wide |>
  summarise(
    composition_effect = sum((P_A - P_B) * R_A),
    rate_effect         = sum(P_B * (R_A - R_B))
  )

sensitivity_tbl <- bind_rows(
  ref_B |> mutate(weights = glue("{COUNTRY_B} reference")),
  ref_A |> mutate(weights = glue("{COUNTRY_A} reference")),
  tibble(composition_effect = comp_total, rate_effect = rate_total,
         weights = "Average (Kitagawa)")
) |>
  relocate(weights) |>
  mutate(total = composition_effect + rate_effect)

# ── 5. Print summary ───────────────────────────────────────────────────────────

cat("\n-- Stratum-specific rates and shares --------------------------------\n")
print(wide, digits = 4)

cat(sprintf(
  "\nCrude smoking rate, %s: %.1f%%   %s: %.1f%%   Gap (A-B): %.1f pp\n",
  COUNTRY_A, 100 * crude_A, COUNTRY_B, 100 * crude_B, 100 * total_gap
))

cat("\n-- Kitagawa decomposition (average weights) --------------------------\n")
print(
  kitagawa |> select(stratum, dP, dR, composition_effect, rate_effect),
  digits = 4
)
cat(sprintf(
  "\nComposition effect: %+.2f pp (%.0f%% of gap)\n",
  100 * comp_total, 100 * comp_total / total_gap
))
cat(sprintf(
  "Rate effect:        %+.2f pp (%.0f%% of gap)\n",
  100 * rate_total, 100 * rate_total / total_gap
))
cat(sprintf("Total:               %+.2f pp (check: matches observed gap)\n",
            100 * (comp_total + rate_total)))

cat("\n-- Reference-weighting sensitivity ------------------------------------\n")
print(sensitivity_tbl |> mutate(across(where(is.numeric), \(x) round(100 * x, 2))),
      digits = 4)

# ── 6. Bar chart of the average-weights decomposition ─────────────────────────

plot_data <- tibble(
  component = c("Composition\n(education mix)", "Rate\n(smoking within stratum)"),
  value_pp  = 100 * c(comp_total, rate_total)
) |>
  mutate(component = fct_reorder(component, value_pp))

plot_kitagawa <- ggplot(plot_data, aes(x = value_pp, y = component)) +
  geom_col(fill = "#2166ac", width = 0.5) +
  geom_vline(xintercept = 0, colour = "grey30", linewidth = 0.5) +
  geom_text(aes(label = sprintf("%+.2f pp", value_pp),
                hjust = if_else(value_pp >= 0, -0.15, 1.15)),
            size = 4.4) +
  scale_x_continuous(labels = scales::label_number(suffix = " pp"),
                      expand = expansion(mult = 0.3)) +
  labs(
    title    = glue("Kitagawa Decomposition: Smoking Gap, {COUNTRY_A} vs {COUNTRY_B}"),
    subtitle = glue(
      "Total gap = {round(100*total_gap,1)} pp  |  stratified by education (3 cat.)  |  ",
      "ESS Round 11"
    ),
    x = "Contribution to the smoking-rate gap (percentage points)",
    y = NULL
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title         = element_text(face = "bold"),
    panel.grid.major.y = element_blank(),
    panel.grid.minor   = element_blank()
  )

print(plot_kitagawa)

# ── 6b. Stratum-level detail: where do the two effects come from? ─────────────
# Breaks the two totals down by education stratum, showing that the
# composition and rate effects are not uniform across strata: e.g. the
# High-education stratum can push composition in the *opposite* direction
# from the total (NO has more high-ed people, which narrows the gap),
# while the Medium stratum dominates both effects.

strata_detail <- kitagawa |>
  select(stratum, composition_effect, rate_effect) |>
  pivot_longer(c(composition_effect, rate_effect),
               names_to = "component", values_to = "value_pp") |>
  mutate(
    value_pp  = 100 * value_pp,
    component = recode(component,
      composition_effect = "Composition",
      rate_effect         = "Rate"
    ),
    stratum = factor(stratum, levels = c("Low", "Medium", "High"))
  )

plot_strata_detail <- ggplot(strata_detail,
                              aes(x = stratum, y = value_pp, fill = component)) +
  geom_col(position = position_dodge(width = 0.65), width = 0.55) +
  geom_hline(yintercept = 0, colour = "grey30", linewidth = 0.5) +
  geom_text(aes(label = sprintf("%+.2f", value_pp)),
            position = position_dodge(width = 0.65),
            vjust = if_else(strata_detail$value_pp >= 0, -0.4, 1.3),
            size = 3.6) +
  scale_fill_manual(values = c(Composition = "#4393c3", Rate = "#d6604d")) +
  scale_y_continuous(labels = scales::label_number(suffix = " pp"),
                      expand = expansion(mult = 0.2)) +
  labs(
    title    = glue("Contribution by Education Stratum, {COUNTRY_A} vs {COUNTRY_B}"),
    subtitle = "Same decomposition, broken out by stratum instead of summed",
    x = NULL, y = "Contribution to the smoking-rate gap (pp)", fill = NULL
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title       = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    legend.position  = "top"
  )

print(plot_strata_detail)

# ── 7. Save outputs ─────────────────────────────────────────────────────────────

saveRDS(
  list(wide = wide, kitagawa = kitagawa, sensitivity = sensitivity_tbl),
  here("data", "ess11-kitagawa-smoking.rds")
)

out_dir <- here("slides", "03-decomp", "figs")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

ggsave(file.path(out_dir, "ess11_kitagawa_smoking.png"),
       plot_kitagawa, width = 9, height = 3.5, dpi = 200, bg = "white")

ggsave(file.path(out_dir, "ess11_kitagawa_smoking_by_stratum.png"),
       plot_strata_detail, width = 8, height = 5, dpi = 200, bg = "white")

message("Figures saved to: ", out_dir)
