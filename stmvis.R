rm(list=ls())
cat('\014')
library(data.table)
library(stm)
library(stmBrowser)
library(stmCorrViz)

# load and clean metadata
load("meta-security-time.RData")
summary(meta)
setkey(meta,party)
meta['R',party:='Republican']
setkey(meta,party)
meta['D',party:='Democratic']
setkey(meta,party)
meta['I',party:='Independent']
setkey(meta,party)
meta['L',party:='N/A']
meta[,party:=droplevels(party)]
summary(meta)
setkey(meta,speechID)

# load model object
load('stm-model.RData')


# visualize
stmBrowser(mod=mod,data=meta,covariates=c('sep11','years','days','party','chamber'),text='name',id='speechID',n=1000)
