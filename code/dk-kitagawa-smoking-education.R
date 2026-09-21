# =============================================================================
# Kitagawa (1955) Decomposition of the Danish Smoking-Rate Decline, 2010-2025
# Data: Den Nationale Sundhedsprofil 2010 (Tabel 4.1.1) and 2025 (Tabel 3.1.3),
#       Statens Institut for Folkesundhed / Sundhedsstyrelsen -- same figures
#       already used in the "Danish smoking has declined..." motivating slide
#       (des-decomp.qmd, dk_rate / dk_share chunks).
# Method: two-factor decomposition of the 2010->2025 crude-rate decline into
#         a composition effect (educational upgrading) and a rate effect
#         (within-education-group decline in smoking), stratified by
#         education (5 categories). Same symmetric/average-weights formula
#         as ess11-kitagawa-decomp.R and the deck's own "Applying the
#         decomposition" slide, just applied across time instead of
#         across two countries.
#
# NOTE on P_k: dk_share uses each wave's raw (unweighted) respondent counts
# by education as a stand-in for population composition, not an external
# population register. This is an approximation -- it's why the
# reconstructed crude rate below (sum_k P_k*R_k) doesn't land exactly on
# the officially reported national rate (20.9% in 2010, 10.5% in 2025),
# though it comes close. The decomposition below is anchored to the
# reconstructed rate so composition + rate effects sum exactly to it.
# =============================================================================

library(tidyverse)
library(here)
library(glue)

# ── 0. Settings ───────────────────────────────────────────────────────────────

edu_levels <- c("Grundskole*", "Gymnasial/erhvervsfaglig*", "Kort videregående",
                "Mellemlang videregående", "Lang videregående")

# ── 1. Data (identical to des-decomp.qmd's dk_rate / dk_share chunks) ─────────
# R = raw (unadjusted) % daily smokers, both sexes combined, ages 16+
# P = share of survey respondents in that education group (see note above)

wide <- tibble::tribble(
  ~stratum,                     ~R_2010, ~R_2025, ~P_2010, ~P_2025,
  "Grundskole*",                   30.5,    19.7,    13.3,    10.4,
  "Gymnasial/erhvervsfaglig*",     24.9,    13.5,    40.5,    34.7,
  "Kort videregående",             21.7,     9.9,    12.6,    10.7,
  "Mellemlang videregående",       15.8,     8.3,    22.1,    27.8,
  "Lang videregående",              9.0,     4.4,    11.5,    16.3
) |>
  mutate(
    stratum = factor(stratum, levels = edu_levels),
    # rescale to proportions and put rates on the 0-1 scale, matching the
    # ess11 script's convention (both R and P as proportions, not percent)
    across(starts_with("R_"), \(x) x / 100),
    across(starts_with("P_"), \(x) x / 100)
  ) |>
  arrange(stratum)

# ── 2. Crude-rate reconstruction check ─────────────────────────────────────────

official_crude_2010 <- 0.209   # Tabel 4.1.1, "Danmark" row
official_crude_2025 <- 0.105   # Tabel 3.1.4, 2025 row

recon_2010 <- with(wide, sum(P_2010 * R_2010))
recon_2025 <- with(wide, sum(P_2025 * R_2025))

cat(sprintf(
  "\nOfficial crude rate:      2010 = %.1f%%   2025 = %.1f%%\n",
  100 * official_crude_2010, 100 * official_crude_2025
))
cat(sprintf(
  "Reconstructed (sum P*R):  2010 = %.1f%%   2025 = %.1f%%\n",
  100 * recon_2010, 100 * recon_2025
))
cat("(Small gap expected: P uses raw respondent shares, not weighted",
    "population shares -- see note at top of script.)\n")

total_decline <- recon_2010 - recon_2025

# ── 3. Kitagawa two-factor decomposition (symmetric / average weights) ────────
# Decline = sum_k (P_2010k - P_2025k) * (R_2010k + R_2025k)/2   [composition]
#         + sum_k (R_2010k - R_2025k) * (P_2010k + P_2025k)/2   [rate]

kitagawa <- wide |>
  mutate(
    dP = P_2010 - P_2025,
    dR = R_2010 - R_2025,
    Rbar = (R_2010 + R_2025) / 2,
    Pbar = (P_2010 + P_2025) / 2,
    composition_effect = dP * Rbar,
    rate_effect         = dR * Pbar
  )

comp_total <- sum(kitagawa$composition_effect)
rate_total <- sum(kitagawa$rate_effect)

