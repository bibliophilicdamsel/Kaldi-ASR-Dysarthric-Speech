#!/usr/bin/env bash

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

nj=12
for part in train test; do
    for i in `seq 1 $nj`; do
      utils/sym2int.pl -f 2- data/lang_test_bg/words.txt \
        data/$part/split${nj}/$i/text \
        > data/$part/split${nj}/$i/text.int
    done
    
    utils/sym2int.pl -f 2- data/lang_test_bg/phones.txt < data/local/text-phone > data/local/text-phone.int
done

echo "DONE"
