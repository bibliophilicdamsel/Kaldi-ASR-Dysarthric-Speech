#!/bin/bash

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

python3 ./steps/nnet3/report/generate_plots.py --start-iter=1 exp/mono_nnet3 exp/nnet3_report

echo "DONE"
