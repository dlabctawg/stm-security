rm(list=ls())
cat('\014')
library(stm)
require(data.table)

# Load stm-formatted bag of words
load('bow2stm-security.RData')

# Load metadata
load('meta-security.RData')

# run provisional topic model testing that documents and metadata are properly sorted
## note that no covariates are used but content and prevalance terms could be easily added
t0<-proc.time()
if(identical(names(bow2stm$documents),meta$speechID)) {
	mod<-stm(bow2stm$documents,bow2stm$vocab,K=10,data=meta)
}
t1<-proc.time()
cat('STM model fit in',round((t1-t0)/60,2)[3],'minutes.')
save(mod,file='stm-model.RData')