# ── 4. Reference-weighting sensitivity ─────────────────────────────────────────
# One-sided alternatives to the symmetric average above -- both exact on
# their own, but split composition vs. rate differently:
#
#   2025 rates as reference for composition, 2010 shares for the rate term:
#     Decline = sum_k (P_2010k - P_2025k) * R_2025k + sum_k P_2010k * (R_2010k - R_2025k)
#
#   2010 rates as reference for composition, 2025 shares for the rate term:
#     Decline = sum_k (P_2010k - P_2025k) * R_2010k + sum_k P_2025k * (R_2010k - R_2025k)

ref_2025 <- wide |>
  summarise(
    composition_effect = sum((P_2010 - P_2025) * R_2025),
    rate_effect         = sum(P_2010 * (R_2010 - R_2025))
  )

ref_2010 <- wide |>
  summarise(
    composition_effect = sum((P_2010 - P_2025) * R_2010),
    rate_effect         = sum(P_2025 * (R_2010 - R_2025))
  )

sensitivity_tbl <- bind_rows(
  ref_2025 |> mutate(weights = "2025 reference"),
  ref_2010 |> mutate(weights = "2010 reference"),
  tibble(composition_effect = comp_total, rate_effect = rate_total,
         weights = "Average (Kitagawa)")
) |>
  relocate(weights) |>
  mutate(total = composition_effect + rate_effect)

# ── 5. Print summary ───────────────────────────────────────────────────────────

cat("\n-- Stratum-specific rates and shares ----------------------------------\n")
print(wide, digits = 4)

cat(sprintf("\nTotal decline (reconstructed): %.2f pp\n", 100 * total_decline))

cat("\n-- Kitagawa decomposition (average weights) ---------------------------\n")
print(
  kitagawa |> select(stratum, dP, dR, composition_effect, rate_effect),
  digits = 4
)
cat(sprintf(
  "\nComposition effect (educational upgrading): %+.2f pp (%.0f%% of decline)\n",
  100 * comp_total, 100 * comp_total / total_decline
))
cat(sprintf(
  "Rate effect (within-group decline):         %+.2f pp (%.0f%% of decline)\n",
  100 * rate_total, 100 * rate_total / total_decline
))
cat(sprintf("Total:                                        %+.2f pp (check: matches reconstructed decline)\n",
            100 * (comp_total + rate_total)))

cat("\n-- Reference-weighting sensitivity --------------------------------------\n")
print(sensitivity_tbl |> mutate(across(where(is.numeric), \(x) round(100 * x, 2))),
      digits = 4)

# ── 6. Bar chart of the average-weights decomposition ─────────────────────────

plot_data <- tibble(
  component = c("Composition\n(educational upgrading)", "Rate\n(within-group decline)"),
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
    title    = "Kitagawa Decomposition: Danish Smoking Decline, 2010-2025",
    subtitle = glue(
      "Total decline = {round(100*total_decline,1)} pp  |  stratified by education (5 cat.), 2010-2025"
    ),
    x = "Contribution to the decline (percentage points)",
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

strata_detail <- kitagawa |>
  select(stratum, composition_effect, rate_effect) |>
  pivot_longer(c(composition_effect, rate_effect),
               names_to = "component", values_to = "value_pp") |>
  mutate(
    value_pp  = 100 * value_pp,
    component = recode(component,
      composition_effect = "Composition",
      rate_effect         = "Rate"
    )
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
  scale_x_discrete(labels = \(x) str_wrap(x, width = 12)) +
  scale_y_continuous(labels = scales::label_number(suffix = " pp"),
                      expand = expansion(mult = 0.2)) +
  labs(
    title    = "Contribution by Education Stratum, 2010-2025",
    subtitle = "Same decomposition, broken out by stratum instead of summed",
    x = NULL, y = "Contribution to the decline (pp)", fill = NULL
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title       = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    legend.position  = "top"
  )

print(plot_strata_detail)

# ── 7. Save outputs ─────────────────────────────────────────────────────────────

saveRDS(
  list(wide = wide, kitagawa = kitagawa, sensitivity = sensitivity_tbl),
  here("data", "dk-kitagawa-smoking-education.rds")
)

ggsave(here("figs", "dk_kitagawa_smoking_education.png"),
       plot_kitagawa, width = 9, height = 3.5, dpi = 200, bg = "white")

ggsave(here("figs", "dk_kitagawa_smoking_education_by_stratum.png"),
       plot_strata_detail, width = 8, height = 5, dpi = 200, bg = "white")

message("Figures saved to: ", here("figs"))
