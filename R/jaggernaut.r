
#' @title Bayesian Analysis with JAGS
#'
#' @description 
#' An R package to facilitate Bayesian analysis
#' using JAGS (Just Another Gibbs Sampler).
#' 
#' @details
#' In short an analysis proceeds first by the 
#' definition of the JAGS model(s) using
#' the \code{\link{jags_model}} function.  Next the resultant \code{jags_model} object
#' or  \code{\link{jags_model}} objects in list form are passed together with a data set to 
#' the \code{\link{jags_analysis}} function which calls the JAGS software to 
#' perform the actual MCMC
#' sampling.  The resultant \code{\link{jags_analysis}} object can then be passed
#' to the \code{\link{plot.jags_analysis}} function to view the MCMC traces, the 
#' \code{\link{convergence}} function to check the Rhat values of individual parameters
#' and the \code{\link{coef.jags_analysis}} function to get the parameter estimates with 95\%
#' credible limits.  The \code{\link{predict.jags_analysis}} function can then be used to extract
#' derived parameter estimates from a \link{jags_analysis} object without the need for further
#' MCMC sampling.
#' 
#' The data sets accompanying this package are those used in the real 
#' examples in Kery and Schaub's (2011) book Bayesian Population Analysis using WinBUGS.
#' To see all available data sets type 
#' \code{data()}.  To get further information on for example 
#' the \code{peregrine}
#' data set type \code{?peregrine}. For illustrative purposes the 
#' real examples in Kery and Schaub (2011) are in the process of being implemented 
#' in jaggernaut as demos. To see the available demos type \code{demo()}.
#' To run the demo for the peregrine data set use the command \code{demo(peregrine)}.
#' 
#' The package is in beta form please report any bugs or pass on any comments
#' or requests to the package maintainer at \email{<joe@@poissonconsulting.ca>}.
#' 
#' @references 
#' Kery M & Schaub M (2011) Bayesian Population Analysis
#' using WinBUGS. Academic Press. (\url{http://www.vogelwarte.ch/bpa})
#' 
#' Plummer M (2012) JAGS Version 3.3.0 User Manual \url{http://sourceforge.net/projects/mcmc-jags/files/Manuals/}
#' 
#' @docType package
#' @import abind coda rjags foreach
#' @name jaggernaut
#' @aliases package-jaggernaut jagr0
#' @seealso \code{\link{jags_model}}, \code{\link{jags_analysis}}, \code{\link{plot.jags_analysis}},
#' \code{\link{convergence}},
#' \code{\link{coef.jags_analysis}} and \code{\link{predict.jags_analysis}}.
#' @examples
#' 
#' mod <- jags_model("
#' model { 
#'  bLambda ~ dlnorm(0,10^-2) 
#'  for (i in 1:nrow) { 
#'    x[i]~dpois(bLambda) 
#'  } 
#'}")
#'
#' dat <- data.frame(x = rpois(100,1))
#' 
#' an <- jags_analysis (mod, dat)
#' 
#' plot(an)
#' convergence(an)
#' coef(an)
#' summary(an)
#'  
#' # data()  
#' # ?peregrine  
#' # data(peregrine)
#' # summary(peregrine)
#' # demo()  
#' # demo(peregrine)
NULL