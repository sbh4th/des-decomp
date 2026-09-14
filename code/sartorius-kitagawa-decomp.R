# =============================================================================
# Kitagawa Decomposition of Neonatal Mortality Rate (NMR) Gaps
# Data: Sartorius et al. (2024, JAMA Network Open) Table 2, Euro-Peristat
#       Network, 2015-2020
#
# Reference population : "Top 3" = pooled Finland, Norway, Sweden
# Comparison countries  : Denmark, Austria
# Stratifier            : gestational age (GA) at birth, 7 completed-week
#                         groups (22-23, 24-25, 26-27, 28-31, 32-36, 37-41,
#                         >=42)
#
# Method: the classic symmetric Kitagawa (1955) two-factor decomposition
# (average-weights formula) -- the SAME formula used in the toy FI/NO
# board example, and the exact formula given in the paper's methods:
#
#   NMR_b - NMR_a = sum_i [(R_ai+R_bi)/2] (P_bi-P_ai)   [distribution effect]
#                 + sum_i [(P_ai+P_bi)/2] (R_bi-R_ai)   [rate effect]
#
# where a = reference (Top 3), b = comparison country (Denmark or Austria),
# R = GA-specific NMR per 1000 live births, P = share of live births per
# 1000 in that GA group.
#
# NOTE ON EXACT REPRODUCTION: Table 2 collapses gestational age into 7
# display bins, but the paper's own methods text says the formula is
# applied "for each GA (i)" -- almost certainly individual completed
# weeks, not these 7 aggregated bins. Reconstructing the decomposition
# from the published (aggregated, 2-decimal-rounded) Table 2 numbers
# therefore gets close to, but does not exactly reproduce, the paper's
# Table 3 percentages (Denmark: 0.0% / 100.0%; Austria: 92.9% / 7.1%).
# This script reproduces Denmark at roughly -6% / 106% and Austria at
# roughly 85% / 15% -- see the printed comparison at the end. Denmark's
# composition effect is a small residual of several much larger,
# mostly-canceling terms, so it is especially sensitive to this
# aggregation/rounding; Austria's is not (every stratum from 22-23
# through 37-41 points the same direction), which is why Austria's
# reproduction is closer to the published value than Denmark's.
# =============================================================================

library(tidyverse)
library(here)
library(glue)

# ── 0. Settings ───────────────────────────────────────────────────────────────

ga_levels    <- c("22-23", "24-25", "26-27", "28-31", "32-36", "37-41", "≥42")
REFERENCE    <- "Top 3"
COMPARISONS  <- c("Denmark", "Austria")
grp_colors   <- c("Top 3" = "#4D4D4D", "Denmark" = "#D6604D", "Austria" = "#2166AC")

# ── 1. Data (Sartorius et al. 2024, Table 2) ──────────────────────────────────
# Published rates and GA distributions, live births >= 22 weeks' GA.

sartorius_rates <- tibble(
  ga    = factor(rep(ga_levels, 3), levels = ga_levels),
  group = factor(rep(c(REFERENCE, COMPARISONS), each = 7),
                 levels = c(REFERENCE, COMPARISONS)),
  rate  = c(491.85, 174.53, 71.73, 30.89, 5.21, 0.52, 0.42,
            901.84, 326.15, 103.39, 30.95, 4.44, 0.45, 0.87,
            695.52, 212.26, 86.81, 27.93, 3.96, 0.43, 1.34)
)

sartorius_dist <- tibble(
  ga    = factor(rep(ga_levels, 3), levels = ga_levels),
  group = factor(rep(c(REFERENCE, COMPARISONS), each = 7),
                 levels = c(REFERENCE, COMPARISONS)),
  share = c(0.55, 0.99, 1.39, 5.40, 48.36, 893.32, 49.98,
            0.44, 1.01, 1.53, 6.43, 51.60, 916.99, 22.00,
            0.66, 1.25, 1.74, 7.17, 63.93, 922.33, 2.93)
)

