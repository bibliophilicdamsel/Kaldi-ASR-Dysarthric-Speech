#! /bin/bash

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

file_path= 'exp/mono_nnet3'
#path="../exp/nnet2_online/nnet_ms_a_online"
#source directory for final.mdl and phones.txt

show-transitions exp/mono_nnet3/phones.txt exp/mono_nnet3/final.mdl > exp/compute_gop/show_transitions.txt
#the binary show-transitions will be available in kaldi/src/bin/

echo "Generating lookup-table......."

cat exp/compute_gop/show_transitions.txt | while read -r line;
do

	decider=$(echo "$line" | grep "Transition-id =")

	if [ -n "$decider" ]
	then
		t_id=$(echo "$line" | cut -d' ' -f3)
		t_prob=$(echo "$line" | cut -d' ' -f6)
		echo "$t_id $pdf $t_prob"
	else
		pdf=$(echo "$line" | rev | cut -d' ' -f1 | rev)
	fi

done < exp/compute_gop/show_transitions.txt > exp/compute_gop/lookup_table.txt

