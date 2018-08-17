## Making your model script

Adapted from http://ibic.github.io/neuropointillist/ and http://ibic.github.io/neuropointillist/usage.html

In this tutorial, we will use the provided `example.rawfmri` dataset to breakdown the mixed model script, fmrimodel.R, called in neuropointillist.

While the neuropointillist code is mostly in R, you will interact with its functions through the Terminal using Bash.

This is an example on simulated data that runs a mixed effects model on the raw simulated fMRI data. There are two explanatory variables of interest, `High` and `Low`. As in traditional fMRI GLM analyses, the response variable, `Y`, is the voxel values. The file `sim.tstat-High.gt.Low.nii.gz` is a map of the t statistics for the contrast `High > Low`.

The dataframe will look like this:


            High     Low    TR subject  time
        1 -0.401 -0.399      1       1     1
        2 -0.401 -0.296      2       1     1
        3 -0.401  0.0660     3       1     1
        4 -0.401  0.442      4       1     1
        5 -0.401  0.659      5       1     1
        6 -0.401  0.737      6       1     1

Let's look at the code that actually runs the model, which is in the file `fmrimodel.R`. This is specified using the `--model` flag (in the `readargs.R` file explained in 02_quick_start_tutorial).

```
library(nlme)

processVoxel <-function(v) {
    # specify the response variable, Y
    Y <- voxeldat[,v]
    # specify mixed model (note you can write this in other packages like lme4
    e <- try(mod <- lme(Y ~ High+Low, random=~1|subject, method=c("ML"), na.action=na.omit, corr=corAR1(form=~1|subject), control=lmeControl(returnObject=TRUE,singular.ok=TRUE)))
    if(inherits(e, "try-error")) {
        mod <- NULL
    }
    if(!is.null(mod)) {
        # specify contrast values
        contr <- c(0, 1,-1)
        out <- anova(mod,L=contr)
        t.stat <- (t(contr)%*%mod$coefficients$fixed)/sqrt(t(contr)%*%vcov(mod)%*%contr)
        p <- 1-pt(t.stat,df=out$denDF)
        retvals <- list(summary(mod)$tTable["High", "t-value"],
                        summary(mod)$tTable["Low", "t-value"], t.stat, p)
    } else {
    # If we are returning 4 dimensional data, we need to be specify how long
    # the array will be in case of errors
        retvals <- list(999,999,999,999)
    }
    names(retvals) <- c("tstat-High", "tstat-Low", "tstat-High.gt.Low", "p-High.gt.Low")
    retvals
}
```

The `processVoxel` function is run for each voxel number `v`. Thus, `Y` is the BOLD signal at each voxel. This code specifies a mixed effects model with two explanatory variables, `High` and `Low`, and accounts for subject as a repeated measure by including a random effect of intercept per subject. We handle autocorrelation in the model using an autoregressive model of order 1 (AR1). Note that adding AR1 increases computation time.

If the model runs without error, then we compute the p-value of the contrast (where `High` > `Low`). Variables that we wish to save are collected in a vector, retvals, and named. The output variables are assembled into files with the prefix specified by the `--output` flag and the variable names.

For more information on mixed effects modeling of fMRI data in R, see the document [“fMRI in R”](https://github.com/madhyastha/fmriInR/blob/master/fmriInRWalkthrough.Rmd). The `processVoxel` function can run any model that can be run on a single voxel. This includes structural equation models, growth models, and so on. This function can also compare several models and output the best according to some criteria.

### Building models

When developing your own processVoxel function, it is helpful to run interactively on a few specific voxels. Similarly, if there are errors at a voxel it may be helpful to interactively interrogate the model output. The `--debugfile` flag for npoint specifies that the design matrix and voxel data should be written to an R file that can be used for model development and debugging.

If you have run `npoint` as directed above, you will have a file called `debug.Rdata` in the `sgedata directory`.

You can start R from within the `sgedata` directory, load this file, and see what is defined.
```
load(“debug.Rdata”)
ls()
[1] "designmat"          "imagecoordtovertex" "mask.arrayindices"
[4] "voxeldat"
```        
The `designmat` data structure contains the design matrix specified by the `setlabels` files.

`voxeldat` is a structure that holds all the voxels in the mask. Each column corresponds to 1 voxel in your mask, and the vertex column assigns each XYZ voxel a unique 1D coordinate value (vertex number) for that particular set of coordinates.

The `imagecoordtovertex` function uses the `mask.arrayindices` structure to transform image coordinates to vertex numbers. For example, to find the data corresponding to voxel x=20,y=42, z=22 in the mni_4mm.nii.gz image, you would call `imagecoordtovertex` as follows to get that coordinates' vertex number.

```
v <- imagecoordtovertex(20,42,22)
v
[1] 16733
```

To access the voxel time course (for all subjects and runs) for a particular voxel indicated by its vertex number, v, attach the design matrix and create the following Y variable.

```
attach(designmat)
Y <- voxeldat[,v]
Y
```

You can then use this Y parameter to test/troubleshoot your models.

### Saving model output

fmrimodel.R also returns the statistical output from the models as a list called "retvals". Below is the output from the quick start, which calculates t-stats and their associated p-values from a contrast of interest.

```
contr <- c(0, 1,-1)
out <- anova(mod,L=contr)
t.stat <- (t(contr)%*%mod$coefficients$fixed)/sqrt(t(contr)%*%vcov(mod)%*%contr)
p <- 1-pt(t.stat,df=out$denDF)
retvals <- list(summary(mod)$tTable["High", "t-value"],
           summary(mod)$tTable["Low", "t-value"], t.stat, p)
```

T-stats and p-values can also be pulled directly from your model's summary output (see example.flournoy/model.R for an example).

The names of these values, which will be appended to your output niftis, are set via the names in the retvals list:

```
names(retvals) <- c("tstat-High", "tstat-Low", "tstat-High.gt.Low", "p-High.gt.Low")
```

Please note that there is currently a bug in which Neuropointillist throws an error if only one output value is stored. Check the [github issue](https://github.com/IBIC/neuropointillist/issues/4) for the latest on this bug. For now, a simple workaround is to ask for the same output twice, or to ask for more than one output to be returned.  

### Additional troubleshooting
See **Notes for troubleshooting** in 04_testretest_opendata_tutorial for notes on how to create a small slice of brain mask to test your model on a smaller number of voxels, rather than your full brain mask.
