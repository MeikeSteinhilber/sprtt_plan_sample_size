library(piggyback)
library(glue)
n_rep <- 10000

# load data --------------------------------------------------------------------
path_df_all <- file.path("meta_data", glue("sprt_tool_df_all_{n_rep}.rds"))
df_all <- readRDS(path_df_all)

# wrap with version metadata before uploading ----------------------------------
new_tag_release <- "v0.1.0-data"  # single source of truth
versioned_data <- list(
  description = "Sequential ANOVA simulation data for sample size planning",
  version     = new_tag_release,
  created     = as.character(Sys.Date()),
  n_rep       = n_rep,
  data        = df_all
)
path_upload <- file.path(tempdir(), "sprtt_external_data_plan_sample_size.rds")
saveRDS(versioned_data, path_upload)

# piggyback: prepare the data set for external use -----------------------------
# create a new release on GitHub
pb_release_create(repo = "MeikeSteinhilber/sprtt_plan_sample_size", tag = new_tag_release)
message("remember to check 'data_url' in the file: sprtt/R/download_sprtt_data.R")

# wait a little bit
Sys.sleep(120) 

# Upload data file to the release
pb_upload(
  file = path_upload,  # wrapped version with metadata
  name = "sprtt_external_data_plan_sample_size.rds", # do not change this name!
  repo = "MeikeSteinhilber/sprtt_plan_sample_size",
  tag = new_tag_release,
  overwrite = TRUE
)
# say yes, and ignore: HTTP error 422 and do again the pb_upload()