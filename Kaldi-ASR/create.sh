# /bin/bash

if [ -f path.sh ]; then . ./path.sh; fi

#create text 
#for one speaker
for d in 113 116 118 119 120 121 122 125 145 151 153 158 159 161 166 174 175 176 179 187 188 190 193 194 197
do
printf "FC01_$d\n" >> wave_text/speakerID_test.txt
done
sort speakerID.txt > wave_text/speakerID.txt

cut -d' ' --complement -f1 train.trans > wave_text/train.txt
#| sort -u 
cut -d' ' --complement -f1 test.trans  > wave_text/test.txt
#| sort -u >
paste wave_text/speakerID.txt wave_text/train.txt > data/train/text
paste wave_text/speakerID_test.txt wave_text/test.txt > data/test/text
sed -i 's/\t/ /g' data/train/text
sed -i 's/\t/ /g' data/test/text

#1. #for many_speaker
./prepare_data.sh
cut -d' ' -f3- wave_text/train.trans > wave_text/train.txt
cut -d' ' -f3- wave_text/test.trans > wave_text/test.txt
paste wave_text/speakerID_train wave_text/train.txt > data/train/text
paste wave_text/speakerID_test wave_text/test.txt > data/test/text
sed -i 's/\t/ /g' data/train/text
sed -i 's/\t/ /g' data/test/text

#create wav.scp
#for one speaker
ls -v /home/bibliophildamsel/kaldi/egs/normal_base/newwave/train/*.wav > wave_text/train_wavelist
ls -v /home/bibliophildamsel/kaldi/egs/normal_base/newwave/test/*.wav > wave_text/test_wavelist
sort -o wave_text/train_wavelist{,}
paste wave_text/speakerID.txt wave_text/train_wavelist > data/train/wav.scp
paste wave_text/speakerID_test.txt wave_text/test_wavelist > data/test/wav.scp
sed -i 's/\t/ /g' data/train/wav.scp
sed -i 's/\t/ /g' data/test/wav.scp

#2. for many speaker- create wavelists
for name in FC01 FC05 MC01 MC05
do
ls -v /home/bibliophildamsel/kaldi/egs/normal_base/newwave/train/$name/*.wav > wave_text/train_wavelist_$name
ls -v /home/bibliophildamsel/kaldi/egs/normal_base/newwave/test/$name/*.wav > wave_text/test_wavelist_$name
cat wave_text/train_wavelist_* > wave_text/train_wavelist
cat wave_text/test_wavelist_* > wave_text/test_wavelist
rm wave_text/train_wavelist_* wave_text/test_wavelist_*
sort -o wave_text/train_wavelist{,}
sort -o wave_text/test_wavelist{,}
done
rm wave_text/train_wavelist_* wave_text/test_wavelist_*

#for many speaker- create wav.scp
for name in FC01 FC05 MC01 MC05
do
filepath1=newwave/train/$name/*.wav
filepath2=newwave/test/$name/*.wav
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

paste wave_text/speakerID_train wave_text/train_wavelist > data/train/wav.scp
paste wave_text/speakerID_test wave_text/test_wavelist > data/test/wav.scp
sed -i 's/\t/ /g' data/train/wav.scp
sed -i 's/\t/ /g' data/test/wav.scp
done

#3. #create utt2spk
for x in train test
do
cut -d'_' -f1 wave_text/speakerID_$x > wave_text/ID_$x
paste wave_text/speakerID_$x wave_text/ID_$x > data/$x/utt2spk
rm wave_text/ID_$x
sed -i 's/\t/ /g' data/$x/utt2spk
done
#sed 's/$/ FC01/' wave_text/speakerID.txt > data/train/utt2spk
#sed 's/$/ FC01/' wave_text/speakerID_test.txt > data/test/utt2spk

#4. #create spk2utt
for x in train test 
do
utils/fix_data_dir.sh data/$x
done

#create_segments
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

#(or call script ./local/create_segments.sh)

#prepare dictionary
./prepare_dict.sh

#prepare LM
./utils/prepare_lang.sh --position-dependent-phones true data/local/dict "SIL" data/local/lang data/lang

#create testing LM
./create_LM.sh
