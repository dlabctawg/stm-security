rm(list=ls())
cat('\014')
library(data.table)
library(stm)
library(stmBrowser)
library(stmCorrViz)

# load metadata
load("meta-security-fit.RData")

# load model object
load('stm-model.RData')

# describe topics
labelTopics(mod)

# browse the model
load('/Volumes/Iomega_HDD 1/CTAWG/speechID.speech.RData')
setkey(dt,speechID)
meta[,ftxt:=dt[meta$speechID,iconv(paste(name,substr(speech,0,10000),sep=': '),to='utf-8')]]
stmBrowser(mod=mod,data=meta,covariates=c('word.count','sep11','years','days','party','chamber'),text='ftxt',id='speechID',n=1000)
rm(dt)

# visualize prevalence https://github.com/bstewart/stm/issues/16
if(F){
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
}

# plot content perspectives

load('stm-model-cont-party.RData')
mod$settings$covariates$yvarlevels<-c('Dem','Rep','Other')
for(i in 1:10) {
	pdf(paste('images/content/party/topic',LETTERS[i],'.pdf',sep=''),width = 6,height = 4)
	plot.STM(mod,type='perspectives',topics=i,covarlevels=c('Dem','Rep'),main = paste('Topic',i,'term differences by party'),xlim=c(-1.5,1.5),text.cex = .75)
	dev.off()
	}

load('stm-model-cont-911.RData')
mod$settings$covariates$yvarlevels<-c('before','after')
for(i in 1:10) {
	pdf(paste('images/content/after911/topic',LETTERS[i],'.pdf',sep=''),width = 6,height = 4)
	plot.STM(mod,type='perspectives',topics=i,covarlevels=c('before','after'),main = paste('Topic',LETTERS[i],'change after September 11, 2001'),text.cex = .75)
	dev.off()
}

# inspect topic terms
load('stm-model.RData')
load('bow2stm-security.RData')
require(LDAvis,quietly = T)
require(servr,quietly = T)
require(data.table)

# called beta by stm, epsilon closest thing to zero the machine can represent, necessary to prevent error
top.word.phi.beta<-sapply(data.frame(mod$beta$logbeta),function(x) sapply(x,function(y) ifelse(is.infinite(y),.Machine$double.eps,exp(y))))
colnames(top.word.phi.beta)<-mod$vocab
doc.top.theta<-mod$theta
rownames(doc.top.theta)<-meta$speechID
doc.length<-sapply(bow2stm$documents,ncol)
tn<-data.table(do.call(rbind,sapply(bow2stm$documents, t)))
setnames(tn,c('ix','freq'))
setkey(tn,ix)
tn<-tn[,list('freq'=sum(freq)),by=ix]
term.frequency<-tn$freq
names(term.frequency)<-mod$vocab[tn$ix]

json <- createJSON(
	phi = top.word.phi.beta
	,theta = mod$theta
	,vocab = mod$vocab
	,doc.length = doc.length
	,term.frequency = term.frequency
	,reorder.topics = F
)
save(json,file='viz.RData')
serVis(json, out.dir = "vis", open.browser = T)
