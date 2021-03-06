#' Date To Integer
#'
#' Converts Dates to integers where 
#' the 1st of Jan 2000 is equal to 1.
#' 
#' @param x a Date.
#' @return An integer.
#' @examples
#' date2integer(integer2date(-1:3))
#' @export
date2integer <- function (x) {
  as.integer(as.Date(x)) - as.integer(as.Date("1999-12-31"))
}

#' Integer To Date
#'
#' Converts integers to Dates where 
#' the 1st of Jan 2000 is equal to 1.
#' 
#' @param x an integer
#' @return A Date.
#' @examples
#' integer2date(-1:3)
#' @export
integer2date <- function (x) {
  as.Date("1999-12-31") + as.integer(x)
}

as.jagr_chains<- function (x, ...) {
  UseMethod("as.jagr_chains", x)
}

as.jagr_model<- function (x, ...) {
  UseMethod("as.jagr_model", x)
}

#' @title Coerce to a JAGS model object
#'
#' @description
#' Coerces to an object of class \code{jags_model}.
#' 
#' @param x object to coerce.
#' @param ... further arguments passed to or from other methods.
#' @return If successful an object of class \code{jags_model} otherwise NA.
#' @seealso \code{\link{jags_model}} and 
#' \code{\link{jaggernaut}}.
#' @export
as.jags_model <- function (x, ...) {
  UseMethod("as.jags_model", x)
}

as.array.mcarray <- function (x, ...) {

  dim <- dim(x)
  dim <- dim[-length(dim)]
  dim[length(dim)] <- nsamples(x)
  dim(x) <- dim
  names(dim) <- NULL
  class(x)<-"array"
  x<-drop(x)

  return (x)
}

as.matrix.jagr_chains <- function (x, ...) {
  return (as.matrix(as.mcmc.list(x), ...))
}

as.list.jagr_chains <- function (x, ...) {  
  samples <- samples(x)
  list <- list()
  for (name in names(samples))
    list[[name]] <- as.array(samples[[name]])
  
  return (list)
}

as.jagr_chains.jagr_analysis <- function (x, ...) {
  return (chains(x))
}

as.mcmc.list.jagr_chains <- function (x, ...) {
  
  ans <- list()
  for (ch in 1:nchains(x)) {
    ans.ch <- vector("list", length(samples(x)))
    vnames.ch <- NULL
    for (i in seq(along = samples(x))) {
      varname <- names(samples(x))[[i]]
      d <- dim(samples(x)[[i]])
      vardim <- d[1:(length(d) - 2)]
      nvar <- prod(vardim)
      niters <- d[length(d) - 1]
      nchains <- d[length(d)]
      values <- as.vector(samples(x)[[i]])
      var.i <- matrix(NA, nrow = niters, ncol = nvar)
      for (j in 1:nvar) {
        var.i[, j] <- values[j + (0:(niters - 1)) * nvar + 
          (ch - 1) * niters * nvar]
      }
      vnames.ch <- c(vnames.ch, coda.names(varname, vardim))
      ans.ch[[i]] <- var.i
    }
    ans.ch <- do.call("cbind", ans.ch)
    colnames(ans.ch) <- vnames.ch
    ans[[ch]] <- mcmc(ans.ch)
  }
  return (mcmc.list(ans))
}

as.jagr_model.jagr_analysis<- function (x, ...) {
  
  x$init_values <- NULL
  x$chains <- NULL
  x$niters <- NULL
  x$time_interval <- NULL
  
  class(x) <- c("jagr_model")
  
  return (x)
}

as.jagr_model_jagr_analysis <- function (x, ...) {
  stopifnot(is.jagr_analysis(x))
  return (as.jagr_model(x, ...))
}

#' @method as.jags_model jags_analysis
#' @export
as.jags_model.jags_analysis <- function (x, ...) {
  analyses <- analyses(x)
  
  models <- lapply(analyses, as.jagr_model_jagr_analysis, ...)
  
  x <- list()
  class(x) <- "jags_model"
  
  models(x) <- models
  
  return (x)
}
