
jagr_analysis_model <- function (model_code, monitor = NULL, select = NULL, 
                                 modify_data = NULL, gen_inits = NULL, 
                                 derived_code = NULL, 
                                 random_effects = NULL,
                                 select_derived = NULL,
                                 modify_data_derived = NULL) {  
  
  if(!is.null(select_derived))
    select <- select_derived
  
  object <- jagr_model(model_code = model_code,
                       monitor = monitor, 
                       select = select,
                       modify_data = modify_data,
                       gen_inits = gen_inits)
  
  class(object) <- c("jagr_analysis_model","jagr_model")
  
  derived_code(object) <- derived_code
  random_effects(object) <- random_effects
  
  if(is.null(modify_data_derived))
    modify_data_derived <- modify_data
  
  modify_data_derived(object) <- modify_data_derived
  
  return (object)
}
