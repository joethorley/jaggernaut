.opts_jagr_debug <- list(
  level = 0.80,
  estimate = "median",
  mode = "debug",
  nchains = 2,
  nresample = 0,
  nsamples = 10,
  parallel = FALSE, 
  quiet = FALSE,
  convergence = 1.5
)

.opts_jagr_test<- list(
  level = 0.95,
  estimate = "median",
  mode = "test",
  nchains = 2,
  nresample = 0,
  nsamples = 100,
  parallel = FALSE, 
  quiet = TRUE,
  convergence = 1.1
)

.opts_jagr_demo<- list(
  level = 0.95,
  estimate = "median",
  mode = "demo",
  nchains = 2,
  nresample = 1,
  nsamples = 500,
  parallel = FALSE, 
  quiet = FALSE,
  convergence = 1.1
)

.opts_jagr_explore<- list(
  level = 0.95,
  estimate = "median",
  mode = "explore",
  nchains = 2,
  nresample = 2,
  nsamples = 200,
  parallel = FALSE, 
  quiet = FALSE,
  convergence = 1.2
)

.opts_jagr_report <- list(
  level = 0.95,
  estimate = "mean",
  mode = "report",
  nchains = 3,
  nresample = 3,
  nsamples = 1000,
  parallel = FALSE, 
  quiet = FALSE,
  convergence = 1.1
)

.opts_jagr_paper <- list(
  level = 0.95,
  estimate = "mean",
  mode = "paper",
  nchains = 5,
  nresample = 4,
  nsamples = 10000,
  parallel = FALSE, 
  quiet = FALSE,
  convergence = 1.05
)

.opts_jagr_def <- .opts_jagr_report

.opts_jagr <- (function() {
  opts_jagr <- .opts_jagr_def
  
  list(
    get = function() opts_jagr,
    set = function(new) {
      old <- opts_jagr
      opts_jagr <<- new
      invisible(old)
    }
  )
})()

opts_jagr_get <- .opts_jagr$get
opts_jagr_set <- .opts_jagr$set

#' @title Get and set jaggernaut options
#'
#' @description
#' Queries and sets options for JAGS analyses.
#' @param ... options can be defined using \code{name = value} or by passing a list
#' of such tagged values.
#' @details
#' The function \code{opts_jagr()}, which can aso be invoked using its alias
#' \code{options_jaggernaut()}, behaves just like the \code{options()}
#'  function in the 
#' base library, with the additional feature that 
#' \code{opts_jagr(mode="default")}
#'  will 
#' reset all options to the values for the default mode. 
#' There are six available modes: debug, explore, test and demo
#' report and paper. 
#' In summary the debug model should be used when first trying to code models in the
#' JAGS dialect of the BUGS language. Once the JAGS code is running without errors
#' is now time to switch to the explore model to look at model adequacy. Once you are content
#' that the model is adequate you can now switch to report model to extract the results
#' for presentation in a report or paper model if you are going to be sending the results to 
#' a peer-reviewed journal. The default mode is report mode. test and demo mode are used
#' internally when testing the package and running demos respectively.
#' 
#' Available options are
#' \describe{
#' \item{level}{the credible interval level (default = 0.95)}
#' \item{estimate}{the type ("mean" or "median") of the point estimate (default = "mean")}
#' \item{nchains}{the number of MCMC chains (default = 3)}
#' \item{nresample}{the number of times to resample 
#' until convergence is achieved (default = 3)}
#' \item{nsamples}{the total number of MCMC samples to thin from the second halves of the MCMC chains (default = 1000)}
#' \item{parallel}{whether in parallel.}
#' \item{quiet}{whether to suppress messages (default = FALSE)}
#' \item{convergence}{the R-hat threshold for convergence (default = 1.1)}
#' }
#' 
#' By default a JAGS analysis will retain a minumum of 1,000 MCMC samples 
#' thinned from the second halves of three chains. For example 
#' if \code{niters = 1000} in the analysis then by default 334 samples will be 
#' thinned from the last 500 iterations of each chain.  
#'  
#' Convergence is considered to have been achieved when all the monitored
#' parameters have an R-hat less than the value of the \code{convergence} option
#' which
#' by default is 1.1 (Kery & Schaub 2011). If the initial number of iterations
#' are performed and the convergence target has not been achieved and
#' \code{nresample > 0}
#' then the value of \code{niters} is doubled, the MCMC sampling to date is 
#' considered the burn in period, the saved MCMC samples are discarded and 
#' MCMC sampling continues.  This process is repeated until the convergence target is 
#' achieved or resampling would exceed the value of the \code{nresample} argument.
#' 
#' 
#' @return For \code{opts_jagr()} a list of all jaggernaut options values
#' sorted by name. For \code{opts_jagr(name)} a list of length one of the 
#' option value. When setting one or more options a list with the previous values of
#' the options unchanged (returned invisibly).
#' @seealso \code{\link{jags_analysis}} and \code{\link{options}}
#' @usage opts_jagr(...)
#' 
#' options_jaggernaut(...) 
#' @examples
#' opts_jagr()
#' opts_jagr(mode = "debug")
#' options_jaggernaut()
#' opts_jagr("nchains","mode")
#' opts_jagr(nchains = 4)
#' opts_jagr("nchains","mode")
#' old <- opts_jagr(mode = "default") 
#' opts_jagr()
#' opts_jagr(old)
#' opts_jagr("nchains","mode") 
#' @export 
#' @aliases options_jaggernaut
opts_jagr <- function (...) {
    
  single <- FALSE
  opts <- opts_jagr_get()
  
  if (nargs() == 0) {
    return(opts)
  }
  args <- list(...)
  if(length(args) == 1) {
    if(is.list(args[[1]])) {
      args <- args[[1]]
    } else if (is.null(names(args))) {
      single <- TRUE
    }
  }
  if(is.null(names(args))) {
    args <- unlist(args)
    value <- vector("list", length(args))
    names(value) <- args
    for (v in args) {
      if (v %in% names(opts)) {
        value[v] <- opts[v]
      } 
    }
    if(single) {
      return (value[[1]])
    }
    return (value)
  }
  old <- opts
  if ("mode" %in% names(args)) {
    parallel <- opts$parallel
    if (args$mode == "debug") {
      opts <- .opts_jagr_debug
    } else if (args$mode == "explore") {
      opts <- .opts_jagr_explore
    } else if (args$mode == "test") {
      opts <- .opts_jagr_test
    } else if (args$mode == "demo") {
      opts <- .opts_jagr_demo
    } else if (args$mode == "report") {
      opts <- .opts_jagr_report
    } else if (args$mode == "paper") {
      opts <- .opts_jagr_paper
    } else if (args$mode == "default") {
      opts <- .opts_jagr_def
    }else if (!args$mode %in% c("current","custom")) {
      stop(paste("mode",args$mode,"not recognized"))
    }
    opts$parallel <- parallel
  }
  names_args <- names(args)
  names_args <- names_args[names_args != "mode"]
  
  if (length(names_args)) {
    opts["mode"] <- "custom"
  }
  
  for (v in names_args) {
    if (is.null(args[[v]])) {
      opts[v] <- list(NULL)
    } else if (mode(opts[[v]]) == mode(args[[v]])) {
      opts[v] <- args[v]
    }
  }
  
  assign_opts_jagr(opts)
  invisible(old)
}

