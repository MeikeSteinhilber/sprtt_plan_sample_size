start_parallel <- function(hyper_parallel, hyper_cores_reduction, hyper_sink, file_name) {
  
  # save start time ------------------------------------------------------------
  start <- Sys.time()
  
  # library --------------------------------------------------------------------
  suppressPackageStartupMessages({
    library(doSNOW)
    library(doParallel)
    library(foreach)
    library(glue)
  })
  
  # sink -----------------------------------------------------------------------
  if (hyper_sink) {
    name_file_output <- glue("output/out_{file_name}.txt")
    file_output <- file(name_file_output, open = "wt")
    sink(file_output, type = "output", append = TRUE)
    sink(file_output, type = "message", append = TRUE)
  }
  
  # set up parallel backend ----------------------------------------------------
  if (hyper_parallel) {
    writeLines("", glue("output/print_{file_name}.txt")) 
    
    n_cores <- detectCores()
    cluster = parallel::makeCluster(
      n_cores - hyper_cores_reduction,
      outfile = glue("output/print_{file_name}.txt")
    )
    doSNOW::registerDoSNOW(cluster)
  }
  # return ---------------------------------------------------------------------
  return(list(start = start, file_output = file_output, cluster = cluster))
}

stop_parallel <- function(hyper_parallel, hyper_sink, backend) {
  # shut down workers ----------------------------------------------------------
  if (hyper_parallel) {
    parallel::stopCluster(backend$cluster)
  }
  # print time  ----------------------------------------------------------------
  end <- Sys.time()
  duration <- difftime(end, backend$start, units = 'auto')
  print(duration)
  
  ## close sink ----------------------------------------------------------------
  if (hyper_sink) {
    sink(type = "output")
    sink(type = "message")
    close(backend$file_output)
  }

  NULL
}