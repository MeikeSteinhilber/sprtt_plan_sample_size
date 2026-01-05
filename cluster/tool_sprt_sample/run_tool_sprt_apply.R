# parse arguments --------------------------------------------------------------
library(optparse)

option_list <- list(
  make_option(c("--hyper_f_simulated"), 
              type = "double",
              default = 0.40,
              action = "store",
              help = ""
  ),
  make_option(c("--hyper_n_rep_raw_data"), 
              type = "integer",
              default = 10,
              action = "store",
              help = ""
  ),
  make_option(c("--hyper_batch"), 
              type = "integer",
              default = 1,
              action = "store",
              help = ""
  ),
  make_option(c("--hyper_strategy"), 
              type = "character",
              default = "tool_sprt_sample",
              action = "store",
              help = "type of hacking startegy"
  ),
  make_option(c("--hyper_f_expected"), 
              type = "character",
              default = paste(seq(0.10, 0.4, 0.05), collapse = " "),
              action = "store",
              help = ""
  ),
  make_option(c("--hyper_select_raw_data"), 
              type = "character",
              default = "detailed",
              action = "store",
              help = ""
  ),
  make_option(c("--hyper_distribution"), 
              type = "character",
              default = "normal",
              action = "store",
              help = ""
  ),
  make_option(c("--hyper_sd_raw_data"), 
              type = "character",
              default = "11",
              action = "store",
              help = ""
  ),
  make_option(c("--hyper_r_raw_data"), 
              type = "character",
              default = "11",
              action = "store",
              help = ""
  ),
  make_option(c("--hyper_n_raw_data"), 
              type = "integer",
              default = 100,
              action = "store",
              help = ""
  ),
  make_option(c("--hyper_file_type"), 
              type = "character",
              default = "rds",
              action = "store",
              help = ""
  ),
  make_option(c("--hyper_raw_data_folder"), 
              type = "character",
              default = "raw_data",
              action = "store",
              help = ""
  ),
  make_option(c("--hyper_data_folder"), 
              type = "character",
              default = "data",
              action = "store",
              help = ""
  ),
  make_option(c("--hyper_meta_data"), 
              type = "character",
              default = "meta_data",
              action = "store",
              help = ""
  ),
  make_option(c("--hyper_cores_reduction"), 
              type = "integer",
              default = 0,
              action = "store",
              help = ""
  ),
  make_option(c("--hyper_seed"), 
              type = "integer",
              default = 100000,
              action = "store",
              help = ""
  ),
  make_option(c("--hyper_parallel"), 
              type = "logical",
              default = TRUE,
              action = "store",
              help = ""
  ),
  make_option(c("--hyper_sink"), 
              type = "logical",
              default = TRUE,
              action = "store",
              help = ""
  )
)

# save all the options variables in a list -------------------------------------
opt <- parse_args(OptionParser(option_list = option_list))

opt$hyper_sd_raw_data <- paste(strsplit(opt$hyper_sd_raw_data, NULL)[[1]], collapse = "_")
opt$hyper_r_raw_data <- paste(strsplit(opt$hyper_r_raw_data, NULL)[[1]], collapse = "_")

opt$hyper_f_expected <- as.numeric(unlist(strsplit(opt$hyper_f_expected, "\\s+")[[1]]))    #as.numeric(unlist(strsplit(opt$hyper_f_expected, ",")))

# put all the option variables into the global environment ---------------------
list2env(opt, .GlobalEnv)

print(opt)

# measure time -----------------------------------------------------------------
start <- Sys.time()
print(glue::glue("f_sim: {hyper_f_simulated}, batch: {hyper_batch}, START: {start} \n"))

# call the simulation function with the arguments ------------------------------
source("R/tool_sprt_apply.R", print.eval = TRUE)




  apply_sprt(
    hyper_f_simulated = hyper_f_simulated,
    hyper_batch = hyper_batch,
    hyper_strategy = "tool_sprt_sample",
    hyper_f_expected = hyper_f_expected,
    hyper_select_raw_data = hyper_select_raw_data,
    hyper_distribution = hyper_distribution,
    hyper_sd_raw_data = hyper_sd_raw_data,
    hyper_r_raw_data = hyper_r_raw_data,
    hyper_n_raw_data = hyper_n_raw_data,
    hyper_n_rep_raw_data = hyper_n_rep_raw_data,
    hyper_file_type = hyper_file_type,
    hyper_raw_data_folder = hyper_raw_data_folder,
    hyper_data_folder = hyper_data_folder,
    hyper_meta_data = hyper_meta_data,
    hyper_cores_reduction = 0,
    hyper_seed = hyper_seed,
    hyper_parallel = TRUE,
    hyper_sink = TRUE
  )
  
  duration <- round(difftime(Sys.time(), start, units = "mins"), 1)
  print(glue::glue("f_sim: {hyper_f_simulated}, batch: {hyper_batch}, END: {Sys.time()}, duration: {duration} min \n"))




tryCatch({
  beepr::beep(2)
}, error = function(e) {
  cat("Error playing sound: ", e$message, "\n")
})

