
# install.packages("devtools")
# install.packages("remotes")
remotes::install_github("MeikeSteinhilber/sprtt", ref = "develop")

library(sprtt)

sprtt::plan_sample_size(0.2, 3, power = .95, output_dir = ".")
