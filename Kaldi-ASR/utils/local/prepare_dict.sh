#!/bin/bash

# Copyright 2013   (Authors: Daniel Povey, Bagher BabaAli)

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
# WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE,
# MERCHANTABLITY OR NON-INFRINGEMENT.
# See the Apache 2 License for the specific language governing permissions and
# limitations under the License.

# Call this script from one level above, e.g. from the s3/ directory.  It puts
# its output in data/local/.

# The parts of the output of this that will be needed are
# [in data/local/dict/ ]
# lexicon.txt
# extra_questions.txt
# nonsilence_phones.txt
# optional_silence.txt
# silence_phones.txt

# run this from ../
srcdir=data/local/data
dir=data/local/dict
lmdir=data/local/nist_lm
tmpdir=data/local/lm_tmp

mkdir -p $dir $lmdir $tmpdir

[ -f path.sh ] && . ./path.sh

#(1) Dictionary preparation:

# Make phones symbol-table (adding in silence and verbal and non-verbal noises at this point).
# We are adding suffixes _B, _E, _S for beginning, ending, and singleton phones.

# silence phones, one per line.
echo SIL > $dir/silence_phones.txt
echo SIL > $dir/optional_silence.txt

# nonsilence phones; on each line is a list of phones that correspond
# really to the same base phone.

# Create the lexicon, which is just an identity mapping
#sed $'s/\t/ /g' $srcdir/train_phn.trans > $srcdir/temp_phn.trans
#sed $'s/\t/ /g' $srcdir/train.trans > $srcdir/temp_wrd.trans
cut -d' ' -f2- $srcdir/train_phn.trans | tr ' ' '\n' | sort -u > $dir/phones.txt
#cp data/local/phones.txt $dir/phones.txt
cut -d' ' -f2- $srcdir/train.trans | tr ' ' '\n' | sort -u > $dir/words.txt
#cp words_new.txt $dir/words.txt
#cat $dir/phones.txt words.txt > $dir/words.txt
#sed -i '/SIL/d' ./$dir/words.txt
paste $dir/phones.txt $dir/phones.txt > $dir/phn_lexicon.txt || exit 1;
grep -v -F -f $dir/silence_phones.txt $dir/phones.txt > $dir/nonsilence_phones.txt 
#copied word level dictionary from recognition lexicon.txt
# A few extra questions that will be added to those obtained by automatically clustering
# the "real" phones.  These ask about stress; there's also one for silence.
cat $dir/silence_phones.txt| awk '{printf("%s ", $1);} END{printf "\n";}' > $dir/extra_questions.txt || exit 1;
cat $dir/nonsilence_phones.txt | perl -e 'while(<>){ foreach $p (split(" ", $_)) {
  $p =~ m:^([^\d]+)(\d*)$: || die "Bad phone $_"; $q{$2} .= "$p "; } } foreach $l (values %q) {print "$l\n";}' \
 >> $dir/extra_questions.txt || exit 1;

# (2) Create the phone bigram LM
if [ -z $SRILM ] ; then
  export SRILM=$KALDI_ROOT/../tools/srilm-1.6.0
fi
export PATH=${PATH}:$SRILM/bin/i686-m64
#if ! command -v prune-lm >/dev/null 2>&1 ; then
 # echo "$0: Error: the IRSTLM is not available or compiled" >&2
  #echo "$0: Error: We used to install it by default, but." >&2
  #echo "$0: Error: this is no longer the case." >&2
  #echo "$0: Error: To install it, go to $KALDI_ROOT/tools" >&2
  #echo "$0: Error: and run extras/install_irstlm.sh" >&2
  #exit 1
#fi
sed -i 's/\t/ /g' $srcdir/train_phn.trans
cut -d' ' -f2- $srcdir/train.trans | sed -e 's:^:<s> :' -e 's:$: </s>:' > $srcdir/lm_train.text

ngram-count -text $srcdir/lm_train.text -order 2 \
  -lm $tmpdir/lm_phone_bg.ilm.gz

#compile-lm $tmpdir/lm_phone_bg.ilm.gz -t=yes /dev/stdout | \
#grep -v unk | gzip -c > $lmdir/lm_phone_bg.arpa.gz 
cp -r $tmpdir/lm_phone_bg.ilm.gz $lmdir/
mv $lmdir/lm_phone_bg.ilm.gz $lmdir/lm_phone_bg.arpa.gz
cp -r $tmpdir/lm_phone_bg.ilm.gz $lmdir/


echo "Dictionary & language model preparation succeeded"
