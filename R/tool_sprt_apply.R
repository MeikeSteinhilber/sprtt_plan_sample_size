
# start simulation function ----------------------------------------------------
apply_sprt <- function(
    hyper_f_simulated = 0.25,
    hyper_batch = 1,
    hyper_strategy = "tool_sprt_sample",
    hyper_f_expected = c(0.10, 0.25, 0.40),
    hyper_select_raw_data = "detailed", # "all"
    hyper_distribution = "normal",
    hyper_sd_raw_data = "1_1_1_1",
    hyper_r_raw_data = "1_1_1_1",
    hyper_n_raw_data = 2000,
    hyper_n_rep_raw_data = 2,
    hyper_file_type = "rds", # rds or csv
    hyper_raw_data_folder = "raw_data",
    hyper_data_folder = "data",
    hyper_meta_data = "meta_data",
    hyper_cores_reduction = 0,
    hyper_seed = 100000,
    hyper_parallel = TRUE,
    hyper_sink = TRUE
    ) {
  library(glue)
  
  print(hyper_f_simulated)
  print("   ")
  # SET SIMULATION SETTINGS ----------------------------------------------------
  ## setup backend -------------------------------------------------------------
  source("R/parallel_backend.R", print.eval = TRUE)
  file_name <- glue::glue("{hyper_strategy}_fsim_{hyper_f_simulated}")
  
  backend <- start_parallel(hyper_parallel, hyper_cores_reduction, hyper_sink,
                            glue("apply_{hyper_distribution}_{hyper_n_rep_raw_data}_{hyper_f_simulated}_{hyper_sd_raw_data}"))

  ## set seed ------------------------------------------------------------------
  set.seed(hyper_seed)
  suppressPackageStartupMessages({
    library(data.table)
    library(sprtt)
    library(dplyr)
    library(car)
    library(effectsize)
    source("R/helper_functions.R", print.eval = TRUE)
  })
  
  ## pick the correct data -----------------------------------------------------
  k_groups <- length(unlist(strsplit(hyper_sd_raw_data, "_")))
  
  data_path <- glue("{hyper_data_folder}/{hyper_strategy}_{hyper_n_rep_raw_data}_{hyper_distribution}_sd_{hyper_sd_raw_data}_r_{hyper_r_raw_data}")
  raw_data_path <- glue("{hyper_raw_data_folder}/tool_sprt_sample/{hyper_n_rep_raw_data}/k_{k_groups}_sd_{hyper_sd_raw_data}_sr_{hyper_r_raw_data}_{hyper_distribution}/fsim_{hyper_f_simulated}")
  print(raw_data_path)
  print("")
  # folder_path <- glue("{hyper_raw_data_folder}/tool_sprt_sample/{hyper_n_rep}/k_{k_groups}_sd_{sd_string}_sr_{sample_ratio_string}_{hyper_distribution}/fsim_{f_sim}/")
  
  pattern <- glue("^{hyper_distribution}_{hyper_n_rep_raw_data}_sd_{hyper_sd_raw_data}_r_{hyper_r_raw_data}_n_{hyper_n_raw_data}_f_{hyper_f_simulated}_i_.*{hyper_file_type}$")
  print(pattern)
  print("")
  
  if (!dir.exists(data_path)) {
    # Create the folder if it does not exist
    dir.create(data_path, recursive = TRUE)
    message("Folder created: ", data_path)
  } 
  if (hyper_select_raw_data == "all") {
    pattern <- glue(".*.{hyper_file_type}")
    data_path <- glue::glue("{hyper_data_folder}/{hyper_strategy}_{hyper_n_rep_raw_data}")
  }
                                                                           
  raw_data_files <- list.files(path = glue::glue("{hyper_raw_data_folder}/tool_sprt_sample/{hyper_n_rep_raw_data}/k_{k_groups}_sd_{hyper_sd_raw_data}_sr_{hyper_r_raw_data}_{hyper_distribution}/fsim_{hyper_f_simulated}"),
                               pattern = pattern)
  #print(raw_data_files)
  #print("")
  
  # Extract iterations
  iterations <- as.integer(sub(".*_i_(\\d+)\\.rds", "\\1", raw_data_files))
  # Sort the vector by iterations
  raw_data_files <- raw_data_files[order(iterations)]
  
  batch_rows <- as.numeric(strsplit(readLines("cluster/apply_sprt_rows_batches.txt")[hyper_batch], split = " ")[[1]])
  batch_pattern <- paste0("i_", batch_rows,".rds", collapse = "|")
  matched_indices <- grepl(batch_pattern, raw_data_files)
  matched_files <- raw_data_files[matched_indices]
  
  ### copy the raw data files to the corresponding strategy folder
  # copy_raw_data(matched_files,
  #               hyper_batch,
  #               hyper_strategy,
  #               data_path,
  #               hyper_n_rep_raw_data,
  #               hyper_distribution,
  #               glue("{hyper_raw_data_folder}/tool_sprt_sample/n_{hyper_n_rep_raw_data}_k_{k_groups}_sd_{hyper_sd_raw_data}_sr_{hyper_r_raw_data}_{hyper_distribution}"))
  # 
  ### pick the copied files
  # raw_data_files <- list.files(path = data_path, pattern = pattern)
  n_files <- length(matched_files)

  # SIMULATION -----------------------------------------------------------------
  ## simulation parameter ------------------------------------------------------
  power_vector <- c(0.80,0.90,0.95) #seq(0.80, 0.95, 0.05)
  alpha <- .05
  n_rows <- hyper_n_raw_data*k_groups
  
  # f_exp <- 0.25;power = 0.80;  i_file = 1;  # Debugging Help
  ## start simulation ----------------------------------------------------------
simulation <- 
  foreach(
    i_file = 1:n_files,
    .combine = rbind,
    .errorhandling = "stop",
    .verbose = FALSE,
    .inorder = FALSE,
    .export = c("file_name", "backend",
                "hyper_strategy", "hyper_data_folder",
                "hyper_raw_data_folder", "data_path",
                "power_analysis", "iqr_detection",
                "matched_files", "hyper_f_expected",
                "glue", "alpha", "power_vector", "raw_data_path")
  ) %dopar% {
    suppressPackageStartupMessages({
      library(dplyr)
    })
    set.seed(hyper_seed + i_file)
    # print(glue("start: file: {i_file}"))
              
    df <- readRDS(glue("{raw_data_path}/{matched_files[i_file]}"))
    df$row_id <- 1:n_rows
    
    ## initiate data -----------------------------------------------------------
    i_max = length(hyper_f_expected) * length(power_vector)
    results <- data.frame(
      iteration      = integer(i_max),
      batch          = integer(i_max),
      f_simulated    = integer(i_max),
      f_expected     = integer(i_max),
      k_groups       = k_groups,
      alpha          = 0.05,
      power          = integer(i_max),
      distribution   = character(i_max),
      sd             = character(i_max),
      sample_ratio   = character(i_max),
      n_raw_data     = integer(i_max),
      fix_n          = integer(i_max),
      n              = integer(i_max),
      decision       = character(i_max),
      decision_error = logical(i_max),
      log_lr         = integer(i_max),
      f              = integer(i_max),
      f_adj          = integer(i_max),
      f_statistic    = integer(i_max)
    )

    # APPLY SPRTs --------------------------------------------------------------
    i = 1
    for (power in power_vector) {
    for (f_exp in hyper_f_expected) {
      temp_waiting_first_decision = TRUE
      
    
      results$iteration[i]      = i_file
      results$batch[i]          = hyper_batch
      results$f_simulated[i]    = hyper_f_simulated
      results$f_expected[i]     = f_exp
      results$distribution[i]   = hyper_distribution
      results$sd[i]             = hyper_sd_raw_data
      results$sample_ratio[i]   = hyper_r_raw_data
      results$n_raw_data[i]     = hyper_n_raw_data
      results$fix_n[i]          = power_analysis(f_exp,
                                                 k_groups = k_groups,
                                                 alpha = alpha,
                                                 beta = 1 - power)
      
      for (row in (2*k_groups):n_rows) {

        sprt_result <- NULL
      
        sprt_result <- sprtt::seq_anova(y ~ x,
                                        f = f_exp,
                                        power = power,
                                        alpha = alpha,
                                        data = df[1:row, ])

        ## first decision ------------------------------------------------------
        if (sprt_result@decision != "continue sampling" |
            row == n_rows) {
          results$n[i]        = sprt_result@total_sample_size
          results$decision[i] = sprt_result@decision
          results$log_lr[i]   = sprt_result@likelihood_ratio_log
          results$alpha[i]    = sprt_result@alpha
          results$power[i]    = sprt_result@power
          results$f[i]        = sprt_result@effect_sizes$cohens_f
          results$f_adj[i]    = sprt_result@effect_sizes$cohens_f_adj
          results$f_statistic = sprt_result@F_value
            
          ## correct decision ---------------------------------------------------
          if (hyper_f_simulated != 0 && sprt_result@decision == "accept H0") {
            results$decision_error[i] <- TRUE
          } else if (hyper_f_simulated == 0 && sprt_result@decision == "accept H1") {
            results$decision_error[i] <- TRUE
          } else{
            results$decision_error[i] <- FALSE
          }
          
          i = i + 1 
          break
        }
    }#END for-loop: row
    }#END for-loop: f_ex
    }#END: for-loop: power
      
    # save results -------------------------------------------------------------
    # saveRDS(
    #   results,
    #   glue("{data_path}/{matched_files[i_file]}")
    # )
    results

}#END foreach
  
  saveRDS(
    simulation,
    glue("{data_path}/fsim_{hyper_f_simulated}_batch_{hyper_batch}_k_{k_groups}_sd_{hyper_sd_raw_data}_sr_{hyper_r_raw_data}_{hyper_distribution}.rds")
  )
  # END SIMULATION -------------------------------------------------------------
  
  ## unset seed ----------------------------------------------------------------
  set.seed(NULL)
  
  ## stop backend and sink -----------------------------------------------------
  backend <- stop_parallel(hyper_parallel, hyper_sink, backend)

}# END simulate_data


# end simulation function ------------------------------------------------------

# Debugging --------------------------------------------------------------------

# hack_sprt()


# hyper_f_simulated = 0.25
# hyper_batch = 1
# hyper_strategy = "single"
# hyper_f_expected = c(0.10, 0.15, 0.25, 0.30, 0.40)
# hyper_select_raw_data = "detailed" # "all
# hyper_distribution = "normal"
# hyper_sd_raw_data = "1_1_1_1"
# hyper_r_raw_data = "1_1_1_1"
# hyper_n_raw_data = 2000
# hyper_n_rep_raw_data = 2
# hyper_file_type = "rds" # rds or cs
# hyper_raw_data_folder = "raw_data"
# hyper_data_folder = "data"
# hyper_meta_data = "meta_data"
# hyper_cores_reduction = 0
# hyper_seed = 100000
# hyper_parallel = TRUE
# hyper_sink = TRUE