library(parallel)

x <- runif(2400000)

qsort <- function(i){
  load(paste("/home/pi/cloud/", "myx", i, ".RData", sep=""))
  sort(test, method="quick")
}

ncores = 6
nsamp = 100
samp <- x[sample(1:length(x), nsamp , replace=TRUE)]
qt <- quantile(samp, probs = seq(0,1, length = ncores+1))
ind <- cut(x, qt, include.lowest = TRUE) 
myx <- split(x, ind) 
for (i in 1:length(myx)){
  test <- myx[[i]]
  save(test, file = paste("/home/pi/cloud/", "myx", i, ".RData", sep=""))
}

hosts <- c("localhost", "rpi1", "rpi2", "rpi3", "rpi4", "rpi5")
cl <- makeCluster(rep(hosts, each=ncores/6), methods=F)
clusterExport(cl, list("qsort"))

bucket_sort <- function(ncores=24){
  res <- parSapply(cl, X=c(1:ncores), qsort)
  return(res)
}

# system.time(sort(x, method="quick"))
# system.time(bucket_sort())
