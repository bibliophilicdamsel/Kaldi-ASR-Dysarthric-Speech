#!/bin/bash

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

python3 ./steps/nnet3/convert_nnet2_to_nnet3.py --model final.mdl exp/mono_nnet2 exp/mono_nnet3 || exit 1

echo "DONE"
