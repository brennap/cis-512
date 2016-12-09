# We may use ggplot2 for more advanced graphs
library(ggplot2)

# Create directory for plots
if (!dir.exists("plots")){
  dir.create("plots")
}
Report <- file("report.txt", open="wt")
writeLines("Basic Analysis Output\n\n", Report)
close(Report)
Report <- file("report.txt", open="at")

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

png("plots/trend-state_target_sector_gdp.png")
qplot(data=subset(GDPbyInd_VT, Industry == IT_niacs), x=Year, y=GDP..Millions.Chained.2009.) +
  ggtitle(expression(atop("Portion of VT GDP",
                          atop(italic("Data processing, internet publishing, and other information services"), "")))) +
  geom_smooth(method=lm) 
dev.off()

png("plots/trend-us_target_sector_gdp.png")
qplot(data=subset(GDPbyInd_US, Industry == IT_niacs), x=Year, y=GDP..Billions.Chained.2009.) +
  ggtitle(expression(atop("Portion of US GDP",
                          atop(italic("Data processing, internet publishing, and other information services"), "")))) +
  geom_smooth(method=lm)
dev.off()

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
png("plots/trend-slope_us_sector_gdp(1).png")
dotchart(sapply(US_GDP_models["coefficients",], 
                function(var){return(var)})[2,grep("^[0-9]{2}[A-Z]*$", colnames(US_GDP_models))],
         main="Regression slopes of Large sectors - US")
dev.off()
png("plots/trend-slope_us_sector_gdp(2).png")
dotchart(sapply(US_GDP_models["coefficients",], 
                function(var){return(var)})[2,grep("^[0-9]{3,}[A-Z]*$", colnames(US_GDP_models))],
         main="Regression slopes of Small sectors - US")
dev.off()
png("plots/trend-slope_us_sector_gdp(3).png")
dotchart(sapply(US_GDP_models["coefficients",], 
                function(var){return(var)})[2,grep("^[A-Z]*$", colnames(US_GDP_models))],
         main="Regression slopes of Other sectors - US")
dev.off()

png("plots/trend-slope_st_sector_gdp(1).png")
dotchart(sapply(VT_GDP_models["coefficients",], 
                function(var){return(var)})[2,grep("^[0-9]{2}[A-Z]*$", colnames(VT_GDP_models))],
         main="Regression slopes of Large sectors - VT")
dev.off()
png("plots/trend-slope_st_sector_gdp(2).png")
dotchart(sapply(VT_GDP_models["coefficients",], 
                function(var){return(var)})[2,grep("^[0-9]{3,}[A-Z]*$", colnames(VT_GDP_models))],
         main="Regression slopes of Small sectors - VT")
dev.off()
png("plots/trend-slope_st_sector_gdp(2).png")
dotchart(sapply(VT_GDP_models["coefficients",], 
                function(var){return(var)})[2,grep("^[A-Z]*$", colnames(VT_GDP_models))],
         main="Regression slopes of Other sectors - VT")
dev.off()


top_growth_VT <- sort(sapply(VT_GDP_models["coefficients",], 
                             function(var){return(var)})[2,grep("^[0-9]{2,}[A-Z]*$", colnames(VT_GDP_models))],
                      decreasing=TRUE)[1:10]

top_growth_US <- sort(sapply(US_GDP_models["coefficients",], 
                             function(var){return(var)})[2,grep("^[0-9]{2,}[A-Z]*$", colnames(US_GDP_models))],
                      decreasing=TRUE)[1:10]

top_growth <- intersect(names(top_growth_US), names(top_growth_VT))

#subset(NIACS, Industry %in% c(IT_niacs, top_growth))
#top_growth_US[c(IT_niacs, top_growth)]
#top_growth_VT[c(IT_niacs, top_growth)]

growth_table <- merge(subset(NIACS, Industry %in% top_growth),
                      merge(cbind(Industry=names(top_growth_VT[top_growth]),
                                  VT_Growth=(top_growth_VT[top_growth])),
                            cbind(Industry=names(top_growth_US[top_growth]), 
                                  US_Growth=(top_growth_US[top_growth])),
                            by="Industry"),
                      by="Industry")


png("plots/trend-us_candidate_sectors.png")
qplot(data=subset(GDPbyInd_US, Industry %in% c(IT_niacs, top_growth)),
      x=Year, y=GDP..Billions.Chained.2009., colour=Industry) + geom_smooth(method=lm) +
  ggtitle(expression(atop("Portion of US GDP",
                          atop(italic("Candidate Industries"), "")))) 
dev.off()

png("plots/trend-st_candidate_sectors.png")
qplot(data=subset(GDPbyInd_VT, Industry %in% c(IT_niacs, top_growth)),
      x=Year, y=GDP..Millions.Chained.2009., colour=Industry) + geom_smooth(method=lm) +
  ggtitle(expression(atop("Portion of VT GDP",
                          atop(italic("Candidate Industries"), "")))) 
