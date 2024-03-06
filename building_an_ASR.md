## Building an ASR System Using Kaldi
### Data Preparation
Every ASR system you try to build in Kaldi for your dataset/recipe has to be carried out in the *egs*
subdirectory of the Kaldi directory.
```
cd kaldi/egs
```
Run, `git clone https://github.com/AssemblyAI/kaldi-asr-tutorial.git` to get the necessary directories for building an ASR system. 
```
mkdir MER_severe_base
cd MER_severe_base
mkdir -p newwave
mkdir -p data
mkdir -p exp
mkdir -p data/local
mkdir -p data/lang
mkdir -p data/train
mkdir -p data/test
mkdir -p data/local/lang
```
* Here, *newwave* directory contains the *train* and *test* subdirectories which will contain the audio files to be grouped under test and train
* The *data/train* and *data/test* directory would contain the files necessary for extracting features and splitting to build the ASR
* The *data/lang* directory will contain the necessary files for building the LM for the ASR system
* The *data/exp* also known as the *experiment* directory would contain the models you train your ASR system on.
* Copy the folders *conf*, *local*, *steps*, and *utils* from the directory *kaldi-asr-tutorial* in your *egs* directory to your working directory (MER_severe_base in this case)

1. **Conversion of audio format to .wav**

	If your audio files are in a format other than .wav, say in .flac, paste the following lines of code by altering the variables according to your dataset into a shell script, name it *flac2wav.sh* (or choose a name that suits your audio format) and run the same by calling `bash ./flac2wav.sh`
	
	The reason for writing *bash* before calling any shell script is to keep the shell prompt from throwing any permission denied errors and to save the task of using *chmod* manually for every file. 
	```
	#!/bin/bash 
	mkdir -p newwave/train
	
	for((j=1; j<=365; j++)); do
	ffmpeg -i /home/bibliophildamsel/SSN_TDSC/data/severe/MER/audio/MER$j.flac newwave/train/MER$j.wav
	done
	
	cp /home/bibliophildamsel/SSN_TDSC/data/severe/MER/label/*.lab newwave/train/
	
	echo "DONE"
	```
		
2. **Divide your dataset into train and test**
	
	To organise your dataset into *train* and *test*, create a shell script called *create_validation.sh* and run it by calling `bash ./create_validation.sh`
	```
	#!/bin/bash
	mkdir -p newwave/test
	
	DIFF=$((365-1+1))
	RANDOM=$$
	for i in `seq 36`
	do
	var1=$(($(($RANDOM%$DIFF))+1))
	cp newwave/train/MER$var1.wav newwave/test/
	cp newwave/train/MER$var1.lab newwave/test/
	done
	echo "DONE"	
	```
	Also, you may save the shell scripts you manually create onto your dataset directory (in this case, MER_severe_base)
3. **Preparing the data**
	
(i) First, prepare the *train.trans*, *train_phn.trans*, *test.trans*, and *test_phn.trans* files which contain the transcriptions of each utterance. These files are created from the .LAB files. If you don't have one, you might need to create these transcription files manually for dictionary preparation and LM building.
	 Create a script called *prepare_data.sh* by writing the following lines of code. 
