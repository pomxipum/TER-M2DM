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

computeDTW <- function(i){
  template <- cos(data.matrix[i,])
  try <- dtw(data.matrix[i,], template)
  return(try)
}

# ncores = 6
# hosts <- c("localhost", "rpi1", "rpi2", "rpi3", "rpi4", "rpi5")
# cl <- makeCluster(rep(hosts, each=ncores/6), methods=F)
cl <- makeCluster(detectCores()-1)
data.matrix <- data.matrix[1:10,1:10]
clusterExport(cl, list("computeDTW","data.matrix","dtw"))
time <- system.time(
  res <- parLapply(cl, 1:(dim(data.matrix)[1]), fun = function(i) computeDTW(i))
)