dev.off()

# Summary of linear models
#for (IND in c(IT_niacs, top_growth)){print(IND); print(
#  summary(lm(GDP..Billions.Chained.2009. ~ Year, data=subset(GDPbyInd_US, Industry == IND)))
#)}

Rsquared_US_top_GDP <- sapply(c(IT_niacs, top_growth), function(IND){
  cor(GDPbyInd_US[GDPbyInd_US$Industry == IND,
                  c("Year","GDP..Billions.Chained.2009.")])["Year","GDP..Billions.Chained.2009."]^2 
})

#for (IND in c(IT_niacs, top_growth)){print(IND); print(
#  summary(lm(GDP..Millions.Chained.2009. ~ Year, data=subset(GDPbyInd_VT, Industry == IND)))
#)}

Rsquared_VT_top_GDP <- sapply(c(IT_niacs, top_growth), function(IND){
  cor(GDPbyInd_VT[GDPbyInd_VT$Industry == IND,
                  c("Year","GDP..Millions.Chained.2009.")])["Year","GDP..Millions.Chained.2009."]^2 
})

growth_table<- merge(growth_table,
                     merge(cbind(Industry=names(Rsquared_VT_top_GDP), "R^2 VT"=Rsquared_VT_top_GDP),
                           cbind(Industry=names(Rsquared_US_top_GDP), "R^2 US"=Rsquared_US_top_GDP),
                           by="Industry"),
                     by="Industry")

writeLines("\n\nGrowth of Candidate Sectors\n", Report)
write.table(growth_table, Report)

paired_sector <- sort((Rsquared_VT_top_GDP + Rsquared_US_top_GDP)/2, decreasing=TRUE)[1]

writeLines("\n\nOf the top growth models, the following has the best average R^2:\n", Report)
write.table(paired_sector, Report)


# A look at Value added by Industry
VADDbyInd_US <- read.csv("data/RealValueAddedbyIndustry_US.csv")
png("plots/trend-slope_us_sector_value_add.png")
qplot(data=subset(VADDbyInd_US, Industry %in% c(IT_niacs, top_growth)),
      x=Year, y=Value.Added..Billions.Chained.2009., colour=Industry,
      main="Value Added by Candidate Sector - US") + geom_smooth(method=lm)
dev.off()

# A look at Income by County
RegionalIncome_VT <- read.csv("data/RegionalIncome_VT.csv")
# qplot(data=RegionalIncome_VT, x=Total.Personal.Income..Thousands., y=Population, colour=Location)

png("plots/vt_pop.png")
qplot(data=RegionalIncome_VT, x=Year, y=Population, colour=Location, main="Population Change in VT") + geom_smooth(method=lm)
dev.off()

png("plots/vt_income.png")
qplot(data=RegionalIncome_VT, x=Year, y=Total.Personal.Income..Thousands., 
      colour=Location, main="Total Income in VT") + geom_smooth(method=lm)
dev.off()

png("plots/vt_income_pp.png")
qplot(data=RegionalIncome_VT, x=Year, y=Total.Personal.Income..Thousands./Population, 
      colour=Location, main="Income per Person in VT") + geom_smooth(method=lm)
dev.off()

VT_Income_models <- sapply(levels(RegionalIncome_VT$Location), 
                        function(LOC){lm(Total.Personal.Income..Thousands./Population ~ Year, 
                                         data=subset(RegionalIncome_VT, Location == LOC))})

png("plots/trend-slope_vt_pop.png")
dotchart(sapply(VT_Income_models["coefficients",], function(var){return(var)})[2,], main="Slope of Population Models - VT")
dev.off()

# Population change
VT_pop <- sapply(levels(RegionalIncome_VT$Location), function(LOC){
  RegionalIncome_VT$Population[RegionalIncome_VT$Location == LOC & RegionalIncome_VT$Year == "2015"] -
    RegionalIncome_VT$Population[RegionalIncome_VT$Location == LOC & RegionalIncome_VT$Year == "2006"]
  })

# Population change by percent

VT_pop_per <- sapply(levels(RegionalIncome_VT$Location), function(LOC){
  RegionalIncome_VT$Population[RegionalIncome_VT$Location == LOC & RegionalIncome_VT$Year == "2015"] /
    RegionalIncome_VT$Population[RegionalIncome_VT$Location == LOC & RegionalIncome_VT$Year == "2006"]
})

VT_pop_table <- merge(cbind(Region=names(VT_pop), "Population Change"=VT_pop),
      cbind(Region=names(VT_pop_per), "Percent Change"=VT_pop_per),
      by="Region"
)
writeLines("\n\nPopulation Change in Vermont, 2006-2015\n", Report)
write.table(VT_pop_table, Report)
close(Report)
