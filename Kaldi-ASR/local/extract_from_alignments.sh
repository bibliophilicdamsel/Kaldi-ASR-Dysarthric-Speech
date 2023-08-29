# /bin/bash

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

nj=12

for((i=1; i<=$nj; i++)); do
	show-alignments exp/mono_nnet3/phones.txt exp/nnet3_ali/final.mdl ark:exp/nnet3_ali/ali.$i > exp/nnet3_ali/show_ali_$i.txt
done

cat exp/nnet3_ali/show_ali_*.txt > exp/nnet3_ali/alignments.txt
awk '$0' exp/nnet3_ali/alignments.txt > exp/compute_gop/align_infile.txt

mkdir -p exp/compute_gop/phones
mkdir -p exp/compute_gop/ids
mkdir -p exp/compute_gop/segments

for((i=1; i<=200; i++))
do
rs=`expr $i % 2`

if [ "$rs" == 0 ] 
then
cat exp/compute_gop/align_infile.txt | head -$i | tail -1 | sed 's/ /\n/g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '/^$/d' | \
 sed '1d' > exp/compute_gop/phones/tmp_phones_$i.txt
else
cat exp/compute_gop/align_infile.txt | head -$i | tail -1 | sed 's/\[ /\n/g' | sed 's/\ ]//g' | sed 's/ /\n/g' | sed 's/^[ \t]*//;s/[ \t]*$//' | \
	sed '/^$/d' | sed '1d' > exp/compute_gop/ids/tmp_t_ids_$i.txt
cat exp/compute_gop/align_infile.txt | head -$i | tail -1 | sed 's/\[ /\n/g' | sed 's/\ ]//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '1d' | \
	 awk '{print NF}' > exp/compute_gop/segments/tmp_segments_$i.txt
fi
done
#cat exp/compute_gop/align_infile.txt | head -1 | sed 's/\[ /\n/g' | sed 's/\ ]//g' | sed 's/ /\n/g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '/^$/d' | sed '1d' > exp/compute_gop/tmp_t_ids.txt
#cat exp/compute_gop/align_infile.txt | head -1 | sed 's/\[ /\n/g' | sed 's/\ ]//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '1d' | awk '{print NF}' > exp/compute_gop/tmp_segments.txt
#cat exp/compute_gop/align_infile.txt | head -2 | tail -1 | sed 's/ /\n/g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '/^$/d' | sed '1d' > exp/compute_gop/tmp_phones.txt
