library(dplyr)
library(tidyr)
library(kableExtra)
library(gridExtra)
library(glue)
library(here)
library(ggplot2)
library(knitr)
library(kableExtra)
library(gt)
library(ggtext)
library(scales)
library(latex2exp)

n_rep <- 100

load(glue("meta_data/sprt_tool_samples_{n_rep}.RData"))

# variables -------------------------------------------------------------------
digits <- 2

palette <- "RdYlBu"  #"Dark2"
light_green <- "#a5d1c7"
green <- "#69b3a2"
dark_green <- "#548f81"
dark2_green <- "#104949"
light_blue <- "#cce5ff" 
grey_blue <- "#bccfe5"
blue <- "#2c7bb6"  #"#404080"
dark_blue <- "#1b3c70"
magenta <- "#e61be5"
rosa <- "#ff0088"
hell_rosa <- "#ffa1c2"
light_red <- "#e72b2e"
red <- "#e72b2e"
# red <- 	"#d7191c" #"#ca0020" "#CD2626" "#8B0000"
dark_red <- "#8b1012"
black_red <- "#4b1919" # "#651718"

light_orange <- "#fffcf9"
orange <- "#fdae61"
dark_orange <- "#fc8715"
yellow <- "#ffffbf"

dpi = 150
base_size <- 37
linewidth = 1.5
theme_set(theme_bw(base_size = base_size))


# PICK =========================================================================

pick_f_expected = 0.25
pick_power = 0.80
pick_k_groups = 3

# SIMPLE ========================================================================

## simple violin plot -----------------------------------------------------------

pick_f_simulated = c(0, pick_f_expected)

# titles
subtitle_html <- glue(
  "<i>f</i><sub>exp</sub> = {pick_f_expected}, ",
  "<i>f</i><sub>true</sub> = (0, {pick_f_expected}),<br>",
  "1 - &beta; = {pick_power}, &alpha; = 0.05,<br>
  groups = {pick_k_groups}"
)

df_all %>% 
  mutate(f_simulated = factor(f_simulated, levels = sort(unique(pick_f_simulated))),
         fill_group = factor(as.integer(f_simulated))) %>% 
  filter(f_expected == pick_f_expected,
         power == pick_power,
         k_groups == pick_k_groups
  ) %>% 
  filter(f_simulated %in% pick_f_simulated) %>%
  {. ->> cases} %>% 
  ggplot(aes(x = as.factor(pick_k_groups), y = n)) +
  geom_violin(trim = FALSE, fill = light_blue,
              scale = "count",
              draw_quantiles = c(0.25, 0.50, 0.75)) +
  # scale_fill_manual(values = light_blue) +
  geom_point(aes(x = as.factor(pick_k_groups), y = fix_n),
             position = position_dodge(0.9),
             shape = 18,
             color = red,
             size = 13) +
  geom_point(aes(x = as.factor(pick_k_groups), y = mean(mean_n)),
             position = position_dodge(0.9),
             shape = 15,
             color = dark_blue,
             size = 10) + 
  labs(
    x = "f true",
    subtitle = subtitle_html  ) +
  theme(plot.subtitle = element_markdown()) -> p_violin 
# theme(legend.)

ggsave(
  glue("plots/sprt_tool_sample/simple_violin_fexp_{pick_f_expected}.png"),
  width = 25, height = 40, units = "cm"
)


## simple tabe ------------------------------------------------------------------

