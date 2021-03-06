#' @title Create a JAGS model
#'
#' @description 
#' Creates a JAGS model object which defines a Bayesian model
#' in the JAGS dialect of the BUGS language.  In addition to defining the model
#' a JAGS model object can also specify the parameters to monitor, 
#' the variables to select, a function to manipulate the input data, a function
#' to generate all (or some) of the initial values and JAGS code
#' to predict derived values from the final model among other things.
#' 
#' @param model_code a character element defining the model in the JAGS dialect of 
#' the BUGS language
#' @param model_id string of name for model.
#' @param monitor a character vector of the parameters to monitor or a 
#' Perl regular expression as a string of the parameters to monitor
#' @param select_data a character vector of the variables to select from the 
#' data set being analysed (can also specify variables to transform and/or centre)
#' @param modify_data a function to modify the data set being analysed
#' (after it has been converted to list form)
#' @param gen_inits a function to generate initial values for an MCMC chain
#' (it is passed the (modified) data in list form)
#' @param derived_code a character element defining a model in the JAGS dialect
#'  of the BUGS language that specifies derived parameters
#' @param random_effects a named list of parameters to be treated as random effects with the
#' related data as values
#' @param select_data_derived a character vector of the variables to select from the 
#' data set being analysed (can also specify variables to transform and/or centre)
#' @param modify_data_derived a function to modify the derived data set 
#' (after it has been converted to list form)
#' @details 
#' The \code{jags_model} function defines a JAGS model that can then be passed to the 
#' \code{jags_analysis} function together with a data frame to perform a Bayesian analysis.
#' The idea is that a JAGS model can be defined once and then used to perform 
#' analyses on different data frames. The only argument that 
#' needs to be set is a character element defining the model block in the JAGS dialect of the 
#' the BUGS language. However various other arguments can also be set 
#' to provide additional control. 
#' 
#' The \code{monitor} argument is used
#' to define the parameters in the model to monitor - by default all model parameters
#' are monitored except those that begin with the character d, e or i and are followed by an 
#' any upper case character, i.e., \code{eCount} would not be monitored while \code{bIntercept}
#' and \code{ecount} would. 
#' 
#' If \code{select_data} is \code{NULL} (the default) all variables in the
#' data frame are passed to the analysis.  If select_data is defined then only those
#' variables named in select_data are passed to the analysis. As a warning is given if a 
#' variable named in select_data is not in the data frame this can be useful for ensuring
#' all the required variables are present in the data frame.
#' 
#' In addition if
#' a variable name in select is followed by a * then the variables is standardised by
#' substracting its mean and then dividing by its standard deviation
#' before
#' it is passed to the analysis i.e., \code{select_data=c("Weight", "Length*")}
#'  would result in \code{Length} being
#' standardised in the analysis while \code{select_data=c("Weight", "Length")} would not. A transformation can also
#' be applied to a variable - for example the
#'  argument \code{select_data=c("Weight", "log(Length)*")} would result in 
#' \code{Length} being logged and then standardised. 
#' 
#' Once the \code{select_data} argument has been applied to the the data, dates and factors are converted
#' into integers and the data frame is converted into list form for input into JAGS. 
#' As well as each variable the list also contains a named element for each
#' factor that gives the number of levels of the factor. For example if the factor 
#' \code{Type} with three levels is present in the input data then an addition element
#' would be created in the list of data with the name \code{nType} and value three. This is useful
#' for iterating over factor levels in the JAGS model code.
#' 
#' In some cases additional manipulations of the data may be required such as
#' conversion of variables into matrix or array form based on input factor levels.
#' This can be achieved by defining a function for the \code{modify_data} argument. The function
#' will be passed the data in list form and should return an updated list of the modified data. 
#' 
#' At this point initial values can be generated for one or more of the model parameters
#' using the \code{gen_inits} argument which expects a function that takes the list of data
#' and returns a list of the initial values - the function is called once for each chain
#' and should therefore use random generation of initial values if different starting
#' values are desired. The remaining arguments are used after the analysis has completed. 
#' 
#' The \code{derived_code} argument is used to define a model in the JAGS dialect of 
#' the BUGS language that specifies derived parameters. 
#' For further information on the use of the \code{derived_code} argument see
#'  \code{\link{predict.jags_analysis}}.
#' 
#' The \code{random_effects} argument is used specify which parameters represent random effects.
#' It takes 
#' the form of a named list where the parameters are the names of the list elements 
#' and the values are character vectors of the variables in the input data frame that
#' the parameters are random with respect to. For further information on the
#' use of the \code{random_effects} argument see the \code{predict} function.
#' @return a \code{jags_model} object
#' @references  
#' Plummer M (2012) JAGS Version 3.3.0 User Manual \url{http://sourceforge.net/projects/mcmc-jags/files/Manuals/}
#' @seealso \code{\link{jags_analysis}}
#' and \code{\link{jaggernaut}} 
#' @examples
#' 
#' model <- jags_model("
#' model { 
#'  bLambda ~ dlnorm(0,10^-2) # $\\lamda$
#'  for (i in 1:length(x)) { 
#'    x[i]~dpois(bLambda) 
#'  } 
#'}")
#'
#' print(model)
#' nmodels(model)
#' model_code(model)
#' @export 
jags_model <- function (model_code,
                        model_id = NULL,                        
                        monitor = "^([^dei]|.[^A-Z])", 
                        select_data = NULL, 
                        modify_data = NULL, 
                        gen_inits = NULL, 
                        derived_code = NULL, 
                        random_effects = NULL,
                        select_data_derived = NULL,
                        modify_data_derived = NULL
                        ) { 
  
  model <- jagr_model(model_code = model_code, 
                      model_id = model_id,                      
                      monitor = monitor, 
                      select_data = select_data,
                      modify_data = modify_data,
                      gen_inits = gen_inits,
                      derived_code = derived_code,
                      random_effects = random_effects,
                      select_data_derived = select_data_derived,
                      modify_data_derived = modify_data_derived
                      )
  
  object <- list(models = list(model))
  
  class(object) <- "jags_model"
  
  rename_models(object)
}
