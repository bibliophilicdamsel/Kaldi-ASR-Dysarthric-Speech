#!/bin/bash

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

python3 ./steps/nnet3/train_dnn.py --feat.online-ivector-dir exp/make_ivectors/train --trainer.optimization.num-jobs-final 1 \
	--trainer.num-epochs 5 \
	--trainer.optimization.initial-effective-lrate 0.04 --trainer.optimization.final-effective-lrate 0.004 \
	--trainer.compute-per-dim-accuracy true --cmd run.pl --use-gpu no \
	--feat-dir data/train --lang data/lang --ali-dir exp/mono2_ali --dir exp/mono_nnet3 || exit 1

echo "DONE"
#--trainer.input-model \