table_cases <- df_all %>%
  mutate(f_simulated = factor(f_simulated, levels = sort(unique(pick_f_simulated))),
         fill_group = factor(as.integer(f_simulated))) %>%
  filter(f_expected == pick_f_expected,
         power == pick_power,
         k_groups == pick_k_groups
  ) %>%
  filter(f_simulated %in% pick_f_simulated) %>%
  ungroup() %>% 
  mutate(
    decision_status_50 = if_else(decision != "continue sampling" & n <= q50_n, 1, 0),
    decision_status_75 = if_else(decision != "continue sampling" & n <= q75_n, 1, 0),
    decision_status_90 = if_else(decision != "continue sampling" & n <= q90_n, 1, 0),
    decision_status_95 = if_else(decision != "continue sampling" & n <= q95_n, 1, 0),
    decision_status_100 = if_else(decision != "continue sampling", 1, 0)
  ) %>% 
  summarize(
    alpha_error_rate = mean(decision_error[f_simulated == 0], na.rm = TRUE),
    beta_error_rate = mean(decision_error[f_simulated != 0], na.rm = TRUE),
    mean_n = mean(n),
    median_n = median(n),
    max_n = max(n),
    min_n = min(n),
    decision_rate_100 = sum(decision_status_100)/n(),
    q25_n = quantile(n, 0.25),
    q50_n = quantile(n, 0.50),
    q75_n = quantile(n, 0.75),
    q90_n = quantile(n, 0.90),
    q95_n = quantile(n, 0.95),
    sd_error_n  = sd(n)/sqrt(length((n))),
    decision_rate_50 = sum(decision_status_50)/n(),
    decision_rate_75 = sum(decision_status_75)/n(),
    decision_rate_90 = sum(decision_status_90)/n(),
    decision_rate_95 = sum(decision_status_95)/n()
  )


# DETAILED =====================================================================

## detailed violin plot ---------------------------------------------------------

pick_f_simulated = c(0,
                     pick_f_expected - 0.05,
                     pick_f_expected,
                     pick_f_expected + 0.15)
violin_colors <- c(light_blue, hell_rosa, light_blue, light_blue)

df_all %>% 
  mutate(f_simulated = factor(f_simulated, levels = sort(unique(pick_f_simulated))),
         fill_group = factor(as.integer(f_simulated))) %>% 
  filter(f_expected == pick_f_expected,
         power == pick_power,
         k_groups == pick_k_groups
  ) %>% 
  filter(f_simulated %in% pick_f_simulated) %>%
  {. ->> cases} %>% 
  ggplot(aes(x = as.factor(f_simulated), y = n, fill = fill_group)) +
  geom_violin(trim = FALSE, #fill = light_blue,
              scale = "count",
              draw_quantiles = c(0.25, 0.50, 0.75)) +
  scale_fill_manual(values = violin_colors) +
  geom_point(aes(x = as.factor(f_simulated), y = fix_n),
             position = position_dodge(0.9),
             shape = 18,
             color = red,
             size = 10) +
  geom_point(aes(x = as.factor(f_simulated), y = mean_n),
             position = position_dodge(0.9),
             shape = 15,
             color = dark_blue,
             size = 10) + 
  labs(
    x = "f true",
    subtitle = glue("f_exp = {pick_f_expected}, power = {pick_power}, alpha = 0.05, groups = {pick_k_groups}")
  ) -> p_violin 
# theme(legend.)

ggsave(
  glue("plots/sprt_tool_sample/detailed_violin_fexp_{pick_f_expected}.png"),
  width = 45, height = 30, units = "cm"
)

## detailed summary table -------------------------------------------------------

