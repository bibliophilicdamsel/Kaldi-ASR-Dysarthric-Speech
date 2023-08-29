#!/bin/bash

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

nj=12
for i in exp/nnet3_ali/ali.*.gz; do
	ali-to-phones --ctm-output exp/mono_nnet3/final.mdl \
	ark:"gunzip -c $i|" -> ${i%.gz}.ctm;
done

cat exp/nnet3_ali/*.ctm > exp/nnet3_ali/merged_alignment.txt 

#for ((i=1; i<=$nj; i++)); do
#python3 ./local/generate_forced_aligned_rttm.py exp/nnet3_ali/ali.1.ctm
#done

# Make align graphs
#for part in 'ls data/train' ; do 
#   run.pl JOB=1:$nj exp/nnet3_ali_train/log/mk_align_graph.JOB.log \
#      compile-train-graphs-without-lexicon \
#        --read-disambig-syms=data/lang/phones/disambig.int \
#        exp/mono_nnet3/tree exp/mono_nnet3/final.mdl \
#        "ark,t:data/train/split${nj}/JOB/text.int" \
#        "ark,t:data/local/text-phone.int" \
#        "ark:|gzip -c > exp/nnet3_ali_train/fsts.JOB.gz"   || exit 1;
#    echo $nj > exp/nnet3_ali_train/num_jobs
#done
#for ((i=1; i<=$nj; i++)); do
#	for ((j=1; j<=$nj; j++)); do
#		align-text ark:exp/nnet3_ali/align.$i ark:exp/nnet3_ali/ali.$j ark,t:exp/nnet3_ali/alignment_$i.txt
#	done
#done
#align-text ark:exp/nnet3_ali/ali.1 ark:exp/nnet3_ali/ali.2 ark:exp/nnet3_ali/ali.3 ark:exp/nnet3_ali/ali.4 ark:exp/nnet3_ali/ali.5 ark:exp/nnet3_ali/ali.6 ark:exp/nnet3_ali/ali.7 \
#	   ark:exp/nnet3_ali/ali.8 ark:exp/nnet3_ali/ali.9 ark:exp/nnet3_ali/ali.10 ark:exp/nnet3_ali/ali.11 ark:exp/nnet3_ali/ali.12 ark,t:alignment.txt
echo "DONE"
