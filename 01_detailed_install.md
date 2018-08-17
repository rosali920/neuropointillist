## Installing Neuropointillist on your local machine (for macs)
Make sure you have the necessary programs and packages installed.

Instructions adapted from: http://ibic.github.io/neuropointillist/installation.html

#### Needed programs:
* R
* Python 2.7 or later
* fsl OR nibabel python package

Note that you only need to install the Python and R packages once on your local machine; after they have been installed, neuropointillist will be able to load them as needed:

#### Needed Python packages
* argparse (for R's argparse package)
* json (for R's argparse package)
* nibabel (if you do not have FSL installed)

The simplest way to install python packages is through pip ([instructions for download here](https://pip.pypa.io/en/stable/); note that pip installs automatically with [Anaconda/miniconda](https://conda.io/docs/user-guide/install/index.html)):

```
pip install argparse
pip install json
pip install nibabel
```

#### Needed R packages
* argparse
* doParallel
* Rniftilib
* nlme (if you're using the tutorial's model)
* neuropointillist

If you don't have the first 4 R packages in the list, the neuropointillist code will try to install these packages for you when it runs. Just to be safe, you can install them manually yourself. The simplest way to install the first 4 R packages is to open R and run the following commands:

```
install.packages("argparse")
install.packages("doParallel")
#Rniftilib must be installed from the source
install.packages("http://ascopa.server4you.net/ubuntu/ubuntu/pool/universe/r/r-cran-rniftilib/r-cran-rniftilib_0.0-35.r79.orig.tar.xz", repos=NULL)
install.packages("nlme")
```

To install the neuropointillist package, you must first clone the neuropointillist repository to your local machine. You can do this manually from the [Neuropointillist GitHub repository](https://github.com/IBIC/neuropointillist) by clicking the green "Clone or download" button.  

Alternatively, you can use Terminal and [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git). Navigate to the folder you want to put the repository in and run the following:

`git clone https://github.com/IBIC/neuropointillist.git`

Once you have the repository on your local machine, in Terminal, cd into the neuropointillist folder you just cloned. There should be yet another neuropointillist folder in this folder. Make sure you're in the first neuropointillist folder but not the second. In other words, if the folder structure looks like ~/Desktop/neuropointillist/neuropointillist, you should be in ~/Desktop/neuropointillist

Open R and run the following to install the neuropointillist package:

`install.packages("neuropointillist", repos=NULL, type="source")`

**Now your computer should be set up to run neuropointillist!**
