# Andrew Fairless, January 2011
# modified May 2015 for posting onto Github
# This script tests whether which litter a mouse is born into affects its 
# sociability as described in Fairless et al 2012
# Fairless et al 2012, doi: 10.1016/j.bbr.2011.12.001, PMID:  22178318, PMCID:  PMC3474345

# The fictional data in "altereddata.txt" were modified from the original 
# empirical data used in Fairless et al 2012.
# I am using fictional data instead of the original data because I do not have 
# permission of my co-authors to release the data into the public domain.  
# NOTE:  Because these data are fictional, several important characteristics of
# these data may be different from those of the original data.

# Each row is a separate mouse.
# The left-most 3 columns are quasi-independent variables (mouse strain, sex, and age).
# The right-most 5 columns are dependent variables describing behaviors of the
# mice during the Social Approach/Choice Test.

# Since this script was originally written, the R package 'lme4' has been 
# revised so that this script no longer works.
# Specifically, the package 'lme4' has changed how AICs are accessed so that my 
# original code (i.e., 'summary(model)@AICtab[[1]]') no longer works.  This
# problem was solved by implementing the new way to access AICs (i.e., 
# 'AIC(model)').
# The remaining problem is that the new 'lme4' package no longer accepts the 
# null model with the 'dummy' variable as valid; it returns the error 'Error: 
# grouping factors must have > 1 sampled level'.
# A version of the old 'lme4' package exists as 'lme4.0'.  I was not able to get
# 'lme4.0' to work with my code here.

install.packages("lme4", dependencies = TRUE)   # install package if not already installed

data = read.table("altereddata.txt", header = TRUE)      
data[ , 11] = -1
colnames(data)[11] = "dummy"
data = split(data, data$strain)

# analysis as described in Fairless et al 2012:
# "We first investigated litter membership by asking whether littermates were 
# more alike in their degree of sociability than non-littermates, after 
# controlling for strain, sex, and age. In other words, does the sociability of 
# mice cluster according to litter membership? . . . We analyzed social cylinder 
# investigation (which consisted predominantly of sniffing of the social cylinder) 
# in a linear mixed effects model for each strain as y = β0 + β1 (sex) + β2 
# (age) + β1,2 (sex, age) + b1 (litter) where sex, age, and their interaction 
# were modeled as fixed effects and litter was modeled as a random effect. This 
# ‘litter’ model was compared to a ‘null’ model, which differed from the ‘litter’
# model only by fictionally assigning all mice to the same litter."

library(lme4)

for(iter in 1:length(data)) {
  
     model = lmer(soc.3rd5min~age*sex*(1|litter), data = data[[iter]])     # litter model with experimental data
     litteraic = AIC(model)                       
     model = lmer(soc.3rd5min~age*sex*(1|dummy), data = data[[iter]])      # null model with dummy random effects variable
     nullaic = AIC(model)                         
     aicdiff = nullaic - litteraic                                         # assumes litteraic < nullaic
     a = exp(-0.5 * aicdiff)
     # probability that litter model is the preferred model to the null model
     probprefermodel = 1 - (a / (1 + a))
     # how many times more likely the litter model is preferred to the null model
     timesprefermodel = probprefermodel / (a / (1 + a))     

     strainname = gsub("[[:punct:]]", "", names(data)[iter])     # removes "/" from strain name
     sink(file = paste("aicmodelcomparison,", strainname, ".txt", sep = ""))
     
     print(paste("These results are for the", names(data)[iter], "mice"))
     print(paste("The AIC for the litter model is", litteraic))
     print(paste("The AIC for the null model is", nullaic))
     print(paste("The difference between the AICs of the two models is", aicdiff))
     print(paste("The probability that the litter model is the preferred model is ", 
                 probprefermodel, "%", sep = ""))
     print(paste("The litter model is", timesprefermodel, 
                 "times more likely to be preferred than the null model"))

     sink(file = NULL)
}
