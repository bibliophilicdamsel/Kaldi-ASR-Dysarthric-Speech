## Computing The Goodness of Pronunciation (GOP) Scores Using Kaldi

Goodness of Pronunciation (GOP) Scores vouch for the intelligibility of the speech uttered. Often used to evaluate and draw contrasts between Native Speakers and Accented Speakers, the evaluation metric has found significant application in establishing the severity for disordered speech.

During my internship at the Speech and Language Technologies Lab SSN, with the guidance and direction of our respected HOD Prof. P Vijayalakshmi Mam, I tried evaluating the Goodness of Pronunciation Scores for Dysarthric Speakers. On that note, I'd like to credit the team at IISc (Sweekar Sudhakara *et al*) by giving a shoutout to their paper [<b>An Improved Goodness of Pronunciation (GoP) Measure for Pronunciation Evaluation with DNN-HMM System Considering HMM Transition Probabilities </b>](https://www.isca-speech.org/archive/pdfs/interspeech_2019/sudhakara19_interspeech.pdf) that guided me in carrying out the evaluation of GOP scores for Dysarthric Speakers belonging to various severity classes. 

The procedure for computing the GOP scores are as dictated by the aforementioned paper and have been discussed in the sections that follow suit. 

On a scale of 2-6, the scores obtained take up the values as follows:

1. A score between 2 and 4 was classified as <b>Severe</b>
2. A score between 3 and 4 was classified as <b>Moderate</b>
3. A score between 4 and 5 was classified as <b>Mild</b>
4. A score between 5 and 6 was classified as <b>Normal</b>

Or, in other words, a higher GOP score signified that the speaker was a *Normal* Dysarthric Speaker while a lower GOP score signified that the speaker was a *Severe* Dysarthric Speaker. A GOP score lower than the score obtained for severe speakers but really larger than the one obtained for normal speakers signified that the speaker was *Moderately* Dysarthric.


### Extract the Frame Level Posterior Probabilities Of The Learner's Uttered Speech

To extract the frame level posterior probabilities of the learner's uttered speech, create a .sh file called <i>show_alignments.sh</i> in the local directory by writing the following code snippet and running the same.

1. **If you performed NNET3 training, make use of the command** `nnet3-compute`.
	
	```
	#!/bin/bash

	if [ -f path.sh ]; then . ./path.sh; fi
	./parse_options.sh || exit 1;

	mkdir -p exp/compute_gop

	nnet3-compute --use-gpu=no --online-ivectors=scp:exp/make_ivectors/train \
	ivector_online.scp --use-priors=true --online-ivector-period=12 \
	exp/nnet3_ali/final.mdl scp:data/train/feats.scp \
	ark,t:exp/compute_gop/posterior_infile.ark

	echo "DONE"
	```
2. **If you performed NNET2 training, make use of the command** `nnet-am-compute`.
	```
	#!/bin/bash

	if [ -f path.sh ]; then . ./path.sh; fi
	./parse_options.sh || exit 1;

	mkdir -p exp/compute_gop
	nnet-am-compute --apply-log=true exp/nnet2_ali/final.mdl \
	scp:data/train/feats.scp ark,t:exp/compute_gop/posterior_infile.ark

	echo "DONE"
	```

### Output of The Forced-Alignment Of The Learner's Uttered Speech
To obtain the output of the forced alignment performed on the learner's uttered speech, create a .sh file called *extract_from_alignments.sh* in the local directory by wrting the following code snippet. 

Before running the shell script, extract the .ali files present in your final alignment directory.

```
#!/bin/bash

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
```

It has to be noted that the following code snippet was run for 200 audio files of the same speaker for the purpose of drawing inferences and making conclusions from the GOP scores obtained. You may change the code according to the number of audio files you'd like to evaluate the probabilities for.

### Generate A Lookup Table
Create a .sh file called *gen_lookup_table.sh* in the local directory by penning down the following snippets of code and running it. 

```
#! /bin/bash

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

file_path= 'exp/mono_nnet3'

show-transitions exp/mono_nnet3/phones.txt exp/mono_nnet3/final.mdl > \ 
exp/compute_gop/show_transitions.txt

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
```

>Note: For the steps carried out until now, remember to use the directories according to the appropriate neural network training you have carried out through the course of your work. If you have performed **NNET2 Training**, your *phones.txt* and *final.mdl* files would be the ones in your **NNET2** subdirectory created in your **exp** directory and not the ones in the **NNET3** directory 

### Modify the '.ark' file into a '.txt' file
Create a .sh file called *modify_post.sh* in the local directory using the following lines of code and call it.

```
#! /bin/bash

#the posterior.ark is modified to posterior.txt for the python code

in_file=exp/compute_gop/posterior_infile.ark

cat $in_file | sed -e '1d' | sed -e 's/^[ \t]*//' > exp/compute_gop/posterior.txt 
```
 
### Compute The Goodness of Pronunciation Scores
First, create a python file called *prop_gop_eqn.py* in the local directory by penning the following lines of code.

