
#' @title Ply JAGS sample
#'
#' @description
#' Combines JAGS samples in a jags_sample object by by using function fun
#' 
#' @param object a jags_sample object.
#' @param by the variables to combine by (using ddply).
#' @param fun the function to using when combining samples (by default fun = sum). 
#' @return a jags_sample object
#' @seealso \code{\link{predict.jags_analysis}}
ply_jags_sample <- function (object, by, fun = sum) {
  if(!is.jags_sample(object))
    stop("object must be class jags_sample")

  fun_vs <- function (x, fun) {
    x <- x[,grep("V[[:digit:]]", colnames(x))]
    return (apply(x, MARGIN = 2, FUN = fun))
  }
  
  object <- plyr::ddply(object, .variables = by, fun_vs, fun = fun)
  class(object) <- c("data.frame","jags_sample")
  return (object)
}

