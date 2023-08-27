# /bin/bash

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
