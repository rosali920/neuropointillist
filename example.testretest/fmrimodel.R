# This model is written so that errors are appropriately trapped and
#handled when running
# using a shared memory multiprocessor
library(nlme)

processVoxel <-function(v) {
    Y <- voxeldat[,v]
    e <- try(mod <- lme(Y ~ task, random=~1|sub, method=c("ML"), na.action=na.omit))
    if(inherits(e, "try-error")) {
        mod <- NULL
    }
    if(!is.null(mod)) {
    mod.tt <- summary(mod)$tTable
    retvals <- list(
    mod.tt["task", "p-value"],
          mod.tt["task", "t-value"])
    } else {
    # If we are returning 2 dimensional data, we need to be specify how long
    # the array will be in case of errors.
        retvals <- list(999, 999)
    }
    names(retvals) <- c("p-task", "t-task")
    retvals
}
