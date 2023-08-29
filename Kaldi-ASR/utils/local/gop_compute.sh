#!/bin/bash

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

nj=12

run.pl JOB=1:$nj exp/compute_gop/log/compute_gop.JOB.log \
	compute-gop --phone-map=data/lang_test_bg/phone-to-pure-phone.int \
        --verbose=3 \
        exp/mono_nnet3/final.mdl \
        "ark,t:gunzip -c exp/nnet3_ali/ali-phone.JOB.gz|" \
        "ark:exp/probability_train/output.JOB.ark" \
        "ark,scp:exp/compute_gop/gop/gop.JOB.ark,exp/compute_gop/gop/gop.JOB.scp" \
        "ark,scp:exp/compute_gop/gop/feat.JOB.ark,exp/compute_gop/gop/feat.JOB.scp" 
        #"ark,t:exp/compute_gop/gop/gop.JOB.ark,exp/compute_gop/gop/gop.JOB.txt" \
        #"ark,t:exp/compute_gop/gop/feat.JOB.ark,exp/compute_gop/gop/feat.JOB.txt" || exit 1;

#echo "Done performing compute-gop. The results can be found in \"exp\gop\gop.<JOB>.txt\" in posterior format"

cat exp/compute_gop/gop/feat.*.scp > exp/compute_gop/gop/feat.scp
cat exp/compute_gop/gop/gop.*.scp > exp/compute_gop/gop/gop.scp

cat exp/mono/decode/wer_* > data/local/scores.txt

#grep -vwE "(%SER|compute-wer|Scored)" data/local/scores.txt > data/local/score_new.txt
#jq -n --arg data/local/score_new.txt > data/local/scores.json
python3 local/visualize_feats.py \
            --phone-symbol-table data/lang_nosp/phones-pure.txt \
            exp/gop_train/feat.scp data/local/scores.txt \
            exp/gop_train/feats.png
    #utils/int2sym.pl -f 2 data/lang_nosp/phones-pure.txt \
    #    exp/gop_test/result_${input}.int > exp/gop_test/result_${input}.txt
#python3 ./local/visualize_feats.py \
#           --phone-symbol-table data/lang/phones-pure.txt \
#            exp/nnet3_ali/gop/feat.scp data/local/scores.json \
#            exp/nnet3_ali/gop/feats.png

#python3 ./local/gop_to_score_eval.py \
#             exp/nnet3_ali \
#              exp/nnet3_ali/gop/gop.scp \
#              exp/nnet3_ali/gop/predicted_gop.txt            
#echo "The features are visualized and saved in exp/gop_train/feats.png"

echo "DONE"
