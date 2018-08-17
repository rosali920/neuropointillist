## Tutorial for running Neuropointillist on preprocessed fMRI data

Note that this tutorial builds off information conveyed in 02_quick_start_tutorial.md.

You should be in the folder neuropointillist/example.testretest and already have the main neuropointillist folder in your path.s

### Overview of the dataset

This tutorial uses a subset of the freely available dataset from [Gorgolewski et al., 2013](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3641991/), available from [OpenNeuro](https://openneuro.org/datasets/ds000114/versions/00001).  

The full dataset has 10 subjects at 2 timepoints (test and retest) completing 1 run each of 5 different tasks. To save processing time, we will just use 4 subs (sub-01 through sub-04) and 1 task (overtwordrepetition) at both timepoints.

In these data, participants engaged in 30s blocks of word repetition, with 30s ITIs. If you want to inspect the original timing file, we have included it in the tutorial folder (task-overtwordrepetition_events.csv), or you can download it from OpenNeuro.

### Download the data

We will use data that has already been preprocessed using fmriprep. To see these files from [v0001 of the data on OpenNeuro](https://openneuro.org/datasets/ds000114/versions/00001), click on FMRIPREP (under Analyses on the right side of the screen), poldracklab/fmriprep:0.5.4 - #9, Results, fmriprep.

Below are the example files we'll use for just sub-01. Pull the same set of files for sub-02, sub-03, and sub-04, so you'll end up with 16 nifti files in total. You can download each file manually by clicking on its download button.
* sub-01/ses-retest/func/sub-01_ses-retest_task-overtwordrepetition_bold_space-MNI152NLin2009cAsym_brainmask.nii.gz
* sub-01/ses-retest/func/sub-01_ses-retest_task-overtwordrepetition_bold_space-MNI152NLin2009cAsym_preproc.nii.gz
* sub-01/ses-test/func/sub-01_ses-test_task-overtwordrepetition_bold_space-MNI152NLin2009cAsym_brainmask.nii.gz
* sub-01/ses-test/func/sub-01_ses-test_task-overtwordrepetition_bold_space-MNI152NLin2009cAsym_preproc.nii.gz

Alternatively, if you have the time and diskspace to download the full dataset, you can just click the DOWNLOAD ALL button, or you can use [Amazon's command line interface](https://aws.amazon.com/cli/) (if not already installed: pip install awscli):

`aws --no-sign-request s3 sync s3://openneuro.outputs/a243dd176d50b0973d013a5a7569787c/db81c46c-1908-4bfd-85b3-9fa1284093ab destination-directory`

### Sort the data

To fit the file structure expected by the tutorial, sort the data into the example.testretest folder of the main neuropointillist repository as described below:

The 8 ..._preproc.nii.gz files that you downloaded are the preprocessed functional data. Place these in a folder in example.testretest called fmri_data, so that your data fit the below folder structure:

    .../neuropointillist/example.testretest/fmri_data/sub-##_..._preproc.nii.gz

The 8 ..._brainmask.nii.gz files are the individual runs' brain mask files. Place these in a folder in example.testretest called indiv_masks, so that your data fit the below folder strucutre.

    .../neuropointillist/example.testretest/indiv_masks/sub-##_..._brainmask.nii.gz

### Create a shared mask

Even though participants' brains have been coregistered to standard space, their masks are slightly different. We will create a common mask that will have voxel data for all subs using nb_createmask.

nb_createmask takes the folder containing your masks (and only your masks) as input. From the neuropointillist/example.testretest folder:

`nb_createmask "./indiv_masks/"`

This will create a common mask called "group_min_mask" in your example.testretest folder.

### Inspect the setfilenames files

The pre-made setfilenames1.txt and setfilenames2.txt from the repo should fit the folder structure that you sorted your downloaded data to. If they do not, you can either fix the data structure or edit the setfilenames files to match your data structure.

### Inspect the setlabels files

setlabels1.csv contains detailed information for every TR for every run listed in setfilenames1.txt, in the same order. setlabels2.csv is the equivalent for setfilenames2.txt.

Compare these csv files to the original timing files (task-overtwordrepetition_events.csv). The task used 5s TRs. Note how we have converted the task onset/offset times into TR numbers so that each row of the csv file denotes a TR, and whether the participant is engaging in the task or waiting out an ITI at that TR.

See 02_quick_start_tutorial for more information about these files.

### Inspect the fmrimodel.R file

This file contains the model that you want to run on each voxel, and returns your desired statistical values. See 03_making_your_model_script for more information.

Our example model

`mod <- lme(Y ~ task, random=~1|sub, method=c("ML"), na.action=na.omit)`

is a simple mixed model that captures the degree to which the presence of "task" predicts voxel activity, while accounting for the random effect of participant identify. The fmrimodel.R will save two brain maps, one of the t-stats associated with the task regressor, and one of the p-values associated with the task regressor.

### Inspect the readargs.R file

The readargs.R file contains the variables that are passed to npoint. Inspect these parameters (more detailed info in the quick start tutorial) to make sure they're correct.

### Run the fmrimodel

From the example.testretest folder, enter

`npoint`

to build your jobs. This will make a testretestREM folder. Enter that.

`cd testretestREM`

If you have access to a cluster and used the --sgeN tag, you can run

`./runme.sge`

Otherwise, if you're running locally, run the runme.local file. You may have to change the permissions first.

```
chmod +x ./runme.local
./runme.local
```

### Expected output

You should have the following output when the code is done running.
* model1_p-task.nii.gz
* model1_t-task.nii.gz

**Congratulations! You have completed the TestRetest tutorial!**

### Notes for troubleshooting

If your files did not properly merge (e.g. you see things like model1_0001p-task.nii.gz, model1_0002p-task.nii.gz), you can run npointmerge manually to pull them together:

```
npointmerge model1_p-task.nii.gz model1*p-task.nii.gz
npointmerge model1_t-task.nii.gz model1*t-task.nii.gz
```

For debugging convenience, the example.testrest folder also includes a test_mask.nii.gz of just 745 voxels (one slice of brain). This will let you run your models quickly through the workflow to help troubleshoot.

The code to make this mask is also included as nb_create_test_mask, which is executed like  nb_createmask. Note that it also includes numpy as a dependency. You may have to change the number 30 in the below to a different number that fits your mask size.

`new_mask[:, 30, :] = sum_data[:, 30, :]`
