#install.packages("NbClust")
library(NbClust)

data <- read.table("/Users/carissamayo/Year3/CSCI3352/CSproject/latlongs.txt", header = TRUE, quote = "\"")
plot(data)

res <- NbClust(data, distance = "euclidean", min.nc = 2, max.nc = 15, method = "ward.D2",
               index = "duda")
res$All.index
res$Best.nc
res$All.CriticalValues
res$Best.partition

dat <- data.frame(res$Best.partition)

write.csv(dat,"/Users/carissamayo/Year3/CSCI3352/CSproject/partition.csv", row.names = FALSE)
