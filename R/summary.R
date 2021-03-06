
summary.jagr_analysis <- function (object, level, estimate, ...) {
  stopifnot(is.jagr_analysis(object))
  stopifnot(is.numeric(level))
  stopifnot(length(level) == 1)
  stopifnot(level >= 0.75)
  stopifnot(level <= 0.99)
  stopifnot(estimate %in% c("mean","median"))
  
  summ <- list()
  
  summ[["Dimensions"]] <- c(samples = nsamples(object), chains = nchains(object))

  summ[["Convergence"]] <- c(Rhat = convergence(object, parm = "all", combine = TRUE))

  summ[["Estimates"]] <- coef(object, parm = "fixed", level = level, 
                              estimate = estimate, as_list = FALSE, latex = FALSE)
  
  class (summ) <- "summary_jagr_analysis"
  
  return (summ)  
}

#' @method summary jags_analysis
#' @export
summary.jags_analysis <- function (object, level = "current", 
                                   estimate = "current", ...) {
  
  if (!is.numeric(level)) {
    if (level != "current") {
      old_opts <- opts_jagr(mode = level)
      on.exit(opts_jagr(old_opts))
    }
    level <- opts_jagr("level")
  } else {
    if (level < 0.75 || level > 0.99) {
      stop("level must lie between 0.75 and 0.99")
    }
  } 
  
  if(!estimate %in% c("mean","median") && estimate != "current") {
    old_opts <- opts_jagr(mode = level)
    if(is.null(sys.on.exit()))
      on.exit(opts_jagr(old_opts))
  }
  
  if (!estimate %in% c("mean","median")) {
    estimate <- opts_jagr("estimate")
  }
  
  analyses <- analyses(object)
  
  summ <- list()
  
  for (i in 1:nmodels(object)) {
    summ[[paste(model_id(object, reference = TRUE)[[i]])]] <- summary(analyses[[i]], level = level, 
                                         estimate = estimate)
  }

  class (summ) <- "summary_jags_analysis"
  
  return (summ)  
}
