#---------------------- Margot Selosse, Hoai Thu Nguyen -----------------------#
#----------------------------------- TER --------------------------------------# 
#--------------------------------- 2016/2017 ----------------------------------#
#!/usr/bin/env Rscript

# load libraries
library(parallel)

hello <- function(i){
  pcname <- system('uname -n',intern=T) 
  x <- system("hostname -i", intern=T)
  x <- unlist(strsplit(x, " "))
  ip <- x[2]
  
  return(paste(pcname, "says hello from", ip))
}

hosts <- c("localhost", "rpi1", "rpi2", "rpi3", "rpi4", "rpi5")
cl <- makeCluster(hosts, methods=F)
clusterExport(cl,list("hello"))

res <- unlist(clusterApply(cl,1:6, hello))
for (i in 1:length(res))
  print(res[i])

stopCluster(cl)