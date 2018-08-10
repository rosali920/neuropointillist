cmdargs <- c("-m","group_min_mask.nii.gz", "--set1", "setfilenames1.txt",
             "--set2", "setfilenames2.txt",
             "--setlabels1", "setlabels1.csv",
             "--setlabels2", "setlabels2.csv",
             "--model", "fmrimodel.R",
             "--output", "testretestREM/model1_",
             "--debug", "debug.Rdata",
             "--sgeN", "1")
