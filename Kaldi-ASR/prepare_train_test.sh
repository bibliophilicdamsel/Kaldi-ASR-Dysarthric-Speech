#!/bin/bash

#ls -v /home/bibliophildamsel/kaldi/egs/MER_severe_base/newwave/train/*.wav | sort  > wave_text/train_wavelist
#ls -v /home/bibliophildamsel/kaldi/egs/MER_severe_base/newwave/test/*.wav > wave_text/test_wavelist
cut -d' ' -f3- wave_text/train.trans > wave_text/train.txt
cut -d' ' -f3- wave_text/test.trans > wave_text/test.txt

#for one speaker- create wav.scp
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

for x in train test
do
sed 's;FSI;/home/bibliophildamsel/kaldi/egs/FSI_mild_base/newwave/train/FSI;g' wave_text/speakerID_$x > wave_text/${x}_wavelist
sed -i 's/$/.wav/g' wave_text/${x}_wavelist
done

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