table_cases <- df_all %>% 
  mutate(f_simulated = factor(f_simulated, levels = sort(unique(pick_f_simulated))),
         fill_group = factor(as.integer(f_simulated))) %>% 
  filter(f_expected == pick_f_expected,
         power == pick_power,
         k_groups == pick_k_groups
  ) %>% 
  filter(f_simulated %in% pick_f_simulated) %>% 
    group_by(
    f_simulated,
    f_expected,
    k_groups,
    alpha,
    power,
    distribution,
    sd,
    sample_ratio) %>% 
  mutate(
    decision_status_50 = if_else(decision != "continue sampling" & n <= q50_n, 1, 0),
    decision_status_75 = if_else(decision != "continue sampling" & n <= q75_n, 1, 0),
    decision_status_90 = if_else(decision != "continue sampling" & n <= q90_n, 1, 0),
    decision_status_95 = if_else(decision != "continue sampling" & n <= q95_n, 1, 0),
    decision_status_100 = if_else(decision != "continue sampling", 1, 0)
  ) %>% 
  summarize(
    decision_error_rate = mean(decision_error),
    fix_n = mean(fix_n),
    mean_n = mean(n),
    median_n = median(n),
    max_n = max(n),
    min_n = min(n),
    decision_rate_100 = sum(decision_status_100)/n(),
    q25_n = quantile(n, 0.25),
    q50_n = quantile(n, 0.50),
    q75_n = quantile(n, 0.75),
    q90_n = quantile(n, 0.90),
    q95_n = quantile(n, 0.95),
    sd_error_n  = sd(n)/sqrt(length((n))),
    decision_rate_50 = sum(decision_status_50)/n(),
    decision_rate_75 = sum(decision_status_75)/n(),
    decision_rate_90 = sum(decision_status_90)/n(),
    decision_rate_95 = sum(decision_status_95)/n()
  ) %>% mutate(
    simulated_power = if_else(f_simulated != 0, 1 - decision_error_rate, NA),
    .after = power
  )

table_cases %>%
  gt() %>%
  tab_header(
    title = md("*Summary Table*")
  ) %>%
  cols_label(
    f_expected = md("*f*<sub>exp</sub>"),
    f_simulated = md("*f*<sub>true</sub>"),
    decision_error_rate = "error rate %",
    fix_n = "fixed n",
    mean_n = "mean n",
    median_n = "median n",
    min_n = "min",
    max_n = "max",
    q90_n = "90% n",
    decision_rate_90 = "90% decision rate",
    q95_n = "95% n",
    decision_rate_95 = "95% decision rate"
  ) %>%
  fmt_number(
    columns = everything(),
    decimals = 2
  ) %>%
  gtsave("plots/sprt_tool_sample/detailed_summary_table_gt.png", expand = 10, vwidth = 1600, vheight = 1200)


# POWER CURVE ==================================================================

plot_cases <- df_all %>% 
  mutate(fill_group = factor(as.integer(f_simulated))) %>% 
  filter(f_expected == pick_f_expected,
         power == pick_power,
         k_groups == pick_k_groups
  ) %>% 
  filter(f_simulated != 0) %>% 
  group_by(
    f_simulated,
    f_expected,
    k_groups,
    alpha,
    power,
    distribution,
    sd,
    sample_ratio) %>% 
  mutate(
    decision_status_50 = if_else(decision != "continue sampling" & n <= q50_n, 1, 0),
    decision_status_75 = if_else(decision != "continue sampling" & n <= q75_n, 1, 0),
    decision_status_90 = if_else(decision != "continue sampling" & n <= q90_n, 1, 0),
    decision_status_95 = if_else(decision != "continue sampling" & n <= q95_n, 1, 0),
    decision_status_100 = if_else(decision != "continue sampling", 1, 0)
  ) %>% 
  summarize(
    error_rate = mean(decision_error),
    mean_n = mean(n),
    median_n = median(n),
    q90_n = quantile(n, 0.90),
  ) %>% mutate(
    simulated_power = if_else(f_simulated != 0, 1 - error_rate, NA),
    .after = power
  )


