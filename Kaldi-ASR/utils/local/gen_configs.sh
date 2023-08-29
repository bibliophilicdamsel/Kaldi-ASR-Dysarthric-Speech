#!/bin/bash

#tree_dir=exp/nnet2_tree
relu_dim=1000
#num_targets=84 #num_pdfs in the tree dir
num_targets=$(<exp/mono2/graph/num_pdfs)
#$(tree-info $tree_dir/tree |grep num-pdfs|awk '{print $2}')

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

#python3 ./steps/nnet2/make_multisplice_configs.py --ivector-dim 100 --lda-mat exp/mono_nnet2/lda.mat --lda-dim 460 --num-hidden-layers 4 configs exp/mono_nnet2/configs

mkdir -p exp/nnet3/configs
#defining the xconfig file
cat <<EOF > nnet.xconfig
input dim=100 name=ivector
input dim=40 name=input
#fixed-affine-layer name=lda input=Append(-1,0,1,ReplaceIndex(ivector,t,0)) dim=360 affine-transform-file=exp/mono_nnet2/lda.mat 
fixed-affine-layer name=lda input=Append(-4,-3,-2,-1,0,1,2,3,4,ReplaceIndex(ivector,t,0)) dim=460 affine-transform-file=exp/mono_nnet2/lda.mat 
#fixed-affine-layer name=lda input=Append(-1,0,1,ReplaceIndex(ivector,t,0)) dim=460 affine-transform-file=exp/mono_nnet2/lda.mat 
#relu-renorm-layer name=affine1 dim=460
#relu-renorm-layer name=affine2 dim=460 input=Append(-1,0,1,2)
#relu-renorm-layer name=affine3 dim=460 input=Append(-3,0,3)
#relu-renorm-layer name=affine4 dim=460 input=Append(-3,0,3)
#relu-renorm-layer name=affine5 dim=460 input=Append(-3,0,3)
#relu-renorm-layer name=affine6 dim=460 input=Append(-6,-3,0)
#relu-renorm-layer name=prefinal-chain dim=460 target-rms=0.5
output-layer name=output dim=$num_targets input=Append(-1,0,1)
EOF

python3 ./steps/nnet3/xconfig_to_configs.py --xconfig-file nnet.xconfig --config-dir exp/mono_nnet3/configs
python3 ./steps/nnet3/xconfig_to_configs.py --xconfig-file nnet.xconfig --config-dir exp/mono_nnet3

echo "DONE"

#component name=fixed-affine1 type=FixedAffineComponent matrix=exp/mono_nnet2/lda.mat
#component name=affine1 type=AffineComponentPreconditioned input-dim=460 output-dim=400 alpha=4.0 max-change=10.0 learning-rate=0.04 param-stddev=0.05 bias-stddev=0.5
#component name=nonlin1 type=TanhComponent dim=400
#component name=affine2 type=AffineComponentPreconditioned input-dim=400 output-dim=84 alpha=4.0 max-change=10.0 learning-rate=0.04 param-stddev=0 bias-stddev=0
#component name=softmax1 type=SoftmaxComponent dim=84
#input-dim= 460 output-dim=400