```
#!/bin/bash

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

train_dir=newwave/train
test_dir=newwave/test
dir=wave_text
mkdir -p $dir
tmpdir=$(mktemp -d /tmp/kaldi.XXXX);
ls -d newwave/train/ | sed -e "s:^.*/::" > $tmpdir/train_spk
ls -d newwave/test/ | sed -e "s:^.*/::" > $tmpdir/test_spk
for x in train; do
  find $train_dir -iname '*.LAB' \
    | grep -f $tmpdir/${x}_spk > $tmpdir/${x}_phn.flist
  sed -e 's:.*/\(.*\)/\(.*\).LAB$:\1_\2:i' $tmpdir/${x}_phn.flist \
    > $tmpdir/${x}_phn.uttids
while read line; do
    [ -f $line ] || error_exit "Cannot find transcription file '$line'";
    cut -f3 -d' ' "$line" | tr '\n' ' ' | sed -e 's: *$:\n:'
  done < $tmpdir/${x}_phn.flist > $tmpdir/${x}_phn.trans
  paste $tmpdir/${x}_phn.uttids $tmpdir/${x}_phn.trans \
   | sort -k1,1 > $dir/${x}_phn.trans
sed 's/ //g' $dir/${x}_phn.trans > $dir/${x}.trans
sed -i 's/SIL/SIL /g' $dir/${x}.trans
sed -i 's/SIL/ SIL/g' $dir/${x}.trans
sed -i 's/\t/ /g' $dir/${x}.trans
done
for x in test; do
  find $test_dir -iname '*.LAB' \
    | grep -f $tmpdir/${x}_spk > $tmpdir/${x}_phn.flist
  sed -e 's:.*/\(.*\)/\(.*\).LAB$:\1_\2:i' $tmpdir/${x}_phn.flist \
    > $tmpdir/${x}_phn.uttids
while read line; do
    [ -f $line ] || error_exit "Cannot find transcription file '$line'";
    cut -f3 -d' ' "$line" | tr '\n' ' ' | sed -e 's: *$:\n:'
  done < $tmpdir/${x}_phn.flist > $tmpdir/${x}_phn.trans
  paste $tmpdir/${x}_phn.uttids $tmpdir/${x}_phn.trans \
    | sort -k1,1 > $dir/${x}_phn.trans
sed 's/ //g' $dir/${x}_phn.trans > $dir/${x}.trans
sed -i 's/SIL/SIL /g' $dir/${x}.trans
sed -i 's/SIL/ SIL/g' $dir/${x}.trans
sed -i 's/\t/ /g' $dir/${x}.trans
done
```

(ii) Next, create a script called *prepare_train_test.sh* and call the same to prepare the necessary files for *data/train* and *data/test*.	The files required for *data/train* and *data/test* along with their formats are as follows:

* **text**

	Contains the utterance-by-utterance transcript of the corpus and will have the format: **UTTERANCE-ID word1 word2 word3**
	
	For example, consider the following line **`MER1 SIL kadxawulxai SIL wanxanggeu SIL`**. Here, *MER1* refers to the *Utterance ID* and *SIL kadxawulxai SIL wanxanggeu SIL* refers to the transcription corresponding to the said Utterance ID
  
* **wav.scp**
	
	Contains the location for each of the audio files and will have the format: **FILE-ID path of file**.
	
	An example format is given below
	```
	MER1 /home/bibliophildamsel/kaldi/egs/MER_severe_base/newwave/train/MER1.wav
	```
	
* **utt2spk**

	Contains the mapping of each utterance to the respective speaker and will have the format: **UTTERANCE-ID SPEAKER-ID**
	
	If you are working with a single speaker (as in the case of observing unique speaker characteristics, like computing Goodness of Pronunciation), it is advisable to make your *Speaker ID* the same as your *Utterance ID* to achieve better performance. 
	
* **spk2utt**

	Contains the speaker to utterance mapping and will have the format: **SPEAKER-ID UTTERANCE-ID**
	
	For single speaker case, it will be **SPEAKER-ID SPEAKER-ID**
	
