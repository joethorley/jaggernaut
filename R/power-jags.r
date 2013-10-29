                                         
#' @export
power_jags <- function (object, parm = c(fixed = 0), level = "current") {
  if(!is.jags_power_analysis(object))
    stop("object must be a jags_power_analysis")
  
  if(!(is.numeric(parm) && is_named(parm)))
    stop("parm must be a named numeric vector")

  if(length(parm) == 0)
    stop("parm must contain at least one element")
       
  if (!is.numeric(level)) {
    if (level != "current") {
      old_opts <- opts_jagr(mode = level)
      on.exit(opts_jagr(old_opts))
    }
    level <- opts_jagr("level")
  }
     
  quiet <- opts_jagr("quiet")
  
  parms <- data.frame(parameter = NA, statistic = NA, comparison = NA, bound = NA)
  parms <- parms[-1,]
  
  chains <- chains(analyses(object)[[1]][[1]])
  
  for (i in seq_along(parm)) {
    df <- data.frame(parameter = expand_parm(chains, names(parm)[i], indices = TRUE))
    
    df$bound <- parm[i]
    
    parms <- rbind(parms, df)
  }
                
  rhat_threshold <- rhat_threshold(object)
  analyses <- analyses(object)
  
  
  melt_coef <- function (object, parm, level, rhat_threshold) {
    stopifnot(is.jagr_power_analysis(object))
        
    coef <- coef(object, parm = parm, level = level)
        
    coef$parameter <- rownames(coef) 
    coef <- reshape2::melt(coef, id.vars = c("parameter"), variable.name = "statistic", value.name = "number")
    
    if(!is_converged(object, rhat_threshold = rhat_threshold))
      is.na(coef$number) <- TRUE
    
    return (coef)
  }
        
  coef <- ldply_jg(analyses, melt_coef, parm = names(parm), level = level, rhat_threshold = rhat_threshold, .recursive = 2)
  
  coef$replicate <- paste0("replicate",as.integer(substr(coef$.id,10,15)))
  coef$value <- paste0("value",rep(1:nvalues(object), each = nrow(coef)/nvalues(object)))
  coef$.id <- NULL
  
  coef <- reshape2::dcast(coef,value + parameter + statistic ~ replicate,
                          value.var = "number")
  
  values <- values(object)
  values <- cbind(data.frame(value = row.names(values)),values)
  
  parms <- merge(values, parms)
  
  power <- merge(parms, coef)
      
  get_power <- function (d) {
    
    bound <- d$bound[1]
    lower <- d[d$statistic == "lower",substr(colnames(d),1,9) == "replicate"]
    upper <- d[d$statistic == "upper",substr(colnames(d),1,9) == "replicate"]
    niters <- length(lower)
    converged <- round(length(lower[!is.na(lower)]) / length(lower),2)
    samples <- length(lower[!is.na(lower)])
    bol <- !is.na(lower) & (lower > bound | upper < bound)
    out <- length(bol[bol])
    return (data.frame(bound = bound, niters = niters, converged = converged, samples = samples, out = out))
  }
  power <- ddply_jg(power,plyr::.(value,parameter,bound), get_power)
  power$power <- NA
  power$lower <- NA
  power$upper <- NA
  
  power[,c("power","lower","upper")] <- binomjags(n = power$samples, s = power$out)
  
  power <- merge(values, power, by = "value")
  
  power <- subset(power,select = c(colnames(values),"parameter","bound","niters",
                                   "converged","samples","out","power","lower",
                                   "upper"))
  
  return (power)
}
