rm(list=ls())
cat('\014')
library(data.table)
library(stm)
library(stmBrowser)
library(stmCorrViz)

# load and clean metadata
load("meta-security-fit.RData")


# load model object
load('stm-model-prev.RData')

# describe topics
labelTopics(mod)

# visualize https://github.com/bstewart/stm/issues/16
ef<-estimateEffect(c(9)~party*after911-1,stmobj = mod,metadata = meta,uncertainty = 'None')
p<-plot.estimateEffect(
	x=ef, covariate = 'party' ,moderator='after911',moderator.value = 'before'
	#,topics = c(9)
	,model = mod #, method = 'difference'
	,cov.value2 = "Republican"
	, cov.value1 = "Democratic"
	#,xlab = "More Conservative ... More Liberal"
	#,main = "Effect of Liberal vs. Conservative"
	,xlim = c(0, .1),verbose.labels=F
	#, labeltype = "custom",custom.labels = c('Dems Before', 'Dems After','Reps Before','Reps After','Other Before','Other After')
)
stmBrowser(mod=mod,data=meta,covariates=c('word.count','sep11','years','days','party','chamber'),text='name',id='speechID',n=1000)


# plot content perspectives

load('stm-model-cont-party.RData')
for(i in 1:10) {
	png(paste('images/content/party/topic',i,'.png',sep=''),width = 900,height = 600)
	plot.STM(mod,type='perspectives',topics=i,covarlevels=c('Democratic','Republican'),main = paste('Topic',i),xlim=c(-1.5,1.5))
	dev.off()
	}

load('stm-model-cont-911.RData')
mod$settings$covariates$yvarlevels<-c('before','after')
for(i in 1:10) {
	png(paste('images/content/after911/topic',i,'.png',sep=''),width = 900,height = 600)
	plot.STM(mod,type='perspectives',topics=i,covarlevels=c('before','after'),main = paste('Topic',i,'change after September 11, 2001'))
	dev.off()
}
