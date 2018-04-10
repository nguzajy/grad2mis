require(RPostgreSQL)
require(reshape2)
require(tables)
require(plyr)

options(knitr.table.format="html")
options(scipen=999) #avoids printing exponential notations such 1e+10

options(warn = -1) #suppresses warnings

setwd("~/grad2mis") #sets directory
source("sitesettings.R")

drv<-dbDriver("PostgreSQL")
con<-dbConnect(drv, user= dbUserName, password=dbPassword,host=dbHost, port=dbPort,dbname=dbName)

#Gets a list of of VESA, PSNP and Saving amount
sql.saving<-paste0("select tedv.lastupdated::DATE as report_date, reg.name as Region, 
zon.name as Zone, wor.name as Woreda, keb.name as Kebele, 
ves.name as VESA, teav.value as PSNP_number, tedv.value as Saving from _orgunitstructure ous
INNER JOIN organisationunit ves ON ous.idlevel6 = ves.organisationunitid
INNER JOIN organisationunit keb ON ous.idlevel5 = keb.organisationunitid
INNER JOIN organisationunit wor ON ous.idlevel4 = wor.organisationunitid
INNER JOIN organisationunit zon ON ous.idlevel3 = zon.organisationunitid
INNER JOIN organisationunit reg ON ous.idlevel2 = reg.organisationunitid
INNER JOIN trackedentityinstance tei ON ves.organisationunitid = tei.organisationunitid 
inner join trackedentityattributevalue teav ON tei.trackedentityinstanceid = teav.trackedentityinstanceid 
inner join programinstance pi ON pi.trackedentityinstanceid = teav.trackedentityinstanceid 
inner join programstageinstance psi ON psi.programinstanceid = pi.programinstanceid 
inner join  trackedentitydatavalue tedv ON tedv.programstageinstanceid = psi.programstageinstanceid
WHERE teav.trackedentityattributeid = 2093 and tedv.dataelementid = 2074 and 
tedv.lastupdated BETWEEN  date_trunc('second', now()::timestamp)  - interval '90 days' AND date_trunc('second', now()::timestamp);")

#Gets a list of of VESA, PSNP and Saving amount
sql.loan<-paste0("select tedv.lastupdated::DATE as report_date, reg.name as Region, 
zon.name as Zone, wor.name as Woreda, keb.name as Kebele, 
ves.name as VESA, teav.value as PSNP_number, tedv.value as Loan from _orgunitstructure ous
INNER JOIN organisationunit ves ON ous.idlevel6 = ves.organisationunitid
INNER JOIN organisationunit keb ON ous.idlevel5 = keb.organisationunitid
INNER JOIN organisationunit wor ON ous.idlevel4 = wor.organisationunitid
INNER JOIN organisationunit zon ON ous.idlevel3 = zon.organisationunitid
INNER JOIN organisationunit reg ON ous.idlevel2 = reg.organisationunitid
INNER JOIN trackedentityinstance tei ON ves.organisationunitid = tei.organisationunitid 
inner join trackedentityattributevalue teav ON tei.trackedentityinstanceid = teav.trackedentityinstanceid 
inner join programinstance pi ON pi.trackedentityinstanceid = teav.trackedentityinstanceid 
inner join programstageinstance psi ON psi.programinstanceid = pi.programinstanceid 
inner join  trackedentitydatavalue tedv ON tedv.programstageinstanceid = psi.programstageinstanceid
WHERE teav.trackedentityattributeid = 2093 and tedv.dataelementid = 2073 and 
tedv.lastupdated BETWEEN  date_trunc('second', now()::timestamp)  - interval '90 days' AND date_trunc('second', now()::timestamp);")

savingAmount <-dbGetQuery(con,sql.saving)
loanAmount <-dbGetQuery(con,sql.loan)

#Summarize and aggregate the savings data
savingAmount <- ddply(savingAmount, .(report_date, region,zone,woreda,kebele,vesa,psnp_number), summarise, saving_amount=sum(as.numeric(saving)))


#Summarize and aggregate the loans data
loanAmount <- ddply(loanAmount, .(report_date, region,zone,woreda,kebele,vesa,psnp_number), summarise, loan_amount=sum(as.numeric(loan)))