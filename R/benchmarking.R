library(sprtt)
library(tictoc)

# Set parameters
set.seed(123)
n_groups <- 4
max_n <- 2000  # 20 per group = 80 total
effect_size <- 0.25  # medium effect size (Cohen's f)

# Simulate data using sprtt's function
data <- sprtt::draw_sample_normal(
  k_groups = n_groups,
  f = effect_size,
  sd = c(1, 1, 1, 1),  # standard deviation for each group
  max_n = max_n
)

# Time the sequential ANOVA test
tic("seq_anova execution time")
results <- seq_anova(
  y ~ x,
  data = data,
  alpha = 0.05,
  power = 0.80,
  f = effect_size
)
toc()


# 0.15 secs for a single run

# Display results
print(results)

tic("seq_anova execution time")
results <- seq_anova(
  y ~ x,
  data = data,
  alpha = 0.05,
  power = 0.80,
  f = effect_size,
  plot = TRUE # takes obviosly a lot longer
)
toc()