```
import sys
import math
import os
import subprocess
import pandas as pd
import numpy as np

path = os.getcwd(); 
               
#with open(path + '/exp/compute_gop/tmp_segments.txt','r') as f:
with open(path + '/' + sys.argv[1],'r') as f:
    x = f.readlines();
num_segments = [int(tmp.split(' ')[0]) for tmp in x];
                      
#with open(path + '/exp/compute_gop/tmp_t_ids.txt','r') as f:
with open(path + '/' + sys.argv[2],'r') as f:
    x = f.readlines();
transition_id = [int(tmp.rstrip().split(' ')[0]) for tmp in x];

#with open(path + '/exp/compute_gop/tmp_phones.txt','r') as f:
with open(path + '/' + sys.argv[3],'r') as f:
    x = f.readlines();
aligned_phones = [tmp.rstrip().split(' ')[0] for tmp in x];

with open(path + '/exp/compute_gop/posterior.txt','r') as f:
    x = f.readlines();
posterior = [tmp.rstrip().split(' ') for tmp in x];
num_of_senones = len(posterior[0]);
total_num_frames = len(posterior);                    
                      
with open(path + '/exp/compute_gop/lookup_table.txt','r') as f:
    x = f.readlines();
lookup_tab = [tmp.rstrip().split(' ') for tmp in x];

series = pd.Series(num_segments);
cum_number_of_segments_tmp = series.cumsum();
cum_number_of_segments=cum_number_of_segments_tmp.tolist();
cum_number_of_segments.insert(0,0);

phone_score = [];
# Code for Proposed GoP formulation :                             
for x in range(len(num_segments)):
    
    req_t_id=transition_id[cum_number_of_segments[x]:(cum_number_of_segments[x+1])];
    req_t_id.sort();
    score=0.0;
    
    for y in range(len(req_t_id)-1):
        
        tmp_prob = float(lookup_tab[req_t_id[y]-1][2]);                                
        tmp_pdf = int(lookup_tab[req_t_id[y]-1][1]);
        tmp_post = float(posterior[cum_number_of_segments[x]+y][tmp_pdf]);
        score = score + math.log(tmp_prob) + math.log(tmp_post);
    
    tmp_pdf = int(lookup_tab[req_t_id[-1]-1][1]);
    tmp_post = float(posterior[cum_number_of_segments[x+1]-1][tmp_pdf]);
    score = (score + math.log(tmp_post) + float(number_of_segments[x]-1)*math.log(num_of_senones)) / float(number_of_segments[x]);
    phone_score.append(score);

#Displaying the scores :
print('Forced aligned phonemes : ');                      
print(aligned_phones);
print('GOP formulated score of each phoneme : ');
print(phone_score);   
                      
# The phoneme_list.txt file contains phonemes in the 1st column and GoP formulated scores in the 2nd column

f = open(path + '/' + sys.argv[4], 'w')
for i in range(len(phone_score)):
    	f.write("%s   %f\n" % (aligned_phones[i], phone_score[i]))
f.close()
```

Finally, create a .sh file called *compute_gop.sh* in the local directory and call the same to obtain the corresponding GOP scores.

```
#!/bin/bash

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

mkdir -p exp/compute_gop/gop
for i in 65
do
python3 ./local/prop_gop_eqn.py exp/compute_gop/segments/tmp_segments_$i.txt exp/compute_gop/ids/tmp_t_ids_$i.txt \
	exp/compute_gop/phones/tmp_phones_$((i+1)).txt exp/compute_gop/gop/gop_outfile_$i.txt
done
#exp/compute_gop/posterior_infile.ark exp/compute_gop/align_infile.txt exp/compute_gop/gop_output.txt

echo "DONE"
```

The code snippet written above takes a random audio of a speaker and computes the GOP phone-level for the sentence uttered in the audio file taken into consideration. 

A sample *gop_outfile.txt* would look something like this.
```
r	5.000228
i	4.428599
sx	5.332993
i	5.058
k	4.846142
k	5.242071
eu	5.305826
r	4.646087
oo	5.528024
sx	5.235368
a	5.055046
m	5.001478
a	5.019377
d	4.889972
i	5.111233
g	5.005164
a	4.567913
m	5.429707
```

Also, the scores obtained here is for a mild speaker for the sentence *risxikkeu roosxam adigam*.

The corresponding scores were obtained for 

a. Severe Speaker
```
r	3.103546
i	3.413216
sx	5.31522
i	4.840277
k	4.321028
k	3.191339
eu	4.932919
r	3.383669
oo	3.773568
sx	5.07603
a	4.57093
m	5.054973
a	3.866683
d	3.211266
i	3.524243
g	3.331577
a	3.252997
m	4.898417
```

b. Moderate Speaker
```
r	3.990545
i	4.103905
sx	5.38123
i	5.163616
k	4.184953
k	4.782334
eu	5.479586
r	3.990545
oo	5.193343
sx	5.317609
a	4.971409
m	5.095013
a	5.069219
d	4.755552
i	4.757178
g	4.340856
a	4.373628
m	5.467689
```

c. Normal Speaker
```
r	5.467134
i	4.771052
sx	5.913051
i	5.404447
k	5.430395
k	5.604835
eu	5.858137
r	5.226735
oo	5.81448
sx	5.885062
a	5.25125
m	5.728299
a	5.150121
d	5.037944
i	5.228974
g	5.485481
a	4.740455
m	5.611898
```

For any insights into the algorithm proposed by Professor Sweeker Sudhakara and team, you may check their paper out or visit their Github page at [sweekarsud](https://github.com/sweekarsud/Goodness-of-Pronunciation/tree/master) where the authors have made their code accessible for public use.

Happy Kaldi-ing!
