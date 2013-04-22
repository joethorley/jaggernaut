
#' @title JAGS analysis residuals
#'
#' @description
#' Calculate residuals with estimates using derived code 
#' in a JAGS analysis
#' 
#' @param object a jags_analysis object.
#' @param parm a character element naming the derived parameter for which 
#' the estimates should be calculated.
#' @param model an integer vector specifying the model to select. 
#' If model = 0 then it selects the model with the lowest DIC.
#' @param derived_code a character element defining a block in the JAGS dialect of 
#' the BUGS language that defines one or more derived parameters for each row of data. 
#' If NULL derived_code is as defined by the JAGS model for which the JAGS analysis was performed. 
#' @param random a named list which specifies which parameters to treat 
#' as random variables. If NULL random is as defined by the JAGS model for which the JAGS analysis was performed. 
#' @param level a numeric scalar specifying the significance level or a character
#' scalar specifying which mode the level should be taken from. By default the
#' level is as currently specified by \code{opts_jagr0} in the global options.
#' @param ... further arguments passed to or from other methods.
#' @return the input data frame with the median estimate and credibility intervals for the residuals
#' @seealso \code{\link{jags_model}} and \code{\link{jags_analysis}}
#' @method residuals jags_analysis
#' @export 
residuals.jags_analysis <- function (object, 
                                   parm = "residual", model = 1, 
                                   derived_code = NULL, random = NULL, 
                                   level = "current", ...) {
  old_opts <- opts_jagr0()
  on.exit(opts_jagr0(old_opts))
  
  if (!is.numeric(level)) {
    opts_jagr0(mode = level)
    level <- opts_jagr0("level")
    opts_jagr0(old_opts)
  }
  opts_jagr0(level = level)
  
  if (!is.jags_analysis(object))
    stop ("object should be class jags_analysis")  
  
  object <- subset(object, model = model)
  
  res <- calc_expected(object, 
                        parameter = parm, data = dataset(object), 
                        derived_model = derived_code, random = random, 
                        calc_estimates = T)
    
  rownames(res) <- NULL
  
  return (res)
  
}