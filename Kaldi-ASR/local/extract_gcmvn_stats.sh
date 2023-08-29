#!/bin/bash

#$dir= exp/extractor_train

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

#for spk2utt in 'ls data/train/' ; do
	#apply-cmvn --utt2spk=ark:data/train/utt2spk scp:data/train/cmvn.scp scp:data/train/feats.scp ark:-
	#compute-cmvn-stats --binary --spk2utt=ark:data/train/spk2utt scp:data/train/feats.scp ark,scp:global_cmvn.ark,global_cmvn.scp|global_cmvn.stats
	#compute-cmvn-stats --binary --spk2utt=ark:data/train/spk2utt scp:data/train/feats.scp /exp/extractor_train/global_cmvn.stats
for feats in 'ls data/train/' 'ls data/test/' ; do
	compute-cmvn-stats --binary scp:data/train/feats.scp exp/extractor/global_cmvn.stats
	#compute-cmvn-stats --binary scp:data/test/feats.scp exp/extractor/global_cmvn.stats
	#mkdir exp/extractor_train/cmvn_stats 	
done
