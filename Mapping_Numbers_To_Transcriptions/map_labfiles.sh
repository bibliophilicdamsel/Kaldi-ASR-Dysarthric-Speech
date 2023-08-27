#!/bin/bash

#mkdir -p FGA
mkdir -p FGA/audio/222-241
mkdir -p FGA/label/222-241
mkdir -p FGA/text/222-241

for((i=1; i<=10; i++))
do
cp GA_222-241/221-240\($i\).wav FGA/audio/222-241/222-241\($i\).wav
cp GA_222-241/221-240\($i\).lab FGA/label/222-241/222-241\($i\).lab
done
cp GA_222-241/Phones_Text_222-241.txt FGA/text/222-241/
cp GA_222-241/Words_Text_222-241.txt FGA/text/222-241/

for((j=1; j<=10; j++))
do
python3 map_table.py FGA/text/222-241/Phones_Text_222-241.txt FGA/text/222-241/Words_Text_222-241.txt FGA/label/222-241/222-241\($j\).lab \
	FGA/label/222-241/222-241\($j\).wrdlab FGA/label/222-241/222-241\($j\).phnlab
done

sed -i 's/\t/ /g' FGA/label/222-241/*.phnlab
sed -i 's/\t/ /g' FGA/label/222-241/*.wrdlab
