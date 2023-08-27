#!/bin/bash

#lst= 113 116 118 119 120 121 122 125 145 151 153 158 159 161 162 166 174 175 176 179 187 188 190 193 194 197
#for d in 113 116 118 119 120 121 122 125 145 151 153 158 159 161 166 174 175 176 179 187 188 190 193 194 197 ; do
#	mv newwave/train/FC01_$d.wav newwave/test/
#	mv newwave/train/FC01_$d.lab newwave/test/
#done
#mkdir -p newwave/test/FC01
#mkdir -p newwave/test/FC05
mkdir -p newwave/test

DIFF=$((365-1+1))
RANDOM=$$
for i in `seq 36`
do
var1=$(($(($RANDOM%$DIFF))+1))
cp newwave/train/FSI$var1.wav newwave/test/
cp newwave/train/FSI$var1.lab newwave/test/
done

echo "DONE"
