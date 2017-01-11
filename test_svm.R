load("/home/pi/cloud/mnist_cut.RData")

library(caret)
time <- system.time(train(X1 ~ ., data = digits, method = "svmRadial"))

library(parallel)
library(doParallel)

ncores = 24
hosts <- c("localhost", "rpi1", "rpi2", "rpi3", "rpi4", "rpi5")
cl <- makeCluster(rep(hosts, each=ncores/6), methods=F)
registerDoParallel(cl)

time_par <- system.time(train(X1 ~ ., data = digits, method = "svmRadial"))

save(time, time_par, file='~/cloud/time_svm.RData')