#!/bin/bash 

for wavefile in `ls newwave/train/*.wav`; do
	sph_wavfile=$(echo $wavefile | rev | cut -d '/' -f1 | rev | cut -d "." -f1).sph
	#echo $sph_wavfile
	sox ${wavefile} waves/train/${sph_wavfile} 
done
