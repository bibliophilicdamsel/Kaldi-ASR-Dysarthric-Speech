#! /bin/bash

#the posterior.ark is modified to posterior.txt for the python code

in_file=exp/compute_gop/posterior_infile.ark

cat $in_file | sed -e '1d' | sed -e 's/^[ \t]*//' > exp/compute_gop/posterior.txt 
