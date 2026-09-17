## Updated Danish smoking-by-education chart (2010 vs 2025), an analogue
## to the Osler (2000) figure used to motivate the lecture.
##
## Source: Den Nationale Sundhedsprofil (Danish National Health Profile),
## Statens Institut for Folkesundhed / Sundhedsstyrelsen.
##   - 2025: natsup_2025.pdf, Tabel 3.1.3 ("Ryger dagligt. 2025"), raw
##     (unadjusted) percent, both sexes combined, ages 16+.
##   - 2010: Den nationale sundhedsprofil 2010, Tabel 4.1.1 ("Daglig
##     rygning"), raw (unadjusted) "Procent" column, both sexes, ages 16+.
##
## Note on education categories: the 2010 report's lowest two tiers were
## labelled "Ingen erhvervsuddannelse" and "Kort uddannelse"; the 2025
## report relabelled these "Grundskole" and "Gymnasial/erhvervsfaglig
## uddannelse". Treated here as the closest match across waves, not a
## certified identical operationalisation -- flagged with an asterisk.
## The top three tiers (Kort/Mellemlang/Lang videregående uddannelse)
## carry identical labels in both reports.

library(here)
library(ggplot2)
library(dplyr)
library(forcats)

dk_smoking <- tibble::tribble(
  ~education,                          ~y2010, ~y2025,
  "Grundskole*",                         30.5,    19.7,
  "Gymnasial/erhvervsfaglig*",           24.9,    13.5,
  "Kort videregående",                   21.7,     9.9,
  "Mellemlang videregående",             15.8,     8.3,
  "Lang videregående",                    9.0,     4.4
) |>
  mutate(education = fct_inorder(education)) |>
  tidyr::pivot_longer(c(y2010, y2025), names_to = "year", values_to = "pct") |>
  mutate(year = if_else(year == "y2010", "2010", "2025"))

theme_blue <- "#377eb8"
theme_red  <- "#ED1B2F"

p <- ggplot(dk_smoking, aes(x = pct, y = fct_rev(education))) +
  geom_line(aes(group = education), colour = "grey70", linewidth = 3) +
  geom_point(aes(colour = year), size = 6) +
  geom_text(aes(label = sprintf("%.1f%%", pct), colour = year),
            vjust = -1.4, size = 4.2, show.legend = FALSE) +
  scale_colour_manual(values = c("2010" = theme_blue, "2025" = theme_red)) +
  scale_x_continuous(limits = c(0, 35), expand = expansion(mult = c(0, 0.05))) +
  labs(
    title = "Age group 16+, daily smoking by education, Denmark, 2010 vs 2025",
    subtitle = "Total population: 20.9% (2010) to 10.5% (2025)",
    x = "% daily smokers", y = NULL, colour = NULL
  ) +
  theme_minimal(base_size = 16) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),
    legend.position = "top",
    plot.title = element_text(face = "bold", size = 15),
    plot.subtitle = element_text(colour = "grey40")
  )

ggsave(here("figs", "dk-smoking-education-update.png"), p,
       width = 9, height = 5.5, dpi = 300, bg = "white")
