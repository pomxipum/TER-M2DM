#---------------------- Margot Selosse, Hoai Thu Nguyen -----------------------#
#----------------------------------- TER --------------------------------------# 
#--------------------------------- 2016/2017 ----------------------------------#

this.dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(this.dir)
rm(list=ls())

install.packages("dtw")
library(dtw)
library(parallel)


# data <- read.csv("mat/2009_agg200.csv", header = T,sep = ",")
# data.matrix <- as.matrix(data)
# save(data.matrix, file="data.matrix.RData")

load("data.matrix.RData")
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
# data.matrix <- data.matrix[1:10,]
# clusterExport(cl, list("computeDTW","data.matrix","dtw"))

data <- read.csv("mat/2009_agg200.csv", header = T,sep = ",")
save(data, file="data.RData")
load("data.RData")
data.matrix <- as.matrix(data)
data.matrix.small <- data.matrix[1:10,1:17000]

computeDTW <- function(i,j){
  try <- dtw(data.matrix.small[i,], data.matrix.small[j,])
  return(try)
}

computeDist <- function(i,j){
  try <- sqrt(sum((data.matrix[i,]-data.matrix[j,])^2))

}

cl <- makeCluster(detectCores()-2)


clusterExport(cl, list("computeDist","data.matrix.small","dtw"))
time.dist <- system.time(
  for(j in 1:(nrow(data.matrix.small)-1)){
    res <- parLapply(cl, (j+1):(nrow(data.matrix.small)), fun = computeDTW, j=j)
  }
)



res
stopCluster(cl)