plot_cases %>% 
ggplot(aes(x = f_simulated, y = simulated_power)) +
  # shaded rectangle
  # annotate("rect",
  #          xmin = pick_f_expected, xmax = Inf,
  #          ymin = pick_power, ymax = Inf,
  #          fill = "lightblue", alpha = 0.2) +
  # shaded area under the curve, starting at f_expected
  geom_ribbon(
    data = subset(plot_cases, f_simulated >= pick_f_expected),
    aes(ymin = pick_power, ymax = simulated_power),
    fill = light_green, alpha = 0.7
  ) +
  geom_ribbon(
    data = subset(plot_cases, f_simulated < pick_f_expected),
    aes(ymin = simulated_power, ymax = pick_power),
    fill = light_red, alpha = 0.5
  ) +
  geom_line(linewidth = 1) +
  geom_point(size = 4) +
  geom_hline(yintercept = pick_power, linetype = "dashed") +
  annotate("text", x = min(plot_cases$f_simulated), y = pick_power,
           label = paste0(" target power = ", percent(pick_power)),
           hjust = 0, vjust = 2, size = base_size*0.3) +
  scale_y_continuous(
    limits = c(0, 1),
    breaks = seq(0, 1, by = 0.1),
    labels = percent_format(accuracy = 1)
  ) +
  scale_x_continuous(expand = expansion(mult = c(0.02, 0.02)),
                     breaks = unique(plot_cases$f_simulated)) +
  labs(
    title    = "Simulated power across true effect sizes",
    x = expression(italic(f)[true]),
    y = "Simulated power",
    subtitle = glue("<i>f</i><sub>exp</sub> = {pick_f_expected},",
                    "1 - &beta; = {pick_power}, &alpha; = 0.05, groups = {pick_k_groups}")
  ) +
  theme(
    panel.grid.minor = element_blank(),
    plot.title.position = "plot",
    plot.subtitle = element_markdown()
  )

ggsave(
  glue("plots/sprt_tool_sample/power_curve_fexp_{pick_f_expected}.png"),
  width = 45, height = 30, units = "cm"
)


# CUMULATIVE PLOT ==============================================================

pick_f_expected = 0.25

df_cum <- df_all %>%
  filter(f_expected == pick_f_expected,
         power      == pick_power,
         k_groups   == pick_k_groups) %>% 
  filter(decision != "continue sampling") %>%
  transmute(f_simulated, n_decision = n) %>% 
  group_by(f_simulated) %>%
  arrange(n_decision, .by_group = TRUE) %>%
  mutate(cum_prop = row_number() / n()) %>%
  ungroup()

# 4) Find the minimum n that achieves at least 90% decided
cut90 <- df_cum %>%
  group_by(f_simulated) %>%
  summarise(n_at_90 = min(n_decision[cum_prop >= 0.90]), .groups = "drop")

# 5) Plot: ECDF of decision n, with a 90% line and vertical markers at n_at_90
ggplot(df_cum, aes(x = n_decision, y = cum_prop, colour = factor(f_simulated), group = f_simulated)) +
  geom_step(linewidth = 1.2) +
  geom_hline(yintercept = 0.90) +
  labs(
    x = "Sample size n",
    y = "Cumulative proportion with a decision",
    colour = "f_simulated"
  ) +
  scale_y_continuous(limits = c(0, 1)) 

ggsave(
  glue("plots/sprt_tool_sample/cumulative_n_fexp_{pick_f_expected}.png"),
  width = 50, height = 25, units = "cm"
)
  
  

# COMBINE OUTPUT ===============================================================

library(magick)

plot_path  <- glue::glue("plots/sprt_tool_sample/detailed_violin_fexp_{pick_f_expected}.png")
table_path <- "plots/sprt_tool_sample/detailed_summary_table_gt.png"
out_path   <- glue::glue("plots/sprt_tool_sample/detailed_violin_plus_table_fexp_{pick_f_expected}.png")

# read images
img_plot  <- image_read(plot_path)
img_table <- image_read(table_path)

# make widths match (prevents odd borders if sizes differ)
max_w <- max(image_info(img_plot)$width, image_info(img_table)$width)
img_plot  <- image_resize(img_plot,  geometry = paste0(max_w))
img_table <- image_resize(img_table, geometry = paste0(max_w))

# stack vertically and write
combined <- image_append(c(img_plot, img_table), stack = TRUE)
image_write(combined, out_path)

