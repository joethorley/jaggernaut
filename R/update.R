update_jags <- function (jags, monitor, n.sim, n.thin, recompile) {
  
  stopifnot(is.jags(jags))
  
  n.sim <- as.integer(n.sim)
  n.thin <- as.integer(n.thin)
  
  quiet <- opts_jagr("quiet")
  
  if (recompile) {
    if (opts_jagr("mode") != "debug") {
      capture.output(jags$recompile())
    } else
      jags$recompile()
  }
  if (opts_jagr("mode") != "debug") {
    capture.output(samples <- jags.samples(
      model = jags, variable.names = monitor, n.iter = n.sim, thin = n.thin
    ))
  } else {
    samples <- jags.samples(
      model = jags, variable.names = monitor, n.iter = n.sim, thin = n.thin
    )      
  }
  object <- list()
  class(object) <- "jagr_chains"
  samples(object) <- samples
  jags(object) <- list(jags)
  return (object)
}

update.jagr_chains <- function (object, niters, nworkers, ...) {
  
  nchains <- nchains(object)
  n.thin <- max(1, floor(nchains * niters / nsamples(object)))
  
  monitor <- monitor(object, trim_suffix = TRUE)
  
  jags <- jags(object)
  
  if(nworkers == 1 || nworkers < nchains) {
    chains <- update_jags (jags = jags[[1]], monitor = monitor, 
                           n.sim = niters, 
                           n.thin = n.thin, 
                           recompile = FALSE)
  } else {
    i <- NULL
    chains <- foreach(i = isplitIndices(n = nchains, chunks = nworkers),
                      .combine = combine_jagr_chains, 
                      .export = "update_jags") %dopar% {
                        update_jags(jags = jags[[i]], monitor = monitor, 
                                    n.sim = niters, 
                                    n.thin = n.thin, 
                                    recompile = TRUE)
                      } 
  }
  
  return (chains)
}

update.jagr_analysis <- function (object, nworkers, ...) {  
  
  niters <- niters(object)
  ptm <- proc.time()
  
  chains(object) <- update(chains(object), niters = niters, nworkers = nworkers)
  niters(object) <- niters * 2
  time_interval(object) <- object$time + ((proc.time () - ptm)[3]) / (60 * 60)
  
  return (object)
}

update_jagr_analysis <- function (object, nworkers, ...) {
  stopifnot(is.jagr_analysis(object))
  return (update(object, nworkers = nworkers, ...))
}

#' @method update jags_analysis
#' @export 
update.jags_analysis <- function (object, mode = "current", ...) {
  
  if (mode != "current") {
    old_opts <- opts_jagr(mode = mode)
    on.exit(opts_jagr(old_opts))
  }
  
  if (options()$jags.pb != "none") {
    jags.pb <- options()$jags.pb
    options(jags.pb = "none")
    on.exit(options("jags.pb" = jags.pb), add = TRUE)
  }
  
  check_modules()
  
  nworkers <- getDoParWorkers()
   
  nchains <- nchains(object)[[1]]
  nmodels <- nmodels(object)
  
  if(!is_parallel(object) && nworkers > 1) {
    nworkers <- 1
  } else if(is_parallel(object) && nworkers < nchains) {
    stop("insufficient workers to run chains in parallel")
  }
        
  quiet <- opts_jagr("quiet")
  
  convergence_threshold <- opts_jagr("convergence")
  
  chunks <- floor(nworkers / nchains)
  chunks <- min(nmodels, chunks)
  if (chunks <= 1) {
    analyses_object <- analyses(object)
    analyses <- list()
    for(i in 1:length(analyses_object)) {
      analyses[[i]] <- update_jagr_analysis(analyses_object[[i]], nworkers = nworkers)
      
      if(!quiet) {
        if(length(analyses_object) > 1)
          cat(paste0("\n", model_id(object, reference = TRUE)[i]))  
        cat("\n")            
        if (is_converged (analyses[[i]], convergence_threshold = convergence_threshold)) {
          cat ("Analysis converged")
        } else 
          cat ("Analysis failed to converge")
        cat_convergence (analyses[[i]])
      }      
    }
  } else { 
    i <- NULL
    
    fun <- function (x1, x2) {
      n1 <- length(x1)
      n2 <- length(x2)
      x <- list()
      for (i in 1:n1)
        x[[i]] <- x1[[i]]
      for (i in 1:n2)
        x[[i + n1]] <- x2[[i]]
      return (x)
    }
    
    analyses <- foreach(i = isplitIndices(n = nmodels, 
                                          chunks = chunks),
                        .combine = fun, 
                        .export = "update_jagr_analysis") %dopar% {
                          update_jagr_analysis(analyses[i], 
                                               nworkers = nchains)
                        }
    if(!quiet) {
      for (i in 1:nmodels) {
        
        cat(paste0("\n", model_id(object, reference = TRUE)[i], "\n"))  
        
        if (is_converged (analyses[[i]], convergence_threshold = convergence_threshold)) {
          cat ("Analysis converged")
        } else 
          cat ("Analysis failed to converge")
        cat_convergence (analyses[[i]])
      }
    }
  }
  
  analyses(object) <- analyses
  convergence_threshold(object) <- convergence_threshold
  
  return (object)
}
