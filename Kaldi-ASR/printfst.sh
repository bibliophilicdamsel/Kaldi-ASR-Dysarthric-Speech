#!/bin/bash

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

#./data/lang/L.fst | ../../tools/openfst-1.7.2/bin/fstprint --osymbols=data/lang/words.txt --isymbols=data/lang/phones.txt
cut -d' ' -f1 data/local/lang/lexiconp.txt > data/local/lang/words_tmp.txt
cat data/local/dict/phones.txt data/local/lang/words_tmp.txt | sort | uniq  | awk '
  BEGIN {
    print "<eps> 0";
  }
  {
    if ($1 == "<s>") {
      print "<s> is in the vocabulary!" | "cat 1>&2"
      exit 1;
    }
    if ($1 == "</s>") {
      print "</s> is in the vocabulary!" | "cat 1>&2"
      exit 1;
    }
    printf("%s %d\n", $1, NR);
  }
  END {
    printf("#0 %d\n", NR+1);
    printf("<s> %d\n", NR+2);
    printf("</s> %d\n", NR+3);
  }' > words_tmp.txt || exit 1;

echo "DONE"
