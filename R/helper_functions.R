# handle NULL cases
# if a value is NULL its possible that the column is then also set to NULL,
# then its necessary to set the misisng value to NA instead
catch_null <- function(x) {if (is.null(x)) NA else x}


# calc Interquartile Range and flag outliers
iqr_detection <- function(data, value = 1.5, output = "no outlier") {
  df <- data %>% 
    group_by(x) %>% 
    mutate(q1 = quantile(y, 0.25),
           q3 = quantile(y, 0.75),
           iqr = q3 - q1,
           lower_bound = q1 - value * iqr,
           upper_bound = q3 + value * iqr,
    ) %>%
    mutate(iqr_outlier = case_when(y < lower_bound | y > upper_bound ~ TRUE,
                                       .default = FALSE)
    ) %>% 
    ungroup() %>% 
    select(y, x, iqr_outlier)
  
  if (output == "no outlier") {
    df %>% filter(iqr_outlier == FALSE)
  } else if (output == "only outlier") {
    df %>% filter(iqr_outlier == TRUE)
  } else{
    df
  }
}


# Clopper-Pearson exact CI
clopper_pearson_ci <- Vectorize(function(emirical_alpha, sample_size, ci_alpha){
  library(PropCIs)
  ci <- exactci(emirical_alpha * sample_size, sample_size, conf.level = 1 - ci_alpha)
  return(as.numeric(ci$conf.int))
}, "emirical_alpha")


power_analysis <- function(f_exp, k_groups, alpha, beta) {
  sample_size_fixed <- double(length(unique(f_exp)))
  counter <- 1
  for (f in unique(f_exp)) {
    power_analysis_n <- pwr::pwr.anova.test(k = k_groups,
                                            f = f,
                                            sig.level = alpha,
                                            power = 1 - beta)$n
    sample_size_fixed[counter] <- ceiling(power_analysis_n) * k_groups 
    counter <- counter + 1
  }
  sample_size_fixed
}


copy_raw_data <- function(
    matched_files,
    hyper_batch,
    hyper_strategy,
    strategy_path,
    hyper_n_rep_raw_data,
    hyper_distribution,
    hyper_raw_data_folder
) {
  start <- Sys.time()
  # raw_data_files <- list.files(path = glue::glue("{hyper_raw_data_folder}"), pattern = pattern)

  if (!dir.exists(glue::glue("{hyper_data_folder}/{hyper_strategy}_{hyper_n_rep_raw_data}_{hyper_distribution}"))) {
    dir.create(glue::glue("{hyper_data_folder}/{hyper_strategy}_{hyper_n_rep_raw_data}_{hyper_distribution}"))
  }
  if (!dir.exists(strategy_path)) {
    # Create the folder if it does not exist
    dir.create(strategy_path, recursive = TRUE)
    message("Folder created: ", strategy_path)
  } 
  
  copy_status <- file.copy(from = file.path(hyper_raw_data_folder, matched_files), to = strategy_path, overwrite = TRUE)
  if (sum(copy_status) != length(matched_files)) {
    message(glue("Warning: in {hyper_n_rep_raw_data} in batch {hyper_batch}: copy process not completly successfull. Only {sum(copy_status)} of {length(matched_files)} files were copied."))
  } else{
    print(glue("{hyper_n_rep_raw_data} in batch {hyper_batch}: Copied succesfully {sum(copy_status)} files into {strategy_path} folder."))
  }
  
  end <- Sys.time()
  duration <- difftime(end, start, units = 'auto')
  cat("Copy process:")
  print(duration)
}

create_meta_df <- function(hyper_meta_data = "meta_data", strategy = "single") {
  library(readr)
  library(purrr)
  path <- glue::glue("{hyper_meta_data}/batches/")
  file_list <- list.files(path = path, pattern = glue(".*.rds$"), full.names = TRUE)
  
  df_all <- file_list %>% 
    map(readRDS) %>%
    bind_rows() %>% 
    arrange(f_simulated, batch, distribution, sd, sample_ratio, strategy, iteration)
  
  # Optionally, write the combined data to a new CSV file
  saveRDS(df_all, file = glue("{hyper_meta_data}/{strategy}.rds"))
}


