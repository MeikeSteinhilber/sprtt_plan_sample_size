library(dplyr)
library(tidyr)
library(kableExtra)
library(glue)
library(purrr)
library(here)
library(stringr)
library(fs)

n_rep <- 2000

# create df --------------------------------------------------------------------

# root folder (use file.path for cross-platform paths)
# root <- file.path("data/tool_{n_rep}", glue("tool_sprt_sample_{n_rep}_normal"))
root <- file.path(glue("data/tool_{n_rep}"))

# list ALL .rds files recursively
rds_files <- dir_ls(root, recurse = TRUE, type = "file", glob = "*.rds")

df_all <- map_dfr(rds_files, function(files) {
  df <- readRDS(files) %>% 
    as_tibble() %>% 
    mutate(source_file = as.character(files))
  df$message <- NULL
  df$call <- NULL
  df
})

# check for missing rows -------------------------------------------------------


df_all_na <- df_all[!complete.cases(df_all), ]
df_all <- df_all[complete.cases(df_all), ]

# compute variables of interest ------------------------------------------------
df_all <- df_all %>% 
  select(
    batch,
    iteration,
    f_simulated,
    f_expected,
    k_groups,
    alpha,
    power,
    distribution,
    sd,
    sample_ratio,
    everything()
  ) %>%
  arrange(
    f_simulated,
    f_expected,
    k_groups,
    alpha,
    power,
    distribution,
    sd,
    sample_ratio,
    batch,
    iteration,
  ) %>% 
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
    decision_error_rate = sum(decision_error)/n(),
    mean_n = mean(n),
    median_n = median(n),
    max_n = max(n),
    min_n = min(n),
    q25_n = quantile(n, 0.25),
    q50_n = quantile(n, 0.50),
    q75_n = quantile(n, 0.75),
    q90_n = quantile(n, 0.90),
    q95_n = quantile(n, 0.95),
    sd_error_n  = sd(n)/sqrt(length((n))),
    decision_status_100 = if_else(decision != "continue sampling", 1, 0),
    decision_rate_100 = sum(decision_status_100)/n(),
    decision_status_25 = if_else(decision != "continue sampling" & n <= q25_n, 1, 0),
    decision_status_50 = if_else(decision != "continue sampling" & n <= q50_n, 1, 0),
    decision_status_75 = if_else(decision != "continue sampling" & n <= q75_n, 1, 0),
    decision_status_90 = if_else(decision != "continue sampling" & n <= q90_n, 1, 0),
    decision_status_95 = if_else(decision != "continue sampling" & n <= q95_n, 1, 0),
    decision_rate_25 = sum(decision_status_25)/n(),
    decision_rate_50 = sum(decision_status_50)/n(),
    decision_rate_75 = sum(decision_status_75)/n(),
    decision_rate_90 = sum(decision_status_90)/n(),
    decision_rate_95 = sum(decision_status_95)/n()
  ) %>% 
  ungroup() %>% 
  select(-starts_with("decision_status_"))
  
df <- df_all %>% 
  group_by(
    f_simulated,
    f_expected,
    k_groups,
    alpha,
    power,
    distribution,
    sd,
    sample_ratio,
    decision_error_rate,
    fix_n,
    mean_n,
    median_n,
    max_n,
    min_n,
    q25_n,
    q50_n,
    q75_n,
    q90_n,
    q95_n,
    sd_error_n,
    decision_rate_100,
    decision_rate_25,
    decision_rate_50,
    decision_rate_75,
    decision_rate_90,
    decision_rate_95
  ) %>% 
  summarise(.) %>% 
  ungroup()
  
# check data -------------------------------------------------------------------
check <- df_all %>%
  count(f_simulated, f_expected, k_groups, power, name = "n") %>%
  arrange(f_simulated, f_expected, k_groups, power)

bad <- filter(check, n != n_rep)
if (nrow(bad) > 0) {
  warning(glue("Expected {n_rep} rows per cell, but {nrow(bad)} cell(s) differ. Showing offending rows."))
  print(bad)
}
  

# done. Example: write out combined file
saveRDS(df, file.path("meta_data", glue("sprt_tool_df_{n_rep}.rds")), compress = "xz")
saveRDS(df_all, file.path("meta_data", glue("sprt_tool_df_all_{n_rep}.rds")), compress = "xz")


# save(list = c("df", "df_all"), file = glue("meta_data/sprt_tool_samples_{n_rep}.RData"))
save(list = c("df", "df_all"), file = glue("meta_data/sprt_tool_samples_{n_rep}.RData"),
     compress = "xz", compression_level = 9)