* **segments**

	A segments file is useful in cases where you have an audio file that does not have individual segments file for every utterance. It has the format: **UTTERANCE-ID FILE-ID START-TIME STOP-TIME**
	
	An example of how every entry in a segments file is supposed to look like is given below. 
	```
	MKA1 MKA1 0.0 1.794937
	MKA10 MKA10 0.0 2.118937
	MKA100 MKA100 0.0 3.828000
	```
	
	The contents of the *./prepare_train_test.sh* script is as follows:
	```
	#!/bin/bash
	
	cut -d' ' -f3- wave_text/train.trans > wave_text/train.txt
	cut -d' ' -f3- wave_text/test.trans > wave_text/test.txt
	
	#create wav.scp
	filepath1=newwave/train/*.wav
	filepath2=newwave/test/*.wav
	for var in $filepath1
	do
	filename1=$(basename "$var")
	filename1="${filename1%.*}"
	printf "$filename1\n" >> wave_text/speakerID_train
	done
	
	for var in $filepath2
	do
	filename2=$(basename "$var")
	filename2="${filename2%.*}"
	printf "$filename2\n" >> wave_text/speakerID_test
	done
	
	sort -o wave_text/speakerID_train{,}
	sort -o wave_text/speakerID_test{,}
	
	#for x in train test
 	sed 's;FC01;/home/balasurya/kaldi/egs/FC01_normal/newwave/train/FC01;g' wave_text/speakerID_train > wave_text/train_wavelist
	sed 's;FC01;/home/balasurya/kaldi/egs/FC01_normal/newwave/test/FC01;g' wave_text/speakerID_test > wave_text/test_wavelist
	sed -i 's/$/.wav/g' wave_text/train_wavelist
	sed -i 's/$/.wav/g' wave_text/test_wavelist
	#do
	#sed 's;MER;/home/bibliophildamsel/kaldi/egs/MER_severe_base/newwave/train/MER;g' wave_text/speakerID_$x > wave_text/${x}_wavelist
	#sed -i 's/$/.wav/g' wave_text/${x}_wavelist
	#done
	paste wave_text/speakerID_train wave_text/train_wavelist > data/train/wav.scp
	paste wave_text/speakerID_test wave_text/test_wavelist > data/test/wav.scp
	sed -i 's/\t/ /g' data/train/wav.scp
	sed -i 's/\t/ /g' data/test/wav.scp
	
	#create utt2spk
	for x in train test
	do
	paste wave_text/speakerID_$x wave_text/speakerID_$x > data/$x/utt2spk
	sed -i 's/\t/ /g' data/$x/utt2spk
	done
	
	#create spk2utt
	for x in train test 
	do
	utils/fix_data_dir.sh data/$x
	done
	
	#create text
	paste wave_text/speakerID_train wave_text/train.txt > data/train/text
	paste wave_text/speakerID_test wave_text/test.txt > data/test/text
	sed -i 's/\t/ /g' data/train/text
	sed -i 's/\t/ /g' data/test/text 
	
	#create segments
	bash ./local/create_segments.sh
	echo "DONE"
	```

	The script *./local/segments.sh* creates the necessary segments file. This step is optional. However, as mentioned earlier, if you haven't segmented an audio file into individual files according to the utterances, then create the *segments.sh* script in the local subdirectory which contains the following lines of code.
```
#!/bin/bash

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

for x in train test; do
cut -d' ' -f1 data/$x/text > data/$x/utteranceIDs
cut -d' ' -f1 data/$x/wav.scp > data/$x/fileIDs
wav-to-duration scp:data/$x/wav.scp ark,t:data/$x/wav.ark || exit 1
awk -v dur=data/$x/wav.ark \
'BEGIN{while(getline < dur) { durH[$1]=$2; } }
   {wav=$1;
     printf("0.0 %f\n", durH[wav]);
   }
  ' data/$x/utt2spk > data/$x/speaker_durn || exit 1 
paste data/$x/utteranceIDs data/$x/fileIDs data/$x/speaker_durn > data/$x/segments
rm data/$x/utteranceIDs data/$x/fileIDs data/$x/speaker_durn
sed -i 's/\t/ /g' data/$x/segments
done
```
### Preparing the Dictionary
	
Prepare a file called *lexicon.txt* which will contain all the words used in your dataset. If you are building a phone-level ASR (which is advisable), the lexicon.txt will have the format: **WORD PHONE**
	
	An example for the same is given below.
	```
	SIL SIL
	kadxawulxai k a dx a w u lx ai
	wanxanggeu w a nx a ng g eu
	mayil m a y i l
	agawum a g a w u m
	mazhai m a zh ai
	```
	
Create a script *prepare_dict.sh* with the following lines of code and call the same to prepare the dictionary. 
```
#/bin/bash

if [ -f path.sh ]; then . ./path.sh; fi

dir=data/local/dict

mkdir -p $dir 

#create lexicon.txt
sort lexicon.txt > $dir/lexicon.txt

printf "SIL\n" > $dir/silence_phones.txt
printf "SIL\n" > $dir/optional_silence.txt

#create nonsilence and phones.txt
cut -d ' ' -f 2- $dir/lexicon.txt | sed 's/ /\n/g' | sort -u > $dir/phones.txt
grep -v -F -f $dir/silence_phones.txt $dir/phones.txt > $dir/nonsilence_phones.txt
#create phn lexicon
paste $dir/phones.txt $dir/phones.txt > phn_lexicon.txt

#create words.txt and extra questions.txt 
cut -d ' ' -f1 $dir/lexicon.txt | sort -u > $dir/words.txt 
cat $dir/silence_phones.txt| awk '{printf("%s ", $1);} END{printf "\n";}' > $dir/extra_questions.txt || exit 1;
cat $dir/nonsilence_phones.txt | perl -e 'while(<>){ foreach $p (split(" ", $_)) {
  $p =~ m:^([^\d]+)(\d*)$: || die "Bad phone $_"; $q{$2} .= "$p "; } } foreach $l (values %q) {print "$l\n";}' \
 >> $dir/extra_questions.txt || exit 1;
 
#create lm text
cut -d' ' -f2- data/train/text | sed -e 's:^:<s> :' -e 's:$: </s>:' > $dir/lm_train.text

echo "Dictionary Preparation Succeeded"
```

