
#' @title Bayesian Analysis with JAGS
#'
#' @description 
#' An R package to facilitate Bayesian analysis
#' using JAGS (Just Another Gibbs Sampler).
#' 
#' @details
#' In short an analysis proceeds first by the 
#' definition of the JAGS model in BUGS code using
#' the \code{\link{jags_model}} function. Multiple models can be
#' combined in a single \code{jags_model} object using \code{\link{combine}}.
#' Next the resultant \code{jags_model} object is passed together with 
#' a data set to 
#' the \code{\link{jags_analysis}} function which calls the JAGS software to 
#' perform the actual MCMC
#' sampling.  The resultant \code{jags_analysis} object can then be passed
#' to the \code{\link{plot.jags_analysis}} function to view the MCMC traces, the 
#' \code{\link{rhat}} function to check the Rhat values of individual parameters
#' and the \code{\link{coef.jags_analysis}} function to get the parameter estimates
#' with  credible limits.  The \code{\link{predict.jags_analysis}} function can
#' then be used to extract derived parameter estimates with credible intervals
#' from a \code{jags_analysis} object without the need for further
#' MCMC sampling.
#' 
#' 
#' Dummy data sets are generated by first using the \code{\link{jags_data_model}}
#' function to define the underlying model in BUGS code. Next the resultant
#' \code{jags_data_model} object is passed to the \code{\link{jags_simulation}}
#' function together with a data frame specifying the values of particular parameters.
#' The generated data sets can then be extracted using the \code{\link{data_jags}}
#' function. 
#' 
#' A power analysis is performed in a similar manner except the \code{jags_data_model}
#' object is passed to the \code{\link{jags_power_analysis}} function together the
#' values data frame and a \code{\link{jags_model}} object. The power estimates
#' are extracted from the \code{jags_power_analysis} object using the 
#' \code{\link{power_jags}} function.
#' 
#' Options are queried and set using the \code{\link{opts_jagr}} function.
#' 
#' The data sets accompanying this package are those used in the real 
#' examples in Kery and Schaub's (2011) book Bayesian Population Analysis 
#' using WinBUGS.
#' To see all available data sets type 
#' \code{data()}.  To get further information on for example 
#' the \code{peregrine}
#' data set type \code{?peregrine}.
#' 
#' For illustrative purposes the 
#' examples in Kery and Schaub (2011) are in the process of being implemented 
#' in jaggernaut as demos. To see the available demos type \code{demo()}.
#' To run the demo for the peregrine data set use the command \code{demo(peregrine)}.
#' 
#' Please report any bugs or pass on any comments
#' or requests to the package maintainer at \email{<joe@@poissonconsulting.ca>}.
#'
#' @references 
#' Kery M & Schaub M (2011) Bayesian Population Analysis
#' using WinBUGS. Academic Press. (\url{http://www.vogelwarte.ch/bpa})
#' 
#' Plummer M (2012) JAGS Version 3.3.0 User Manual \url{http://sourceforge.net/projects/mcmc-jags/files/Manuals/}
#' 
#' @docType package
#' @import abind reshape2 plyr coda rjags assertthat
#' @name jaggernaut
#' @aliases package-jaggernaut
#' @seealso \code{\link{jags_model}},
#' \code{\link{jags_analysis}}, \code{\link{jags_data_model}}, 
#' \code{\link{jags_simulation}}, \code{\link{jags_power_analysis}} 
#' and \code{\link{opts_jagr}}.
#' @examples
#' 
#' mod <- jags_model("
#' model { 
#'  bLambda ~ dlnorm(0,10^-2) 
#'  for (i in 1:length(x)) { 
#'    x[i]~dpois(bLambda) 
#'  } 
#'}")
#'
#' dat <- data.frame(x = rpois(100,1))
#' 
#' an <- jags_analysis (mod, dat, mode = "demo")
#' 
#' plot(an)
#' rhat(an)
#' coef(an)
#' summary(an)
#'  
#'  
#' \dontrun{ 
#' 
#' data(package = "jaggernaut")  
#' ?peregrine  
#' data(peregrine)
#' summary(peregrine)
#' demo(package = "jaggernaut")
#' demo(peregrine)
#' }
NULL
