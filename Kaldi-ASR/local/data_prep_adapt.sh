#!/bin/bash

# Copyright 2013   (Authors: Bagher BabaAli, Daniel Povey, Arnab Ghoshal)
#           2014   Brno University of Technology (Author: Karel Vesely)
# Apache 2.0.

if [ $# -ne 1 ]; then
   echo "Argument should be the Timit directory, see ../run.sh for example."
   exit 1;
fi

dir=`pwd`/data/local/data
lmdir=`pwd`/data/local/nist_lm
mkdir -p $dir $lmdir
local=`pwd`/local
utils=`pwd`/utils
conf=`pwd`/conf

. ./path.sh # Needed for KALDI_ROOT
export PATH=${PATH}:$KALDI_ROOT/tools/srilm-1.6.0/bin/i686-m64
sph2pipe=$KALDI_ROOT/tools/sph2pipe_v2.5/sph2pipe
if [ ! -x $sph2pipe ]; then
  echo "Could not find (or execute) the sph2pipe program at $sph2pipe";
  exit 1;
fi

#[ -f $conf/test_spk.list ] || error_exit "$PROG: Eval-set speaker list not found.";
#[ -f $conf/dev_spk.list ] || error_exit "$PROG: dev-set speaker list not found.";

# First check if the train & test directories exist (these can either be upper-
# or lower-cased
#if [ ! -d $*/TRAIN -o ! -d $*/TEST ] && [ ! -d $*/train -o ! -d $*/test ]; then
 # echo "timit_data_prep.sh: Spot check of command line argument failed"
  #echo "Command line argument must be absolute pathname to TIMIT directory"
  #echo "with name like /export/corpora5/LDC/LDC93S1/timit/TIMIT"
  #exit 1;
#fi

# Now check what case the directory structure is
uppercased=false
train_dir=trainadapt
if [ -d $*/TRAIN ]; then
  uppercased=true
  train_dir=TRAIN
fi

tmpdir=$(mktemp -d /tmp/kaldi.XXXX);
trap 'rm -rf "$tmpdir"' EXIT

# Get the list of speakers. The list of speakers in the 24-speaker core test 
# set and the 50-speaker development set must be supplied to the script. All
# speakers in the 'train' directory are used for training.
if $uppercased; then
 # tr '[:lower:]' '[:upper:]' < $conf/dev_spk.list > $tmpdir/dev_spk
 # tr '[:lower:]' '[:upper:]' < $conf/test_spk.list > $tmpdir/test_spk
  ls -d "$*"/TRAIN/* | sed -e "s:^.*/::" > $tmpdir/trainadapt_spk
else
 # tr '[:upper:]' '[:lower:]' < $conf/dev_spk.list > $tmpdir/dev_spk
 # tr '[:upper:]' '[:lower:]' < $conf/test_spk.list > $tmpdir/test_spk
  ls -d "$*"/trainadapt/* | sed -e "s:^.*/::" > $tmpdir/trainadapt_spk
fi

#cd $dir
for x in trainadapt; do

  # First, find the list of audio files (use only si & sx utterances).
  # Note: train & test sets are under different directories, but doing find on 
  # both and grepping for the speakers will work correctly.
  find $*/$train_dir -iname '*.WAV' | grep -f $tmpdir/${x}_spk > $dir/${x}_sph.flist
  sed -e 's:.*/\(.*\)/\(.*\).WAV$:\1_\2:i' $dir/${x}_sph.flist \
    > $tmpdir/${x}_sph.uttids
  paste $tmpdir/${x}_sph.uttids $dir/${x}_sph.flist \
    | sort -k1,1 > $dir/${x}_sph.scp

cat $dir/${x}_sph.scp | awk '{print $1}' > $dir/${x}.uttids

  
  find $*/$train_dir -iname '*.LAB' \
    | grep -f $tmpdir/${x}_spk > $tmpdir/${x}_phn.flist
  sed -e 's:.*/\(.*\)/\(.*\).LAB$:\1_\2:i' $tmpdir/${x}_phn.flist \
    > $tmpdir/${x}_phn.uttids
while read line; do
    [ -f $line ] || error_exit "Cannot find transcription file '$line'";
    cut -f3 -d' ' "$line" | tr '\n' ' ' | sed -e 's: *$:\n:'
  done < $tmpdir/${x}_phn.flist > $tmpdir/${x}_phn.trans
  paste $tmpdir/${x}_phn.uttids $tmpdir/${x}_phn.trans \
    | sort -k1,1 > $dir/${x}_phn.trans

  #find $*/{$train_dir} -iname '*.WRDLAB' \
   # | grep -f $tmpdir/${x}_spk > $tmpdir/${x}_wrd.flist
  #sed -e 's:.*/\(.*\)/\(.*\).WRDLAB$:\1_\2:i' $tmpdir/${x}_wrd.flist \
   # > $tmpdir/${x}_wrd.uttids
  #while read line; do
   # [ -f $line ] || error_exit "Cannot find transcription file '$line'";
    #cut -f3 -d' ' "$line" | tr '\n' ' ' | sed -e 's: *$:\n:'
  #done < $tmpdir/${x}_wrd.flist > $tmpdir/${x}_wrd.trans
  #paste $tmpdir/${x}_wrd.uttids $tmpdir/${x}_wrd.trans \
   # | sort -k1,1 > $dir/${x}.trans
      

  # Do normalization steps. 
 # cat ${x}.trans | $local/timit_norm_trans.pl -i - -m $conf/phones.60-48-39.map -to 48 | sort > $x.text || exit 1;

  # Create wav.scp
  awk '{printf("%s '$sph2pipe' -f wav %s |\n", $1, $2);}' < $dir/${x}_sph.scp > $dir/${x}_wav.scp

  # Make the utt2spk and spk2utt files.
  cut -f1 -d' '  $dir/$x.uttids | paste -d' ' $dir/$x.uttids - > $dir/$x.utt2spk 
  cat $dir/$x.utt2spk | $utils/utt2spk_to_spk2utt.pl > $dir/$x.spk2utt || exit 1;

  # Prepare gender mapping
  #cat $x.spk2utt | awk '{print $1}' | perl -ane 'chop; m:^.:; $g = lc($&); print "$_ $g\n";' > $x.spk2gender

  # Prepare STM file for sclite:
  wav-to-duration scp:$dir/${x}_wav.scp ark,t:$dir/${x}_dur.ark || exit 1
  awk -v dur=$dir/${x}_dur.ark \
  'BEGIN{ 
     while(getline < dur) { durH[$1]=$2; } 
     print ";; LABEL \"O\" \"Overall\" \"Overall\"";
     print ";; LABEL \"F\" \"Female\" \"Female speakers\"";
     print ";; LABEL \"M\" \"Male\" \"Male speakers\""; 
   } 
   { wav=$1; spk=gensub(/_.*/,"",1,wav); $1=""; ref=$0;
     gender=(substr(spk,0,1) == "f" ? "F" : "M");
     printf("%s 1 %s 0.0 %f <O,%s> %s\n", wav, spk, durH[wav], gender, ref);
   }
  ' $dir/${x}_phn.trans >$dir/${x}.stm || exit 1

  # Create dummy GLM file for sclite:
  echo ';; empty.glm
  [FAKE]     =>  %HESITATION     / [ ] __ [ ] ;; hesitation token
  ' > $dir/${x}.glm
done

echo "Data preparation succeeded"
