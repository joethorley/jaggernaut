
check_modules <- function () {
if(!"basemod" %in% list.modules())
  load.module("basemod")  

if(!"bugs" %in% list.modules())
  load.module("bugs")

 invisible()
}
