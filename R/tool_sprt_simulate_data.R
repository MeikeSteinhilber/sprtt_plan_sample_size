
# start simulation function ----------------------------------------------------
simulate_data <- function(
    hyper_n_rep = 1,
    hyper_distribution = "normal",
    hyper_f_simulated = c(0, 0.1, .25, 0.4),
    hyper_sd = c(1, 1, 1, 1),
    hyper_sample_ratio = c(1, 1, 1, 1),
    hyper_max_n = 2000,
    hyper_raw_data_folder = "raw_data",
    hyper_file_type = "rds", # rds or csv
    hyper_cores_reduction = 0,
    hyper_seed = 100000,
    hyper_parallel = TRUE,
    hyper_sink = TRUE
    ) {

  start <- Sys.time()

  # SET SIMULATION SETTINGS ----------------------------------------------------
  library(doSNOW)
  library(doParallel)
  library(foreach)
  library(glue)
  library(data.table)
  library(sprtt)
  
  ## parameter -----------------------------------------------------------------
  k_groups <- length(hyper_sd)
  
  sd_string <- gsub(", ", "_", toString(hyper_sd))
  sample_ratio_string <- gsub(", ", "_", toString(hyper_sample_ratio))
  hyper_f_sim_string <- gsub(", ", "_", toString(hyper_f_simulated))
  
  ## setup backend -------------------------------------------------------------
  source("R/parallel_backend.R", print.eval = TRUE)
  file_name <- glue("{hyper_distribution}_{hyper_n_rep}_sd_{sd_string}_r_{sample_ratio_string}_n_{hyper_max_n}")
  
  backend <- start_parallel(hyper_parallel, hyper_cores_reduction, hyper_sink,
                            glue("simulate_data_{file_name}"))
  
  ## set seed ------------------------------------------------------------------
  set.seed(hyper_seed)
  
  # SIMULATION -----------------------------------------------------------------
  ## simulation parameter ------------------------------------------------------

  
  # f_sim <- 0.25;  i = 1 # Debugging Help
  # start simulation -----------------------------------------------------------
  simulation <- foreach(f_sim = hyper_f_simulated,
                        .errorhandling = "stop",
                        .verbose = FALSE,
                        .export = c("file_name", "hyper_raw_data_folder", "hyper_n_rep", "glue", "sd_string", "sample_ratio_string")
                        ) %:%
    foreach(i = 1:hyper_n_rep, .errorhandling = "pass") %dopar% {
      set.seed(hyper_seed + i)
            
      
      # draw population --------------------------------------------------------
      if (hyper_distribution == "normal") {        
        data <- sprtt::draw_sample_normal(
          k_groups = k_groups,
          f = f_sim,
          max_n = hyper_max_n,
          sd = hyper_sd,
          sample_ratio = hyper_sample_ratio
          )
      } else if (hyper_distribution == "mixture") {
        data <- sprtt::draw_sample_mixture(
          k_groups = k_groups,
          f = f_sim,
          max_n = hyper_max_n
          )
      } else{stop("unclear hyper_distribution")}
      
      # save raw data ----------------------------------------------------------
      folder_path <- glue("{hyper_raw_data_folder}/tool_sprt_sample/{hyper_n_rep}/k_{k_groups}_sd_{sd_string}_sr_{sample_ratio_string}_{hyper_distribution}/fsim_{f_sim}/")
      #print(folder_path)
      if (!dir.exists(folder_path)) {
        # Create the folder if it does not exist
        dir.create(folder_path, recursive = TRUE, showWarnings = TRUE)
        message("Folder created: ", folder_path)
      } 
      
      saveRDS(
        data,
        glue::glue('{folder_path}{file_name}_f_{f_sim}_i_{i}.rds')
      )
        
  }#END foreach
  # SIMULATION END -------------------------------------------------------------

  ## unset seed ----------------------------------------------------------------
  set.seed(NULL)
  
  ## stop backend and sink -----------------------------------------------------
  backend <- stop_parallel(hyper_parallel, hyper_sink, backend)
  
}# END simulate_data

# end simulation function ------------------------------------------------------

# Debugging --------------------------------------------------------------------

# simulate_data(hyper_distribution = "normal",
#               hyper_n_rep = 1,
#               hyper_parallel = TRUE,
#               hyper_sink = TRUE,
#               # hyper_raw_data_folder = "raw_data/rds"
#               )
