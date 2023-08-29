#!/bin/bash

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

mkdir -p exp/compute_gop/gop
for i in 3
do
python3 ./local/prop_gop_eqn.py exp/compute_gop/segments/tmp_segments_$i.txt exp/compute_gop/ids/tmp_t_ids_$i.txt \
	exp/compute_gop/phones/tmp_phones_$((i+1)).txt exp/compute_gop/gop/gop_outfile_$i.txt
done
#exp/compute_gop/posterior_infile.ark exp/compute_gop/align_infile.txt exp/compute_gop/gop_output.txt

echo "DONE"
