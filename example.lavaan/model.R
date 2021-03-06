library(lavaan)
library(tidyr)
processVoxel <- function(v) {
    Y <- voxeldat[,v]
    adf <- data.frame(idnum,sex,pds,age,time,target,domain,Y)
    data <- aggregate(adf, by=list(adf$idnum, adf$time),FUN=mean)
    data$idnum <- data$Group.1

    adf <- data
    adf <- adf[,c("idnum", "sex", "pds", "age", "time", "Y")]
    colnames(adf) <-c("idnum", "sex", "pds", "age", "time", "Y")


#widen the data for lavaan
adf_w <- adf[, grep('age', names(adf), invert = T)] %>% 
  gather(variable, value, pds, Y) %>%
  unite(var_time, variable, time) %>%
  spread(var_time, value)

#head(adf_w)

require(lavaan)

cor_lgc_model <- '
#centered at wave 2, time unit = years
Y_i =~ 1*Y_0 + 1*Y_1 + 1*Y_2
Y_s =~ -3*Y_0 + 0*Y_1 + 3*Y_2
pds_i =~ 1*pds_0 + 1*pds_1 + 1*pds_2
pds_s =~ -3*pds_0 + 0*pds_1 + 3*pds_2

#correlations explicitly coded, but would be generated by default
Y_i ~~ Y_s + pds_i + pds_s
Y_s ~~ pds_i + pds_s
pds_i ~~ pds_s
Y_s~~0*Y_s
'

e <- try(fit <- lavaan::growth(cor_lgc_model, data = adf_w, missing="fiml",standardized=TRUE))

if(inherits(e,"try-error")) {
            message("error thrown at voxel",v)
            message(e)
            fit <- NULL
        }

    if (!is.null(fit)) {
        unstd_ests <- parameterEstimates(fit)
        vars <- subset(unstd_ests, op=="~~" & lhs==rhs)
        if (sum(vars$est < 0) > 1) { #negative variances, abort!
            fit <- NULL
        }
    }

#summary(fit)
    if (!is.null(fit)) {
        unstd_ests <- parameterEstimates(fit)
        param_ests <- standardizedsolution(fit)
        param_ests$name <- paste(param_ests$lhs, param_ests$op, param_ests$rhs,sep="")
  # get p values from unstandardized
        param_ests$pvalue <- unstd_ests$pvalue
                                        # get fit measures
        fit <- fitmeasures(fit, c("rmsea", "cfi", "pvalue"))


        latent_int <- param_ests[param_ests$lhs %in% c('Y_i', 'Y_s', 'pds_i', 'pds_s') & 
                                     param_ests$op %in% c('~1'),]
        latent_varcov <- param_ests[param_ests$lhs %in% c('Y_i', 'Y_s', 'pds_i', 'pds_s') & 
                                        param_ests$op %in% c('~~'),]

        ret <- rbind(latent_int, latent_varcov)

# make sure order is correct
        ret <- ret[order(ret$name),]

        retvals <- c(ret$est.std,ret$pvalue, fit)

        names(retvals) <-c(paste(ret$name,".est",sep=""), paste(ret$name, ".pvalue", sep=""), "rmsea", "cfi", "chisq.pvalue")

    } else {
        retvals <- rep(-999, 31)
        names(retvals) <- c(
"pds_i~1.est",         "pds_i~~pds_i.est",    "pds_i~~pds_s.est",
 "pds_s~1.est",         "pds_s~~pds_s.est",    "Y_i~1.est",
 "Y_i~~pds_i.est",      "Y_i~~pds_s.est",      "Y_i~~Y_i.est",
 "Y_i~~Y_s.est",        "Y_s~1.est",           "Y_s~~pds_i.est",    
 "Y_s~~pds_s.est",      "Y_s~~Y_s.est",        "pds_i~1.pvalue",    
 "pds_i~~pds_i.pvalue", "pds_i~~pds_s.pvalue", "pds_s~1.pvalue",    
 "pds_s~~pds_s.pvalue", "Y_i~1.pvalue",        "Y_i~~pds_i.pvalue",
 "Y_i~~pds_s.pvalue",   "Y_i~~Y_i.pvalue",     "Y_i~~Y_s.pvalue", 
 "Y_s~1.pvalue",        "Y_s~~pds_i.pvalue",   "Y_s~~pds_s.pvalue",
 "Y_s~~Y_s.pvalue",     "rmsea",               "cfi",
 "chisq.pvalue")     
}
retvals
}