# ── 2. Kitagawa decomposition function (symmetric / average-weights) ─────────
# Applies the exact formula above to one comparison country vs. the
# reference. Returns the stratum-level table plus the two totals.

kitagawa_decomp <- function(comparison) {
  wide <- sartorius_rates |>
    filter(group %in% c(REFERENCE, comparison)) |>
    left_join(
      sartorius_dist |> filter(group %in% c(REFERENCE, comparison)),
      by = c("ga", "group")
    ) |>
    pivot_wider(names_from = group, values_from = c(rate, share))

  names(wide) <- str_replace(names(wide), REFERENCE, "ref")
  names(wide) <- str_replace(names(wide), comparison, "cmp")

  kitagawa <- wide |>
    mutate(
      dP = share_cmp - share_ref,
      dR = rate_cmp  - rate_ref,
      Rbar = (rate_ref + rate_cmp) / 2,
      Pbar = (share_ref + share_cmp) / 2,
      distribution_effect = (dP / 1000) * Rbar,
      rate_effect         = (Pbar / 1000) * dR
    )

  crude_ref <- sum(wide$share_ref / 1000 * wide$rate_ref)
  crude_cmp <- sum(wide$share_cmp / 1000 * wide$rate_cmp)
  total_gap <- crude_cmp - crude_ref

  dist_total <- sum(kitagawa$distribution_effect)
  rate_total <- sum(kitagawa$rate_effect)

  list(
    comparison = comparison,
    kitagawa   = kitagawa,
    crude_ref  = crude_ref,
    crude_cmp  = crude_cmp,
    total_gap  = total_gap,
    dist_total = dist_total,
    rate_total = rate_total,
    dist_pct   = 100 * dist_total / total_gap,
    rate_pct   = 100 * rate_total / total_gap
  )
}

results <- map(COMPARISONS, kitagawa_decomp) |> set_names(COMPARISONS)

# ── 3. Print summary, with comparison to the paper's published Table 3 ───────

published <- tibble(
  comparison = c("Denmark", "Austria"),
  pub_dist_pct = c(0.0, 92.9),
  pub_rate_pct = c(100.0, 7.1)
)

summary_tbl <- map_dfr(results, \(r) tibble(
  comparison = r$comparison,
  crude_ref  = r$crude_ref,
  crude_cmp  = r$crude_cmp,
  total_gap  = r$total_gap,
  dist_pct   = r$dist_pct,
  rate_pct   = r$rate_pct
)) |>
  left_join(published, by = "comparison")

cat("\n-- Kitagawa decomposition: Top 3 vs. Denmark and Austria ------------\n")
cat(sprintf("Crude NMR, Top 3: %.2f per 1000\n\n", results[[1]]$crude_ref))
print(
  summary_tbl |> mutate(across(where(is.numeric), \(x) round(x, 1))),
  n = Inf
)
cat("\nNote: pub_dist_pct/pub_rate_pct are the paper's Table 3 values,\n")
cat("computed from finer (per-week) GA data than Table 2's 7 display bins.\n")

# ── 4. Reference-weighting sensitivity (as in the toy FI/NO example) ─────────
# Same idea as ess11-kitagawa-decomp.R: show how the composition/rate
# split shifts if you use one-sided (reference-only or comparison-only)
# weights instead of the symmetric average.

sensitivity <- map_dfr(COMPARISONS, function(cmp) {
  k <- results[[cmp]]$kitagawa
  total <- results[[cmp]]$total_gap

  ref_weighted <- k |> summarise(
    dist = sum((dP / 1000) * rate_ref),
    rate = sum((share_cmp / 1000) * dR)
  )
  cmp_weighted <- k |> summarise(
    dist = sum((dP / 1000) * rate_cmp),
    rate = sum((share_ref / 1000) * dR)
  )

  bind_rows(
    ref_weighted |> mutate(weights = "Top 3 reference"),
    cmp_weighted |> mutate(weights = glue("{cmp} reference")),
    tibble(dist = results[[cmp]]$dist_total, rate = results[[cmp]]$rate_total,
           weights = "Average (Kitagawa)")
  ) |>
    mutate(comparison = cmp, total = dist + rate,
           dist_pct = 100 * dist / total, rate_pct = 100 * rate / total)
})

