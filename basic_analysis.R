# We may use ggplot2 for more advanced graphs
library(ggplot2)

# Read GPD by Industry tables
GDPbyInd_US <- read.csv("data/RealGrossOutputbyIndustry_US.csv")
GDPbyInd_VT <- read.csv("data/RealGrossOutputbyIndustry_VT.csv")

# The Industry codes used in the state dataset do not match those used by the national dataset
# This forces state codes to national codes using fuzzy matching 
NIACS <- read.csv("data/NIACS.csv")
for (State_IND in levels(GDPbyInd_VT$Industry.Description)) {
  best <- which.min(adist(State_IND, NIACS$Industry.Description))
  if (length(best) != 1){
    warning(paste("multiple 'best' matches found for ",State_IND))
  }
  GDPbyInd_VT$Industry[GDPbyInd_VT$Industry.Description == State_IND] <- levels(factor(NIACS$Industry[best]))
}
GDPbyInd_VT$Industry <- factor(GDPbyInd_VT$Industry)

# Get the NIACS code for our target industry
IT_niacs <- NIACS$Industry[agrep("Data processing, internet publishing, and other information services", 
                                 NIACS$Industry.Description)]
IT_niacs <- levels(factor(IT_niacs))

# Show the Industries that are a subset of our target industry
# NIACS[grep(paste0("^",IT_niacs), NIACS$Industry),]
# No subsets in my case, so commenting out.

qplot(data=subset(GDPbyInd_VT, Industry == IT_niacs), x=Year, y=GDP..Millions.Chained.2009.) + geom_smooth(method=lm) 
qplot(data=subset(GDPbyInd_US, Industry == IT_niacs), x=Year, y=GDP..Billions.Chained.2009.) + geom_smooth(method=lm)
 

# Create a list of Linear Regressions of change in GDP for each Industry
US_GDP_models <- sapply(levels(GDPbyInd_US$Industry), function(IND){lm(GDP..Billions.Chained.2009. ~ Year,
                                                                       data=subset(GDPbyInd_US, Industry == IND))})
VT_GDP_models <- sapply(levels(GDPbyInd_VT$Industry), function(IND){lm(GDP..Millions.Chained.2009. ~ Year,
                                                                     data=subset(GDPbyInd_VT, Industry == IND))})

# Plot Trends for US
#plot(NA, xlim=c(2005,2015), ylim=c(0,max(GDPbyInd_US$GDP..Billions.Chained.2009.)))
#for (col in 1:ncol(US_GDP_models)) {
#  abline(US_GDP_models[,col])
#}

# Identify Industries with positive/strong growth
dotchart(sapply(US_GDP_models["coefficients",], 
                function(var){return(var)})[2,grep("^[0-9]{2}[A-Z]*$", colnames(US_GDP_models))])
dotchart(sapply(US_GDP_models["coefficients",], 
                function(var){return(var)})[2,grep("^[0-9]{3,}[A-Z]*$", colnames(US_GDP_models))])
dotchart(sapply(US_GDP_models["coefficients",], 
                function(var){return(var)})[2,grep("^[A-Z]*$", colnames(US_GDP_models))])


dotchart(sapply(VT_GDP_models["coefficients",], 
                function(var){return(var)})[2,grep("^[0-9]{2}[A-Z]*$", colnames(VT_GDP_models))])
dotchart(sapply(VT_GDP_models["coefficients",], 
                function(var){return(var)})[2,grep("^[0-9]{3,}[A-Z]*$", colnames(VT_GDP_models))])
dotchart(sapply(VT_GDP_models["coefficients",], 
                function(var){return(var)})[2,grep("^[A-Z]*$", colnames(VT_GDP_models))])


top_growth_VT <- sort(sapply(VT_GDP_models["coefficients",], 
                             function(var){return(var)})[2,grep("^[0-9]{2,}[A-Z]*$", colnames(VT_GDP_models))],
                      decreasing=TRUE)[1:10]

top_growth_US <- sort(sapply(US_GDP_models["coefficients",], 
                             function(var){return(var)})[2,grep("^[0-9]{2,}[A-Z]*$", colnames(US_GDP_models))],
                      decreasing=TRUE)[1:10]

top_growth <- intersect(names(top_growth_US), names(top_growth_VT))

subset(NIACS, Industry %in% c(IT_niacs, top_growth))

qplot(data=subset(GDPbyInd_US, Industry %in% c(IT_niacs, top_growth)),
      x=Year, y=GDP..Billions.Chained.2009., colour=Industry) + geom_smooth(method=lm)

qplot(data=subset(GDPbyInd_VT, Industry %in% c(IT_niacs, top_growth)),
      x=Year, y=GDP..Millions.Chained.2009., colour=Industry) + geom_smooth(method=lm)

# A look at Value added by Industry
VADDbyInd_US <- read.csv("data/RealValueAddedbyIndustry_US.csv")

qplot(data=subset(VADDbyInd_US, Industry %in% c(IT_niacs, top_growth)),
      x=Year, y=Value.Added..Billions.Chained.2009., colour=Industry) + geom_smooth(method=lm)

# A look at Income by County
RegionalIncome_VT <- read.csv("data/RegionalIncome_VT.csv")
qplot(data=RegionalIncome_VT, x=Total.Personal.Income..Thousands., y=Population, colour=Location)

qplot(data=RegionalIncome_VT, x=Year, y=Population, colour=Location) + geom_smooth(method=lm)
qplot(data=RegionalIncome_VT, x=Year, y=Total.Personal.Income..Thousands., colour=Location) + geom_smooth(method=lm)
qplot(data=RegionalIncome_VT, x=Year, y=Total.Personal.Income..Thousands./Population, colour=Location) + geom_smooth(method=lm)

VT_Income_models <- sapply(levels(RegionalIncome_VT$Location), 
                        function(LOC){lm(Total.Personal.Income..Thousands./Population ~ Year, 
                                         data=subset(RegionalIncome_VT, Location == LOC))})

dotchart(sapply(VT_Income_models["coefficients",], function(var){return(var)})[2,])


