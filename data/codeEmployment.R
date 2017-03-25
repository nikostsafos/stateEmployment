library(tidyr) # spread
library(reshape) # melt

# fileURL: 'https://download.bls.gov/pub/time.series/sm/'
# file: sm.data.1.AllData
# download file and save as AllData.tsv

# Data cleaning
dat = read.table('AllData.tsv', sep="\t", header=TRUE, stringsAsFactors = F)
dat$Survey = substring(dat$series_id, 0,2)
dat$Seasonal = substring(dat$series_id, 3,3)
dat$State = substring(dat$series_id, 4,5)
dat$Area = substring(dat$series_id, 6,10)
dat$Sector = substring(dat$series_id, 11,12)
dat$Industry = substring(dat$series_id, 11,18)
dat$Data = substring(dat$series_id, 19,20)
dat$period <- gsub("M","", dat$period) 
dat$value = as.numeric(dat$value)
dat = dat[ dat$year >= 1990,]
dat$year = as.Date(paste(dat$year, '01', '01', sep = '-'), format = '%Y-%m-%d')
# dat <- transform(dat, value = as.numeric(levels(value)[value]))

## Extract annual data and subset data after 1990
dat = dat[dat$period == '13',]
dat = dat[,c(2, 8:12, 4)] # take out Survey (all SM) and seasonal (all U)

# Subset data ####
df = dat[dat$Data == '01',] # All Employees, In Thousands
df = df[df$Area == '00000', ] # Select states only 
df$Industry = substring(df$Industry, 3,8) # Extract industry information 
df = df[df$Industry == '000000', ] # Select only total industry-level information 
df = df[,c(1:2,4,7)]

df = spread(df, Sector, value)

sectors = colnames(df)[3:24]
df$`05` = (df$`05`/df$`00`)*100
df$`06` = (df$`06`/df$`00`)*100
df$`07` = (df$`07`/df$`00`)*100
df$`08` = (df$`08`/df$`00`)*100
df$`10` = (df$`10`/df$`00`)*100
df$`15` = (df$`15`/df$`00`)*100
df$`20` = (df$`20`/df$`00`)*100
df$`30` = (df$`30`/df$`00`)*100
df$`31` = (df$`31`/df$`00`)*100
df$`32` = (df$`32`/df$`00`)*100
df$`40` = (df$`40`/df$`00`)*100
df$`41` = (df$`41`/df$`00`)*100
df$`42` = (df$`42`/df$`00`)*100
df$`43` = (df$`43`/df$`00`)*100
df$`50` = (df$`50`/df$`00`)*100
df$`55` = (df$`55`/df$`00`)*100
df$`60` = (df$`60`/df$`00`)*100
df$`65` = (df$`65`/df$`00`)*100
df$`70` = (df$`70`/df$`00`)*100
df$`80` = (df$`80`/df$`00`)*100
df$`90` = (df$`90`/df$`00`)*100
df$`00` = (df$`00`/df$`00`)*100

df = melt(df, id.vars = c('year', 'State'))

colnames(df) = c('Year', 'State', 'Sector', 'Value')

# Exclude high-level aggregations
df = df[!df$Sector %in% c('00', # Total Nonfarm 
                          '05', # Total Private
                          '06', # Goods Producing
                          '07', # Service-Providing
                          '08', # Private Service Providing
                          '15', # Mining, Logging, and Construction
                          # '30', # Manufacturing
                          '31', # Durable goods
                          '32', # Non-durable goods
                          '40'),] # Trade, Transportation, and Utilities	

df = df[!df$State %in% c('72', # Puerto Rico
                         '78'),] # Virgin Islands

sectorCode = read.table('backup/sector.tsv', sep = '\t', header = T, row.names = NULL)
sectorCode = sectorCode[,c(1:2)]
colnames(sectorCode) = c('Sector', 'SectorName')
df = merge(df, sectorCode, by.df = 'Sector', by.sectorCode = 'Sector')
df = df [,c(3,5,2,4)]
rm(sectorCode)

stateCode = read.table('backup/states.tsv', sep = '\t', header = T, row.names = NULL)
stateCode = stateCode[,c(1:2)]
colnames(stateCode) = c('State', 'StateName')
df = merge(df, stateCode, by.df = 'State', stateCode = 'State')
rm(stateCode)
df = df [,c(5,2:4)]
df = na.omit(df)
colnames(df) = c('State', 'Sector', 'Year', 'Value')

df = spread(df, Sector, Value)
df$Year <- format(df$Year, "%Y") ## create year column 
df = melt(df, id.vars = c('State', 'Year'))
colnames(df) = c('State', 'Year', 'Sector' ,'Value')
df$Year = as.numeric(df$Year)
write.csv(df, 'employment.csv', row.names = F)
