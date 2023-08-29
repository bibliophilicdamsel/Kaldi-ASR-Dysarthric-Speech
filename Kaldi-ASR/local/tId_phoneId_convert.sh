#!/bin/bash

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

nj=12

run.pl JOB=1:$nj exp/nnet3_ali/log/ali_to_phones.JOB.log \
      ali-to-phones --per-frame=true exp/nnet3_ali/final.mdl \
        "ark,t:gunzip -c exp/nnet3_ali/ali.JOB.gz|" \
        "ark,t:|gzip -c > exp/nnet3_ali/ali-phone.JOB.gz"

echo "DONE"
