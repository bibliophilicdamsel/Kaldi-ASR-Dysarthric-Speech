#!/bin/bash 

mkdir -p newwave/train

for((j=1; j<=365; j++)); do
	ffmpeg -i /home/bibliophildamsel/SSN_TDSC/data/mild/FSI/audio/FSI$j.flac newwave/train/FSI$j.wav
done
cp /home/bibliophildamsel/SSN_TDSC/data/mild/FSI/label/*.lab newwave/train/

echo "DONE"
