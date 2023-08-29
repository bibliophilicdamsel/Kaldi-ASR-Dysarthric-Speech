#!/bin/bash

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

n=12
mkdir -p exp/compute_gop
#net-am-compute 
#for ((i=1; i<=$n; i++)); do
#	ali-to-pdf exp/mono_nnet3/final.mdl ark:exp/nnet3_ali/ali.$i ark,t:- | ali-to-post
#nnet-am-compute --apply-log=true exp/nnet2_ali/final.mdl scp:data/train/feats.scp ark,t:exp/posterior_infile.ark
nnet3-compute --use-gpu=no --online-ivectors=scp:exp/make_ivectors/train/ivector_online.scp --use-priors=true --online-ivector-period=12 \
	exp/nnet3_ali/final.mdl scp:data/train/feats.scp ark,t:exp/compute_gop/posterior_infile.ark

echo "DONE" 
