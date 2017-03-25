library(reshape) # melt

fileURL = 'https://www.bls.gov/lau/staadata.txt'
download.file(fileURL, destfile = 'staadata.txt')

# Read in file; set widths to match file format #### 
dat = read.fwf('staadata.txt', 
                 skip = 18, 
                 strip.white = T, 
                 stringsAsFactors = F,
                 widths = c(17, 14, 14, 10, 14, 10, 13, 9))

# Set column names
colnames(dat) = c('Year',
                  'Population',
                  'CivilianLaborForce',
                  'CivilianLaborForcePCT',
                  'Employment',
                  'EmploymentPCT',
                  'Unemployment',
                  'UnemploymentPCT')

# Remove rows where Unemployment is NA -- removes all lines w/o data 
# df = dat[is.na(dat$UnemploymentPCT),]
dat = dat[!is.na(dat$UnemploymentPCT),]

# Remove dots, trailing whitespace, and commas to turn numbers into numeric
dat$Year = gsub('\\.', '', dat$Year)
dat$Year = trimws(dat$Year, "r")
dat$Population = as.numeric(gsub(',', '', dat$Population))
dat$CivilianLaborForce = as.numeric(gsub(',', '', dat$CivilianLaborForce))
dat$Employment = as.numeric(gsub(',', '', dat$Employment))
dat$Unemployment = as.numeric(gsub(',', '', dat$Unemployment))

minY = as.numeric(min(dat$Year))
maxY = as.numeric(max(dat$Year))
years = maxY-minY+1

states = state.name
states = sort(append(states, 'District of Columbia'))
states = append(states, c('Los Angeles County',
                          'New York city'))

State = rep(states, each = years)

dat$State = State

dat = subset(dat, select = c('State',
                             'Year',
                             'CivilianLaborForcePCT',
                             'EmploymentPCT',
                             'UnemploymentPCT'))

dat = melt(dat, id.vars = c('State', 'Year'))
colnames(dat)[3:4] = c('Variable', 'Value')

dat$Variable = gsub('CivilianLaborForcePCT', 'Labor force participation', dat$Variable)
dat$Variable = gsub('EmploymentPCT', 'Total employment', dat$Variable)
dat$Variable = gsub('UnemploymentPCT', 'Unemployment', dat$Variable)

dat = dat[dat$Year >= 1990,]

write.csv(dat, 'laborforce.csv', row.names = F)