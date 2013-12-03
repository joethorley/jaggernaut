
#' @title Get dataset(s) from a JAGS object
#'
#' @description
#' Gets the dataset(s) from a JAGS object.  
#' 
#' @param object a JAGS object.
#' @param ... further arguments passed to or from other methods.
#' @return a data.frame, object of type \code{jags_data} or list(s) of the data
#' @seealso \code{\link{data_jags.jags_data_model}}  
#' @export
data_jags <- function (object, ...) {
  UseMethod("data_jags", object)
}

"data_jags<-" <- function (object, value) {
  UseMethod("data_jags<-", object)
}

#' @title Get dataset
#'
#' @description
#' Gets the dataset from a \code{jags_sample} object.  
#' 
#' @param object a \code{jags_sample} object.
#' @param ... further arguments passed to or from other methods.
#' @return The dataset.
#' @method data_jags jags_sample
#' @export
data_jags.jags_sample <- function (object, ...) {
  object <- object[,-grep("[[:digit:]]", colnames(object)), drop = FALSE]
  return (object)
}

#' @title Get dataset from a JAGS data model
#'
#' @description
#' Simulates a dataset from a \code{jags_data_model} object.  
#' 
#' @param object a \code{jags_data_model} object.
#' @param values a data.frame with a single row of data indicating the values 
#' for the simulation.
#' @param ... further arguments passed to or from other methods.
#' @return the simulated dataset in list form (unless modified by extract_data function).
#' @seealso \code{\link{data_jags}} and \code{\link{jags_data_model}}
#' @method data_jags jags_data_model
#' @export
data_jags.jags_data_model <- function (object, values, ...) { 
  if (!is.data.frame(values) || nrow(values) != 1)
    stop("values must be a data.frame with a single row")

  if (options()$jags.pb != "none") {
    jags.pb <- options()$jags.pb
    options(jags.pb = "none")
    on.exit(options("jags.pb" = jags.pb))
  }
  
  check_modules()
  
  values <- as.jags_data_frame(values)
  
  values <- translate_data(select(object), values)
  
  data <- values
  
  if (is.function(modify_data(object))) 
    data <- modify_data(object)(data)
  
  if (is.function(gen_inits(object))) {
    inits <- list()
    inits[[1]] <- gen_inits(object)(data)
  } else
    inits <- NULL
  
  file <- tempfile(fileext=".bug")
  cat(paste(model_code(object),"model { deviance <- 1}"), file=file)
    
  chains <- jags_analysis_internal (
    data = data, file = file, monitor = monitor(object), 
    inits = inits
  )

  est <- extract_estimates(chains)[["estimate"]]
  
  est$deviance <- NULL
    
  data <- clist(data, est)
  
  values <- values[!names(values) %in% names(data)]
  
  if (length(values))
    data <- clist(values, data)
  
  if(is.function(extract_data(object)))
    data <- extract_data(object)(data)
  
  data <- data[order(names(data))]
  
  return (as.jags_data(data))
}

#' @title Get dataset from a JAGS analysis object
#'
#' @description
#' Returns the original dataset from a \code{jags_analysis} object.  
#' 
#' @param object a \code{jags_analysis} object.
#' @param ... further arguments passed to or from other methods.
#' @return The original dataset as type \code{jags_data}.
#' @seealso \code{\link{data_jags}}, \code{\link{jags_analysis}},
#' \code{\link{jags_data}} and \code{\link{jaggernaut}}
#' @method data_jags jags_analysis
#' @export
data_jags.jags_analysis <- function (object, ...) {
  return (object$data)
}

#' @title Get datasets from a JAGS simulation
#'
#' @description
#' Extracts datasets from a \code{jags_simulation} object.  
#' 
#' @param object a \code{jags_simulation} object.
#' @param ... further arguments passed to or from other methods.
#' @return The datasets as a list of lists.
#' @seealso \code{\link{data_jags}} and \code{\link{jags_simulation}}
#' @method data_jags jags_simulation
#' @export
data_jags.jags_simulation <- function (object, ...) {  
  data <- object$data
  data <- name_object(data,c("value","replicate"))
  
  return (data)
}

"data_jags<-.jags_analysis" <- function (object, value) {
  stopifnot(is_data(value))

  object$data <- as.jags_data(value)
  
  return (object)
}

"data_jags<-.jags_simulation" <- function (object, value) {  
  stopifnot(is_list_list(value))
  stopifnot(is_scalar(unique(sapply(value,length))))
  stopifnot(length(value) == nvalues(object))
  
  object$data <- value
  
  return (object)
}
