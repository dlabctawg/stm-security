rm(list=ls())
cat('\014')
library(stm)
require(data.table)


# Load metadata
load('meta-security-time.RData')

# recode
## party
meta[,.N,by=party]
setkey(meta,party)
meta['R',party:='Republican']
setkey(meta,party)
meta['D',party:='Democratic']
setkey(meta,party)
meta['I',party:='Other']
setkey(meta,party)
meta['Independent',party:='Other']
setkey(meta,party)
meta['L',party:='Other']
setkey(meta,party)
meta['N/A',party:='Other']
setkey(meta,party)
meta[,party:=droplevels(party)]
levels(meta$party)<-c("Other","Democratic","Republican" )
meta[,.N,by=party]
## period
meta[,after911:=factor(sep11>=0,labels=c('before','after'))]
meta[,partyXafter911:=interaction(party,after911,drop=T)]
save(meta,file='meta-security-fit.RData')


summary(meta)
setkey(meta,speechID)

# run provisional topic model testing that documents and metadata are properly sorted
## note that no covariates are used but content and prevalance terms could be easily added
t0<-proc.time()
cat(c(rep('#',10),' Fitting content = ~after911 ',rep('#',10),'\n\n'),sep='')
if(identical(names(bow2stm$documents),meta$speechID)) {
	mod<-stm(bow2stm$documents,bow2stm$vocab,K=10,data=meta,content = ~after911)
}
t1<-proc.time()
cat('STM model fit in',round((t1-t0)/60,2)[3],'minutes.')
save(mod,file='stm-model-cont-911.RData')

# run provisional topic model testing that documents and metadata are properly sorted
## note that no covariates are used but content and prevalance terms could be easily added
t0<-proc.time()
cat(c(rep('#',10),' Fitting content = ~party ',rep('#',10),'\n\n'),sep='')
if(identical(names(bow2stm$documents),meta$speechID)) {
	mod<-stm(bow2stm$documents,bow2stm$vocab,K=10,data=meta,content = ~party)
}
t1<-proc.time()
cat('STM model fit in',round((t1-t0)/60,2)[3],'minutes.')
save(mod,file='stm-model-cont-party.RData')

t0<-proc.time()
cat(c(rep('#',10),' Fitting prevalence = ~after911*party ',rep('#',10),'\n\n'),sep='')
if(identical(names(bow2stm$documents),meta$speechID)) {
	mod<-stm(bow2stm$documents,bow2stm$vocab,K=10,data=meta,prevalence = ~after911*party)
}
t1<-proc.time()
cat('STM model fit in',round((t1-t0)/60,2)[3],'minutes.')
save(mod,file='stm-model-prev.RData')
