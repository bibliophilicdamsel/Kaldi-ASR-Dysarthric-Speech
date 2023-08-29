#!/bin/bash

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

python3 ./steps/nnet3/train_rnn.py --feat.online-ivector-dir exp/make_ivectors/train --trainer.optimization.num-jobs-final 1 \
	--trainer.num-epochs 5 \
	--trainer.optimization.initial-effective-lrate 0.0004 --trainer.optimization.final-effective-lrate 0.00004 \
	--trainer.compute-per-dim-accuracy true --cmd run.pl --use-gpu no \
	--feat-dir data/train --lang data/lang --ali-dir exp/nnet2_ali --dir exp/mono_nnet3 || exit 1

echo "DONE"