Also, to avoid any syllable not found errors being thrown while running the prepare_lang.sh script (which mostly arises for noise syllables like **SIL**, **UNK**, or **SMP**), include that syllable in your lexicon.txt. 

For word-level ASR, the phones will be replaced by words in the *lexicon.txt* file.

### Language Preparation
	
run `./utils/prepare_lang.sh --position-dependent-phones true data/local/dict "SIL" data/local/lang data/lang` to prepare the language model.
	
Here, the parameter *position-dependent-phones* being set true assigns markers namely _B, _E, _I, and _S to the appropriate phones. Meaning, a phone at the beginning will be marked with "_B" (or the beginning marker), a phone at the end will be marked with "_E" (or the end marker), phones which occur in between the start and end phones will be marked with an "_I" (or the internal marker), and phones that occur independently will be assigned an "_S" (or the singleton marker). 
	
These markers help in alignment by providing the model insights into where a sentence starts and where it ends.
	
6. **LM Construction**

	Create a file named *create_LM.sh* with the following lines of code and call the same to create the language model.

```	
#/bin/bash

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
```

Employing various smoothing-typed language model impacts the WER significantly, so, you might need to choose the right one depending on your dataset.

### MFCC Feature Extraction
Majority of the datasets use 40-dimensional MFCC features. However, iVector features of dimension 100 play a significant role when it comes to the computation of the Goodness of Pronunciation Scores and would be discussed in later sections.
```
# extract mfcc features for train and test
./steps/make_mfcc.sh --cmd run.pl --nj 4 --config ./conf/mfcc.conf data/train exp/make_mfcc/train mfcc 
./steps/make_mfcc.sh --cmd run.pl --nj 2 --config ./conf/mfcc.conf data/test exp/make_mfcc/test mfcc 

# compute cepstral mean and variance normalisation for the train and test utterances
./steps/compute_cmvn_stats.sh data/train exp/make_mfcc/train mfcc
./steps/compute_cmvn_stats.sh data/test exp/make_mfcc/test mfcc

# detect voice activity in the speech 
./steps/compute_vad_decision.sh --nj 4 data/train exp/make_vad/train vad
./steps/compute_vad_decision.sh --nj 2 data/test exp/make_vad/test vad
```

### Monophone Training
```
./steps/train_mono.sh --nj 12 --cmd run.pl --config conf/mfcc.conf data/train data/lang_test_bg exp/mono
```
**Construct Graph**
```
./utils/mkgraph.sh data/lang_test_bg exp/mono exp/mono/graph
```
**Decode**
```
./steps/decode.sh --config conf/decode.config --nj 2 --cmd run.pl exp/mono/graph data/test exp/mono/decode
```

While decoding, it is better to stick with a *lattice-beam* size of 1 and keep the *acoustic-weight (acwt)* parameter low to increase the dependency on the language model for a lower WER, translating to a better accuracy. 

To display all the WER for easier comparison and inference making, run `cat exp/mono/decode/wer_* | grep "WER" | sort -n > exp/mono/WER.txt`

**Align Graph**
```
./steps/align_si.sh --nj 12 --cmd run.pl --use-graphs true data/train data/lang exp/mono exp/mono_ali
```

### Triphone Training
```
./steps/train_deltas.sh --cmd run.pl --config conf/mfcc.conf 2000 10000 data/train data/lang exp/mono_ali exp/tri
```
**Construct Graph**
```
./utils/mkgraph.sh data/lang_test_bg exp/tri exp/tri/graph
```
**Decode**
```
./steps/decode.sh --config conf/decode.config --nj 2 --cmd run.pl exp/tri/graph data/test exp/tri/decode
```

