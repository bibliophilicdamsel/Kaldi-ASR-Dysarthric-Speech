## Getting Started With Kaldi
### Installation
Before getting started with Kaldi's installation, it is essential to realise that the creators have designed it with a higher compatibility of working in a Linux-based environment. Hence, it is better to either have a system that works on a Linux-based OS, or have a Virtual Machine (VM) installed on your system and run the Linux-based OS through the virtual environment. 

Also, if you are running Ubuntu, either on your VM or on your system as an independent OS, run the version which would support python2 as Python codes of Kaldi are implemented through a combination of Python versions 2 and 3.

Kaldi requires a few essential packages to be installed before its installation. Run the following snippets of code to get them done. 

```
sudo apt-get install git
sudo apt-get install bc
sudo apt-get install g++
sudo apt-get install zlib1g-dev wget make automake autoconf bzip2 libtool subversion
sudo apt-get install libatlas3-base
```
If the commands like awk, sed, grep, rename, or sort aren't installed, you may install them using `sudo apt-get install` _command-name_.

In general, the latest version of Python will be present in your system by default. If it isn't, run, `sudo apt-get install python` which would install the latest version of Python. To install the lower version of python, run `sudo apt-get install python2`.

Next, run `sudo apt-get update` and `sudo apt-get upgrade` to check for any missing functionalities or updates. Finally, clone the Github repository of Kaldi by running the following snippet of code to conclude Kaldi's installation. 

```
git clone https://github.com/kaldi-asr/kaldi.git
```
### Configuration
Next, follow the following code snippet to configure the installation of Kaldi.

```
cd kaldi
cd tools
extras/check_dependencies.sh
```
If the above snippet returns **all ok**, then proceed with running the further lines of code. If not, install the required dependencies using `sudo apt-get` _dependencyname_.

Also, Intel MKL libraries might not have been installed in some of the systems. So, run `extras/install_mkl.sh.` Next, check for the number of processes your system supports by typing `nproc` in the command window. Let's say the number of processes your system supports is 4. Then, run `make -j 4` for the tools directory.

**Note:**
*If you are running on a Fedora Linux environment, trying to intall intel mkl libraries might not work because of a compatibility issue on the side of Intel developers*

In majority of the cases, running `make` would return with a warning that states that **IRSTLM is not installed by default anymore**. So, to waive that warning off (as IRSTLM is necessary to build the language model required), run `extras/install_irstlm.sh`.

Once done, run the subsequent code snippet
```
cd ..
cd src
./configure --debug-level=0
make depend -j 4
make -j 4
```

We are using a debugging level of 0 while configuration to disable assertions which might be a tad bit problematic in certain cases. Also, if you are planning on using iVector features, open `ivector-extractor.h` in src/ivector and change the `gaussian_min_count` to a lower value like 15 or 20. The default minimum count is 100 and has been set when experimenting on datasets with larger time durations which have gaussian values greater than 100. This keeps the user astray from any *feature not found error while trying to build an ivector extractor*.

Finally, Kaldi requires SRILM toolkit as well. To install the same, log in to the SRILM website, provide your necessary details, and download the SRILM archive. Extract the archive, rename it to *srilm* and move it to `kaldi/tools/`. Then, run `install_srilm.sh` and conclude Kaldi's installation.

### Testing Kaldi's Installation
To test if your installation of Kaldi is working perfectly, the developers recommend starting out with an example popularly known as the *Yes-No* recipe. To check it out, run the following code snippet
```
cd ..
cd egs
cd yesno/s5
bash ./run.sh 
```

If any errors like `unknown name python` or `python does not exist` or `env: no such file or dir` arise, check for where your variables exist (which might most probably be in `bin`), and change the header of your .sh files to `#!/bin/bash`. And in .py files, change the header to `#!/usr/bin/python3`.

You can always log on to the Kaldi Google groups and post in any queries you might be having in regard with its functioning. The developers are almost always active and might revert back to you with prompt response. Also, for any further queries, you may check out Kaldi's StackOverFlow forum, or Sourceforge.net Forum, or even, Kaldi's Github discussion forum. Some websites which might come super helpful while working with Kaldi are listed below. Feel free to check them out.

* [Kaldi Help Material](https://www.eleanorchodroff.com/tutorial/kaldi)
* [Kaldi Cheatsheet JR Myer](http://jrmeyer.github.io/asr/2019/08/17/Kaldi-cheatsheet.html)
* [Kaldi Kunal Dhawan](https://kunal-dhawan.weebly.com/asr-system-for-hindi-language-from-scratch.html)

Happy Kaldi-ing!
