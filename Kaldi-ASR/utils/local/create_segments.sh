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
echo "DONE"
