
#' @title Get modify data derived
#'
#' @description
#' Get the modify_data_derived component of a JAGS object.  
#' 
#' @param object a JAGS object.
#' @param ... further arguments passed to or from other methods.
#' @return The modify_data_derived component of a JAGS object.
#' @seealso \code{\link{jaggernaut}}  
#' @export
modify_data_derived <- function (object, ...) {
  UseMethod("modify_data_derived", object)
}

#' @title Set modify data derived
#'
#' @description
#' Set the modify_data_derived component of a JAGS object.  
#' 
#' @usage
#' modify_data_derived(object) <- value
#' @param object a JAGS object.
#' @param value a function or NULL to replace the modify data derived fnction.
#' @seealso \code{\link{jaggernaut}}  
#' @export
"modify_data_derived<-" <- function (object, value) {
  UseMethod("modify_data_derived<-", object)
}

modify_data_derived.jagr_analysis_model <- function (object, ...) {
  return (object$modify_data_derived)
}

modify_data_derived_jagr_analysis_model <- function (object, ...) {
  stopifnot(is.jagr_analysis_model(object))
  return (modify_data_derived(object, ...))
}

#' @method modify_data_derived jags_model
#' @export
modify_data_derived.jags_model <- function (object, ...) {
  
  if(is_one_model(object))
    return (modify_data_derived(model(object), ...))
  
  models <- models(object)
  models <- lapply(models, modify_data_derived_jagr_analysis_model, ...)
  models <- name_object(models, "Model")
  return (models) 
}

#' @method modify_data_derived jags_analysis
#' @export
modify_data_derived.jags_analysis <- function (object, ...) {
  return (modify_data_derived(as.jags_model(object), ...))
}  

"modify_data_derived<-.jagr_analysis_model" <- function (object, value) {
  
  if(!is.null(value)) {
    if (!is.function(value)) {
      stop ("value must be NULL or a function")
    }
    args <- names(formals(value))
    if (!identical(args,c("data"))) {
      stop ("value argument must be named data")
    }
  }
  
  object$modify_data_derived <- value
  
  return (object)
}

#' @method modify_data_derived<- jags_model
#' @export
"modify_data_derived<-.jags_model" <- function (object, value) {
  
  if(is.list(value) && length(value) != nmodels(object))
    stop("if value is a list it must be the same length as the number of models in object")
  
  if(is.list(value))
    names(value) <- NULL
  
  models <- models(object)
  
  for (i in 1:length(models)) {
    if(!is.list(value)) {
      modify_data_derived(models[[i]]) <- value
    } else
      modify_data_derived(models[[i]]) <- value[[i]]
  }
  
  models(object) <- models
  return (object)
}

#' @method modify_data_derived<- jags_analysis
#' @export
"modify_data_derived<-.jags_analysis" <- function (object, value) {
  
  if (!is.null (value)) {
    if(!is.character(value)) {
      stop("modify_data_derived must be NULL or a character")
    }
    if (length(value) != 1) {
      stop ("modify_data_derived must be define a single model block")
    }
  }
  
  if(is.null(value))
    is.na(value) <- TRUE
  
  for (i in 1:nmodels(object))
    object$modify_data_derived[[i]] <- value
  
  return (object)
}
