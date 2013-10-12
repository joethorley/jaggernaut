
#' @export
model <- function (object, ...) {
  UseMethod("model", object)
}

#' @export
"model<-" <- function (object, ...) {
  UseMethod("model<-", object)
}

model.jags_model <- function (object, ...) {
  stopifnot(is_one_model(object))
  return (models(object)[[1]])
}

#' @method model jags_power_analysis
#' @export 
model.jags_power_analysis <- function (object, ...) {
  return (object$model)
}

"model<-.jags_power_analysis" <- function (object, value, ...) {
  stopifnot(is.jags_model(value))
  object$model <- value
  return (object)
}