To display all the WER for easier comparison and inference making, run `cat exp/tri/decode/wer_* | grep "WER" | sort -n > exp/tri/WER.txt`

**Align Graph**
```
./steps/align_si.sh --nj 12 --cmd run.pl --use-graphs true data/train data/lang exp/tri exp/tri_ali
```
### Triphone + LDA-MLLT Training
```
./steps/train_lda_mllt.sh --cmd run.pl --config conf/mfcc.conf 2500 15000 data/train data/lang exp/tri_ali exp/tri1
```

**Construct Graph**
```
./utils/mkgraph.sh data/lang_test_bg exp/tri1 exp/tri1/graph
```

**Decode**
```
./steps/decode.sh --config conf/decode.config --nj 2 --cmd run.pl exp/tri1/graph data/test exp/tri1/decode
```

To display all the WER for easier comparison and inference making, run `cat exp/tri1/decode/wer_* | grep "WER" | sort -n > exp/tri1/WER.txt`

**Align Graph**
```
./steps/align_si.sh --nj 12 --cmd run.pl --use-graphs true data/train data/lang exp/tri1 exp/tri1_ali
```
### Triphone + LDA-MLLT + SAT Training
```
./steps/train_sat.sh --cmd run.pl --config ./conf/mfcc.conf 4000 16000 data/train data/lang exp/tri1_ali exp/tri2
```
**Construct Graph**
```
./utils/mkgraph.sh data/lang_test_bg exp/tri2 exp/tri2/graph
```
**Decode**
```
./steps/decode_fmllr.sh --nj 2 --cmd run.pl exp/tri2/graph data/test exp/tri2/decode_test
```
To display all the WER for easier comparison and inference making, run `cat exp/tri2/decode_test/wer_* | grep "WER" | 

**Align Graph**
```
steps/align_fmllr.sh --nj 12 --cmd run.pl --use-graphs true data/train data/lang exp/tri2 exp/tri2_ali
```
### Extraction of iVector Features
1. **Constructing a diagonal UBM (dubm)**

	UBM (universal background models) are often used with Gaussian Mixture Models. Diagonal UBMs offer a base for the creation of ivector subspace modelling
i-Vector subspace modeling is one of the recent methods that has become the state of the art technique in this domain. 

	This method largely provides the benefit of modeling both the intra-domain and interdomain variabilities into the same low dimensional space.

```
./steps/nnet/ivector/train_diag_ubm.sh --cmd run.pl --nj 4 data/train 500 exp/diag_ubm/train
./steps/nnet/ivector/train_diag_ubm.sh --cmd run.pl --nj 2 data/test 500 exp/diag_ubm/test
```
2. **Building an iVector Extractor**

```
./steps/nnet/ivector/train_ivector_extractor.sh --cmd run.pl --num-processes 1 --num-threads 1 --nj 4 data/train exp/diag_ubm/train exp/extractor
```

Create a script *extract_gcmvn_stats.sh* in the local subdirectory to construct the global_cmvn.stats file with the following lines of code.
```
#!/bin/bash

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

for feats in 'ls data/train/' 'ls data/test/' ; do
	compute-cmvn-stats --binary scp:data/train/feats.scp exp/extractor/global_cmvn.stats
