library(piggyback)
library(glue)

n_rep <- 2000

# load data --------------------------------------------------------------------
path_df_all <- file.path("meta_data", glue("sprt_tool_df_all_{n_rep}.rds"))
df_all <- readRDS(path_df_all)

# piggyback: prepare the data set for external use -----------------------------

# create a new release on GitHub
new_tag_release <- "v0.1.0-data"

pb_release_create(repo = "MeikeSteinhilber/sprtt_plan_sample_size", tag = new_tag_release)

message("remember to check 'data_url' in the file: sprtt/R/download_sprtt_data.R")

# wait a little bit
Sys.sleep(15) 

# Upload data file to the release
pb_upload(
  file = path_df_all,
  name = "sprtt_external_data_plan_sample_size.rds", # do not change this name!
  repo = "MeikeSteinhilber/sprtt_plan_sample_size",
  tag = new_tag_release,
  overwrite = TRUE
)

# say yes