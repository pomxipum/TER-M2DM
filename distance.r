#---------------------- Margot Selosse, Hoai Thu Nguyen -----------------------#
#----------------------------------- TER --------------------------------------# 
#--------------------------------- 2016/2017 ----------------------------------#
#!/usr/bin/env Rscript

# load libraries
library(optparse)

# Arguments
option_list = list(
  make_option(c("-f", "--file"), type="character", default="data.matrix.RData", 
              help="path to data.matrix.RData file [default= %default]",
              metavar="character"),
  make_option(c("-d", "--distance"), type="character", default="euclidean", 
              help="type of distance, between 'euclidean' and 'dtw' 
              [default= %default]", metavar="character"),
  make_option(c("-p", "--parallel"), type="logical", default=FALSE, 
              help="parallelize the calculation or not [default= %default]",
              metavar="logical"),
  make_option(c("--grain"), type="character", default="fine", 
              help="grain size in parallel computing (between coarse and fine) 
              [default= %default]", metavar="character"),
  make_option(c("-n", "--ncores"), type="integer", default=24, 
              help="number of cores used in the parallel computation, need to be
              a multiplication of 6 [default= %default]", metavar="integer")
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if ((opt$distance != "euclidean")&(opt$distance != "dtw")){
  print_help(opt_parser)
  stop("Type of distance unknown", call.=FALSE)
}

if ((opt$grain != "coarse")&(opt$grain != "fine")){
  print_help(opt_parser)
  stop("Size of grain unknown", call.=FALSE)
}

if (((opt$ncores %% 6)!= 0) | (opt$ncores == 0)){
  print_help(opt_parser)
  stop("Number of cores invalid", call.=FALSE)
}
#------------------------------------------------------------------------------#
#                                 FUNCTIONS                                    #
#------------------------------------------------------------------------------#
computeDTW <- function(i,j){
  try <- dtw(data.matrix[i,], data.matrix[j,])
  return(try$distance)
}

computeDist <- function(i,j){
  try <- sqrt(sum((data.matrix[i,]-data.matrix[j,])^2))
  return(try)
}

DTW <- function(){
  for (i in 1:(n-1)){
      res <- sapply((i+1):n, computeDTW, j=i)
  }
}

distEucl <- function(){
  for (i in 1:(n-1)){
    res <- sapply((i+1):n, computeDist, j=i)
  }
}

DTW.par.fine <- function(){
  for(i in 1:(n-1)){
    res <- parSapply(cl, (i+1):n, computeDTW, j=i)
  }
}

distEucl.par.fine <- function(){
  for(i in 1:(n-1)){
    res <- parSapply(cl, (i+1):n, computeDist, j=i)
  }
}

DTW.par.coarse <- function(){
  res <- clusterApplyLB(cl, 1:(n-1), function(i) sapply((i+1):n, computeDTW, j=i))
}

distEucl.par.coarse <- function(){
  res <- clusterApplyLB(cl, 1:(n-1), function(i) sapply((i+1):n, computeDist, j=i))
}
  
#------------------------------------------------------------------------------#
#                                  MAIN                                        #
#------------------------------------------------------------------------------#

# data <- read.csv("mat/2009_agg200.csv", header = T,sep = ",")
# data.matrix <- as.matrix(data)
# save(data.matrix, file="data.matrix.RData")

load("data.matrix.RData")
n <- nrow(data.matrix)
if (opt$distance == "dtw"){
  require("dtw")
  data.matrix <- data.matrix[,1:1000]
}
  
print(dim(data.matrix))

if (opt$parallel){
  require(parallel)
  hosts <- c("localhost", "rpi1", "rpi2", "rpi3", "rpi4", "rpi5")
  cl <- makeCluster(rep(hosts, each=opt$ncores/6), methods=F)
  
  if (opt$distance == "euclidean"){
    clusterExport(cl, list("computeDist", "data.matrix", "n"))
    if (opt$grain == "fine")
      print(system.time(distEucl.par.fine()))
    if (opt$grain == "coarse")
      print(system.time(distEucl.par.coarse()))
  }
    
  if (opt$distance == "dtw") {
    clusterExport(cl, list("dtw", "computeDTW", "data.matrix", "n"))
    if (opt$grain == "fine")
      print(system.time(DTW.par.fine()))
    if (opt$grain == "coarse")
      print(system.time(DTW.par.coarse()))
  }
  stopCluster(cl)
  print("Done!")
} else {
  if (opt$distance == "euclidean")
    print(system.time(distEucl()))
  if (opt$distance == "dtw") 
    print(system.time(DTW()))
}