#' @export 
options_jaggernaut <- function (...) {
  return (opts_jagr(...))
}

assign_opts_jagr <- function (opts) {
  
  for (v in names(.opts_jagr_def)) {
    if (!v %in% names(opts))
      stop(paste("option",v,"is unspecified"))
  }
  for (v in names(opts)) {
    if (!v %in% names(.opts_jagr_def))
      stop(paste("option",v,"is unknown"))
  }  

  if (length(opts$level) != 1) {
    stop("option level must be length 1")
  }
  if (length(opts$estimate) != 1) {
    stop("option estimate must be length 1")
  }
  if (length(opts$nchains) != 1) {
    stop("option nchains must be length 1")
  }
  if (length(opts$nresample) != 1) {
    stop("option nresample must be length 1")
  }  
  if (length(opts$nsamples) != 1) {
    stop("option nsamples must be length 1")
  }
  assert_that(is.flag(opts$parallel) && noNA(opts$parallel))
  assert_that(is.flag(opts$quiet) && noNA(opts$quiet))
  
  if (length(opts$convergence) != 1) {
    stop("option convergence must be length 1")
  }
  
  opts$nchains <- as.integer(opts$nchains)
  opts$nresample <- as.integer(opts$nresample)
  opts$nsamples <- as.integer(opts$nsamples)
  
  if (!(opts$level >= 0.75 && opts$level <= 0.99)) {
    stop("option level must lie between 0.75 and 0.99")
  }  
  if (!opts$estimate %in% c("mean","median")) {
    stop("option estimate must be 'mean' or 'median'")
  }
  if (!opts$nchains %in% 2:6) {
    stop("option nchains must lie between 2 and 6")
  }  
  if (!opts$nresample %in% 0:4) {
    stop("option nresample must lie between 0 and 4")
  } 
  if (!(opts$nsamples >= 10 &&  opts$nsamples <= 10000)) {
    stop("option nsamples must lie between 10 and 10^4")
  } 
  
  if (!(opts$convergence >= 1 &&  opts$convergence <= 2))
    stop("option convergence must lie between 1 and 2")
  
  if(opts$parallel && getDoParWorkers() == 1) {
    warning(paste0("chains and models will not be run",
    " in parallel until a parallel backend is registered"))
  } else if(opts$parallel && getDoParWorkers() < opts$nchains) {
    warning(paste0("chains will not be run in parallel 
                   as the number of workers is less than the number of chains"))
  }
  
  topts <- opts[!names(opts) %in% c("mode","parallel")]
  
  if (isTRUE(all.equal(topts, 
               .opts_jagr_debug[!names(.opts_jagr_debug) %in% c("mode","parallel")]))) {
    opts$mode <- "debug"
  } else if(isTRUE(all.equal(topts, 
                       .opts_jagr_explore[!names(.opts_jagr_debug) %in% c("mode","parallel")]))) {
    opts$mode <- "explore"
  } else if(isTRUE(all.equal(topts, 
                             .opts_jagr_test[!names(.opts_jagr_debug) %in% c("mode","parallel")]))) {
    opts$mode <- "test"
  } else if(isTRUE(all.equal(topts, 
                             .opts_jagr_demo[!names(.opts_jagr_debug) %in% c("mode","parallel")]))) {
    opts$mode <- "demo"
  } else if(isTRUE(all.equal(topts, 
                     .opts_jagr_paper[!names(.opts_jagr_debug) %in% c("mode","parallel")]))) {
    opts$mode <- "paper"
  } else if(isTRUE(all.equal(topts, 
                     .opts_jagr_report[!names(.opts_jagr_debug) %in% c("mode","parallel")]))) {
    opts$mode <- "report"
  }
  
  opts_jagr_set(opts)
  invisible(opts)
}