done
```
Next, run `cp ./conf/online_cmvn.conf exp/extractor/`.

Finally, copy cmvn_stats, splice_opts, final.mdl, and final.mat files from the LDA_MLLT alignment directory into the extractor directory.

3. **Extracting iVector features of dimension 100**
```
./steps/online/nnet2/extract_ivectors_online.sh --nj 4 --config conf/mfcc.conf --num-gselect 5 --ivector-period 12 --use-vad true --cmd run.pl data/train exp/extractor exp/make_ivectors/train
./steps/online/nnet2/extract_ivectors_online.sh --nj 2 --config conf/mfcc.conf --num-gselect 5 --ivector-period 12 --use-vad true --cmd run.pl data/test exp/extractor exp/make_ivectors/test
```

### NNET2 Training
```
./steps/nnet2/train_tanh.sh --config ./conf/mfcc_hires.conf --initial-learning-rate 0.04 --final-learning-rate 0.004 --num-jobs-nnet 12 --num-hidden-layers 1 --num-epochs 10 --hidden-layer-dim 256 --cmd run.pl data/train data/lang exp/tri1_ali exp/nnet2
```

Alter the parameters like learning rate, hidden layer dimension, number of hidden layers, and number of epochs depending upon your dataset

**Decode**
```
./steps/nnet2/decode.sh --cmd run.pl --lattice-beam 1 --nj 2 --config conf/decode.config exp/tri1/graph data/test exp/nnet2/decode_test
```

To display all the WER for easier comparison and inference making, run `cat exp/nnet2/decode_test/wer_* | grep "WER" | sort -n > exp/nnet2/WER.txt`

**Align Graph**
```
./steps/nnet2/align.sh –nj 12 data/train data/lang exp/nnet2 exp/nnet2_ali
```
### NNET3 Training
Commonly used these days in Kaldi, NNET3 models are Kaldi's developer, Dan Povey's Deep Neural Network recipes that offer space for better performance accuracy with option to work around with various layers and performance enhancing input nodes.

To include iVector as a node in your NNET3 model, you need to generate a configs file by creating an xconfigs file using the following lines of code that have to be written by the user on to the local subdirectory in a script named *gen_configs.sh*

```
#!/bin/bash

num_targets=$(<exp/mono2/graph/num_pdfs)

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

mkdir -p exp/nnet3/configs

#defining the xconfig file
cat <<EOF > nnet.xconfig
input dim=100 name=ivector
input dim=40 name=input
fixed-affine-layer name=lda input=Append(-4,-3,-2,-1,0,1,2,3,4,ReplaceIndex(ivector,t,0)) dim=460 affine-transform-file=exp/nnet2/lda.mat 
output-layer name=output dim=$num_targets input=Append(-1,0,1)
EOF

python3 ./steps/nnet3/xconfig_to_configs.py --xconfig-file nnet.xconfig --config-dir exp/nnet3/configs
python3 ./steps/nnet3/xconfig_to_configs.py --xconfig-file nnet.xconfig --config-dir exp/nnet3

echo "DONE"
```

Consequently, you may start training your model for NNET3-DNN, or NNET3-LSTM. The shell scripts for each of the models are deprecated and hence it's advisable to use the .py files namely *train_dnn.py* for DNN and *train_rnn.py* for LSTM by creating appropriate shell scripts which have the format as shown below. 

```
#!/bin/bash

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

python3 ./steps/nnet3/train_dnn.py --feat.online-ivector-dir exp/make_ivectors/train --trainer.optimization.num-jobs-final 1 \
	--trainer.num-epochs 5 \
	--trainer.optimization.initial-effective-lrate 0.04 --trainer.optimization.final-effective-lrate 0.004 \
	--trainer.compute-per-dim-accuracy true --cmd run.pl --use-gpu no \
	--feat-dir data/train --lang data/lang --ali-dir exp/tri1_ali --dir exp/nnet3 || exit 1

echo "DONE"
```

Run the scripts.
```
./local/run_tdnn.sh 
```
**Construct Graph**
``` 
./utils/mkgraph.sh data/lang_test_bg exp/nnet3 exp/nnet3/graph
```

**Decode**
```
./steps/nnet3/decode.sh --cmd run.pl --nj 2 --online-ivector-dir exp/make_ivectors/test --use-gpu false --config conf/decode.config exp/nnet3/graph data/test exp/nnet3/decode_test
```

To display all the WER for easier comparison and inference making, run `cat exp/mono_nnet3/decode_test/wer_* | grep "WER" | sort -n > exp/mono_nnet3/WER.txt`.

**Align Graph**
```
./steps/nnet3/align.sh --cmd run.pl --nj 12 --use-gpu false --online-ivector-dir exp/make_ivectors/train data/train data/lang exp/nnet3 exp/nnet3_ali
```

Also, if you have very less examples, say utterances in the range of 300-400, go to `./steps/nnet3/get_egs.sh` and change the number of utterances subset to 40-50 to facilitate deep neural network training even on smaller datasets. 

### Visualize FSTs
```
cat data/lang_test_bg/L.fst | fstdraw --portrait=true --isymbols=data/lang_test_bg/phones.txt --osymbols=data/lang_test_bg/words.txt | dot -Tpdf > data/lang_test_bg/lattice.pdf
```
