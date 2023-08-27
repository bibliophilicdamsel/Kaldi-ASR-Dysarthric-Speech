#!/bin/bash

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

#tree-info exp/tri/tree
#gmm-info exp/tri/final.mdl
#gmm-info exp/tri2_ali/final.mdl
#show-alignments exp/tri2_ali/phones.txt exp/tri2_ali/final.mdl ark:exp/tri2_ali/ali.1 > exp/tri2_ali/show_ali_1.txt
#gmm-info exp/mono/final.mdl
#lattice-copy "ark:gunzip -c lat.1.gz|" ark,t:-| utils/sym2int.pl -f 3 data/lang/words.txt | less
#cat lattice.txt | lattice-to-fst --rm-eps=true --acoustic-scale=1.0 --lm-scale=1.0 ark,t:- ark,t:- | \
#	tail -n+2 | fstcompile |fstdraw --portrait=true --osymbols=data/lang/words.txt | dot -Tpdf > lattice.pdf
#cat data/lang_test_bg/G.fst | fstdraw --portrait=true --isymbols=data/lang_test_bg/phones.txt --osymbols=data/lang_test_bg/words.txt | dot -Tpdf > data/lang_test_bg/lattice.pdf
#./utils/show_lattice.sh train_FC01_100 --mode display \
#	--acoustic-scale=0.0 exp/mono_nnet3/decode_test/lat.1.gz \
#	exp/mono/graph/words.txt
#draw-tree data/lang_test_bg/phones.txt exp/tri/tree | dot -Gsize=8,10.5 -Tps |ps2pdf - mono_tree.pdf
paste wave_text/speakerID_train wave_text/train.txt > data/train/text
paste wave_text/speakerID_test wave_text/test.txt > data/test/text
sed -i 's/\t/ /g' data/train/text
sed -i 's/\t/ /g' data/test/text 
echo "DONE"
