# parse arguments --------------------------------------------------------------
library(optparse)

option_list <- list(
  make_option(c("--hyper_n_rep"), 
              type = "integer",
              help = "Number of repetitions", 
              action = "store",
              default = 200
  ),
  make_option(c("--hyper_distribution"), 
              type = "character",
              help = "Type of distribution", 
              action = "store",
              default = "normal"
  ),
  make_option(c("--hyper_f_simulated"), 
              type = "character",
              help = "simulated effect size", 
              action = "store",
              default = paste(c(0, seq(0.10, 0.4, 0.05)), collapse = " ")
  ),
  make_option(c("--hyper_sd"), 
              type = "character",
              help = "standard deviations of the groups", 
              action = "store",
              default = "11"
  ),
  make_option(c("--hyper_sample_ratio"), 
              type = "character",
              help = "sample ratio of the groups", 
              action = "store",
              default = "11"
  ),
  make_option(c("--hyper_max_n"), 
              type = "integer",
              help = "max sample size", 
              action = "store",
              default = 100
  ),
  make_option(c("--hyper_raw_data_folder"), 
              type = "character",
              help = "folder path of raw data", 
              action = "store",
              default = "raw_data"
  ),
  make_option(c("--hyper_file_type"), 
              type = "character",
              help = "csv or rds", 
              action = "store",
              default = "rds"
  ),
  make_option(c("--hyper_cores_reduction"), 
              type = "integer",
              help = "reduces the cores that are used fpr parallelization", 
              action = "store",
              default = 0
  ),
  make_option(c("--hyper_seed"), 
              type = "integer",
              help = "hyper seed of the simulation", 
              action = "store",
              default = 100000
  ),
  make_option(c("--hyper_parallel"), 
              type = "logical",
              help = "use parallelization or not", 
              action = "store",
              default = TRUE
  ),
  make_option(c("--hyper_sink"), 
              type = "logical",
              help = "redirect message sinto an output file or not", 
              action = "store",
              default = TRUE
  )
)

# save all the options variables in a list -------------------------------------
opt <- parse_args(OptionParser(option_list = option_list))

# opt$hyper_sd <- paste(strsplit(opt$hyper_sd, NULL)[[1]], collapse = "_")
# opt$hyper_sample_ratio <- paste(strsplit(opt$hyper_sample_ratio, NULL)[[1]], collapse = "_")
opt$hyper_sd <- as.numeric(unlist(strsplit(opt$hyper_sd, "")))
opt$hyper_sample_ratio <- as.numeric(unlist(strsplit(opt$hyper_sample_ratio, "")))

opt$hyper_f_simulated <- as.numeric(unlist(strsplit(opt$hyper_f_simulated, "\\s+")[[1]]))     # as.numeric(unlist(strsplit(opt$hyper_f_simulated, ",")))

# put all the option variables into the global environment ---------------------
list2env(opt, .GlobalEnv)

print(opt)

# measure time -----------------------------------------------------------------
start <- Sys.time()
print(glue::glue("f_sim: {hyper_f_simulated}, START: {start} \n"))

# call the simulation function with the arguments ------------------------------
source("R/tool_sprt_simulate_data.R", print.eval = TRUE)

simulate_data(
    hyper_n_rep = hyper_n_rep,
    hyper_distribution = hyper_distribution,
    hyper_f_simulated = hyper_f_simulated,
    hyper_sd = hyper_sd,
    hyper_sample_ratio = hyper_sample_ratio,
    hyper_max_n = hyper_max_n,
    hyper_raw_data_folder = hyper_raw_data_folder,
    hyper_file_type = hyper_file_type,
    hyper_cores_reduction = hyper_cores_reduction,
    hyper_seed = hyper_seed,
    hyper_parallel = hyper_parallel,
    hyper_sink = hyper_sink
)

tryCatch({
  beepr::beep()
}, error = function(e) {
  cat("Error playing sound: ", e$message, "\n")
})

duration <- round(difftime(Sys.time(), start, units = "mins"), 1)
print(glue::glue("f_sim: {hyper_f_simulated}, END: {Sys.time()}, duration: {duration} min \n"))