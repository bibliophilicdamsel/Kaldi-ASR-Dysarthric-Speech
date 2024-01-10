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