cat("\n-- Reference-weighting sensitivity ------------------------------------\n")
print(
  sensitivity |>
    select(comparison, weights, dist_pct, rate_pct) |>
    mutate(across(where(is.numeric), \(x) round(x, 1))),
  n = Inf
)

# ── 5. Plot: decomposition summary (distribution vs. rate effect) ────────────

decomp_plot_data <- map_dfr(COMPARISONS, function(cmp) {
  r <- results[[cmp]]
  tibble(
    comparison = cmp,
    component  = c("Distribution\n(GA mix)", "Rate\n(GA-specific NMR)"),
    value      = c(r$dist_total, r$rate_total)
  )
})

plot_decomp <- ggplot(decomp_plot_data, aes(x = value, y = component, fill = comparison)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  geom_vline(xintercept = 0, colour = "grey30", linewidth = 0.5) +
  geom_text(aes(label = sprintf("%+.2f", value)),
            position = position_dodge(width = 0.7),
            hjust = if_else(decomp_plot_data$value >= 0, -0.15, 1.15),
            size = 4.2) +
  scale_fill_manual(values = grp_colors[COMPARISONS], name = NULL) +
  scale_x_continuous(labels = scales::label_number(suffix = " pp"),
                      expand = expansion(mult = 0.3)) +
  labs(
    title    = "Kitagawa Decomposition: NMR Gap vs. Top 3 Reference",
    subtitle = "Denmark vs. Austria — same-sized gap, opposite decomposition",
    x = "Contribution to the NMR gap (per 1000 live births)",
    y = NULL
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title       = element_text(face = "bold"),
    panel.grid.major.y = element_blank(),
    panel.grid.minor   = element_blank(),
    legend.position    = "top"
  )

print(plot_decomp)

# ── 6. Plot: stratum-level detail ─────────────────────────────────────────────

strata_detail <- map_dfr(COMPARISONS, function(cmp) {
  results[[cmp]]$kitagawa |>
    select(ga, distribution_effect, rate_effect) |>
    pivot_longer(c(distribution_effect, rate_effect),
                 names_to = "component", values_to = "value") |>
    mutate(
      comparison = cmp,
      component  = recode(component,
        distribution_effect = "Distribution",
        rate_effect          = "Rate"
      )
    )
})

plot_strata_detail <- ggplot(strata_detail, aes(x = ga, y = value, fill = component)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  geom_hline(yintercept = 0, colour = "grey30", linewidth = 0.5) +
  facet_wrap(~comparison, ncol = 1) +
  scale_fill_manual(values = c(Distribution = "#4393c3", Rate = "#d6604d")) +
  labs(
    title    = "Contribution by Gestational Age, Top 3 vs. Denmark and Austria",
    subtitle = "Same decomposition, broken out by GA stratum instead of summed",
    x = "Gestational age (completed weeks)",
    y = "Contribution to the NMR gap (per 1000 live births)",
    fill = NULL
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title       = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    legend.position  = "top"
  )

print(plot_strata_detail)

# ── 7. Save outputs ────────────────────────────────────────────────────────────

saveRDS(
  list(results = results, summary = summary_tbl, sensitivity = sensitivity),
  here("data", "sartorius-kitagawa-decomp.rds")
)

out_dir <- here("slides", "03-decomp", "figs")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

ggsave(file.path(out_dir, "sartorius_kitagawa_decomp.png"),
       plot_decomp, width = 8, height = 4, dpi = 200, bg = "white")

ggsave(file.path(out_dir, "sartorius_kitagawa_by_stratum.png"),
       plot_strata_detail, width = 8, height = 7, dpi = 200, bg = "white")

message("Figures saved to: ", out_dir)
