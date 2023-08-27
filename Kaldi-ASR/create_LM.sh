# /bin/bash

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

ngram_size=2
lm_text='data/local/dict/lm_train.text'
lm_type=improved-kneser-ney 

mkdir -p data/local/irstlm_lm

#improved-kneser-ney type LM
'/home/bibliophildamsel/kaldi/tools/irstlm/bin/build-lm.sh' -i $lm_text -n $ngram_size -s $lm_type -o data/local/irstlm_lm/lm_kn_phone_bg.ilm.gz
#witton bell type LM
'/home/bibliophildamsel/kaldi/tools/irstlm/bin/build-lm.sh' -i $lm_text -n $ngram_size -o data/local/irstlm_lm/lm_wb_phone_bg.ilm.gz

#kn_lm= data/local/irstlm_lm/lm_kn_phone_bg.ilm.gz
#wb_lm= data/local/irstlm_lm/lm_wb_phone_bg.ilm.gz

#finds words that are not symbols in the symbol table words.txt
#gunzip-c $kn_lm | utils/find_arpa_oovs.pl data/lang/words.txt > data/lang_test_bg/words.txt

echo "LM Preparation Succeeded"

echo "Preparing train, dev and test data"
lexicon=data/local/dict/lexicon.txt
lm_dir=data/local/irstlm_lm
tmpdir=data/local/lm_tmp

for x in train test; do 
  utils/validate_data_dir.sh --no-feats data/$x || exit 1
done

echo Preparing language models for test

for lm_suffix in bg; do
	test=data/lang_test_${lm_suffix}
	mkdir -p $test
	cp -r data/lang/* $test
	gunzip -c $lm_dir/lm_wb_phone_bg.ilm.gz | grep -v '<s> <s>' | grep -v '<s> </s>' | grep -v '</s> </s>' | grep -v '<unk>' | \
		arpa2fst - | fstprint | \
 		utils/eps2disambig.pl | utils/s2eps.pl > $test/Gfst.txt
 		
	gunzip -c $lm_dir/lm_wb_phone_bg.ilm.gz | grep -v '<s> <s>' | grep -v '<s> </s>' | grep -v '</s> </s>' | grep -v '<unk>' | \
		arpa2fst - | fstprint | \
 		utils/eps2disambig.pl | utils/s2eps.pl | fstcompile --isymbols=$test/words.txt --osymbols=$test/words.txt \
 		--keep_isymbols=false --keep_osymbols=false | fstrmepsilon | fstarcsort --sort_type=ilabel > $test/G.fst
  	fstisstochastic $test/G.fst
  	
	mkdir -p $tmpdir/g
  	awk '{if(NF==1){ printf("0 0 %s %s\n", $1,$1); }} END{print "0 0 #0 #0"; print "0";}' \
    	< "$lexicon"  >$tmpdir/g/select_empty.fst.txt
  	fstcompile --isymbols=$test/words.txt --osymbols=$test/words.txt $tmpdir/g/select_empty.fst.txt | \
   	fstarcsort --sort_type=olabel | fstcompose - $test/G.fst > $tmpdir/g/empty_words.fst
  	fstinfo $tmpdir/g/empty_words.fst | grep cyclic | grep -w 'y' && 
    	echo "Language model has cycles with empty words" && exit 1
    	rm -r $tmpdir/g
done

utils/validate_lang.pl data/lang_test_bg || exit 1

echo "Succeeded in formatting data."
rm -r $tmpdir
