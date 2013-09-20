context("data_jags")

test_that("data_jags.jags_data_model", {
  
  data_model <- jags_data_model("
data {
 for (i in 1:nx) {
   x[i] ~ dpois(bIntercept)
   for (j in 1:nx) {
     y[i,j] ~ dpois(bIntercept)
   }
 }
 z <- bIntercept
}
")
  
  values <- data.frame(nx = 10, bIntercept = 5)
  
  data <- data_jags(data_model, values)
    
  expect_that(data, is_a("list"))
  expect_that(names(data), is_identical_to(c("x","y","z")))
  expect_that(length(data$x), equals(10))
  expect_that(dim(data$y), equals(c(10,10)))
})

test_that("data_jags.jags_data_model", {
  
  model <- jags_model("
model {
 bLambda ~ dlnorm(0, 10^-2)
                      for (i in 1:nrow) {
                      x[i]~dpois(bLambda)
                      }
}")

  data <- data.frame(x = rpois(100,10))
  
  analysis <- jags_analysis (model, data, mode = "test")
  
  data <- data_jags(analysis)
  datab <- data_jags(analysis, base = TRUE)
    
  expect_that(data, is_a("data.frame"))
  expect_that(datab, is_a("data.frame"))
  expect_that(nrow(data), equals(100))
  expect_that(nrow(datab), equals(1))
  expect_that(colnames(data), is_identical_to("x"))
  expect_that(colnames(datab), is_identical_to("x"))
})

test_that("data_jags.jags_simulation", {
  
  data_model <- jags_data_model("
data {
 for (i in 1:nx) {
                                x[i] ~ dpois(bIntercept)
                                for (j in 1:nx) {
                                y[i,j] ~ dpois(bIntercept)
                                }
}
                                z <- bIntercept
                                }
                                ")

values <- data.frame(nx = c(1,10), bIntercept = c(5,10))

simulation <- jags_simulation (data_model, values, nrep = 5, mode = "test")

data1 <- data_jags(simulation)
data2 <- data_jags(simulation, value = 1, rep = NULL)
data3 <- data_jags(simulation, value = NULL, rep = 1)
data4 <- data_jags(simulation, value = NULL, rep = NULL)
  
  expect_that(data1, is_a("numeric"))
  expect_that(data2, is_a("list"))
  expect_that(data3, is_a("list"))
  expect_that(data4, is_a("list"))
  
  expect_that(length(data1), equals(3))
  expect_that(length(data2), equals(5))
  expect_that(length(data3), equals(2))
  expect_that(length(data4), equals(2))
  
  expect_that(names(data1), is_identical_to(c("x","y","z")))
  expect_that(data1, is_identical_to(data2[[1]]))
  expect_that(data1, is_identical_to(data3[[1]][[1]]))
  expect_that(data1, is_identical_to(data4[[1]][[1]]))
})
