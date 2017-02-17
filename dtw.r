#---------------------- Margot Selosse, Hoai Thu Nguyen -----------------------#
#----------------------------------- TER --------------------------------------# 
#--------------------------------- 2016/2017 ----------------------------------#

this.dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(this.dir)
rm(list=ls())

install.packages("dtw")
library(dtw)
library(parallel)

data <- read.csv("mat/2009_agg200.csv", header = T,sep = ",")
data.matrix <- as.matrix(data)
data.matrix.small <- data.matrix[1:10,1:100]

computeDTW <- function(i){
  template <- cos(data.matrix.small[i,])
  try <- dtw(data.matrix.small[i,], template)
  return(try)
}

# ncores = 6
# hosts <- c("localhost", "rpi1", "rpi2", "rpi3", "rpi4", "rpi5")
# cl <- makeCluster(rep(hosts, each=ncores/6), methods=F)
cl <- makeCluster(detectCores()-1)

clusterExport(cl, list("computeDTW","data.matrix.small","dtw"))
time <- system.time(
  res <- parLapply(cl, 1:(dim(data.matrix.small)[1]), fun = function(i) computeDTW(i))
)
res
stopCluster(cl)







