"""
Authors : Sweekar Sudhakara, Manoj Kumar Ramanathi, Chiranjeevi Yarra, Prasanta Kumar Ghosh
Paper Title : An improved goodness of pronunciation (GoP) measure for pronunciation evaluation with DNN-HMM system considering HMM transition probabilities
"""
import sys
import math
import os
import subprocess
import pandas as pd
import numpy as np

path = os.getcwd(); 
  
# Modifying posterior.ark to posterior.txt
#var1 = [path + '/exp/compute_gop/' + sys.argv[1]];
#subprocess.call(['bash', './local/modify_post.sh', str(var1[0])]);
                    
# Creating segment information list, aligned phones list & transition_id's list 
#var2 = [path + '/exp/compute_gop/' + sys.argv[2]];
#subprocess.call(['bash', './local/extract_from_alignments.sh', str(var2[0])]);
               
#with open(path + '/exp/compute_gop/tmp_segments.txt','r') as f:
with open(path + '/' + sys.argv[1],'r') as f:
    x = f.readlines();
num_segments = [int(tmp.split(' ')[0]) for tmp in x];
#number_of_segments=[]
#for segment in num_segments:
#	if segment not in number_of_segments:
#		number_of_segments.append(segment) 
                      
#with open(path + '/exp/compute_gop/tmp_t_ids.txt','r') as f:
with open(path + '/' + sys.argv[2],'r') as f:
    x = f.readlines();
transition_id = [int(tmp.rstrip().split(' ')[0]) for tmp in x];
#transition_id=[]
#for trans_id in t_id:
#	if trans_id not in transition_id:
#		transition_id.append(trans_id)

#with open(path + '/exp/compute_gop/tmp_phones.txt','r') as f:
with open(path + '/' + sys.argv[3],'r') as f:
    x = f.readlines();
aligned_phones = [tmp.rstrip().split(' ')[0] for tmp in x];
#print(aligned_phones)

with open(path + '/exp/compute_gop/posterior.txt','r') as f:
    x = f.readlines();
posterior = [tmp.rstrip().split(' ') for tmp in x];
num_of_senones = len(posterior[0]);
#print(num_of_senones)
total_num_frames = len(posterior);    
#print(total_num_frames)                
                      
with open(path + '/exp/compute_gop/lookup_table.txt','r') as f:
    x = f.readlines();
lookup_tab = [tmp.rstrip().split(' ') for tmp in x];
#print(lookup_tab)

series = pd.Series(num_segments);
#print(series)
cum_number_of_segments_tmp = series.cumsum();
#print(cum_number_of_segments_tmp)
cum_number_of_segments=cum_number_of_segments_tmp.tolist();
#print(cum_number_of_segments)
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
        try:
        	tmp_post = float(posterior[cum_number_of_segments[x]+y][tmp_pdf]);
        	score = score + math.log(tmp_prob) + math.log(tmp_post);
        	#print(score)
        except ValueError as ve:
        	tmp_post = 1.0
        	score = score + math.log(tmp_prob) + math.log(tmp_post);
        	#print(score)
        #tmp_post = float(posterior[cum_number_of_segments[x]+y][tmp_pdf]);
        except IndexError as ie:
        	break      
    tmp_pdf = int(lookup_tab[req_t_id[-1]-1][1]);
    try:
    	tmp_post = float(posterior[cum_number_of_segments[x+1]-1][tmp_pdf]);
    	score = (score + math.log(tmp_post) + float(num_segments[x]-1)*math.log(num_of_senones)) / float(num_segments[x]);
    	phone_score.append(score);
    	#print(phone_score)
    except ValueError as ve:
    	tmp_post = 1.0
    	score = (score + math.log(tmp_post) + float(num_segments[x]-1)*math.log(num_of_senones)) / float(num_segments[x]);
    	phone_score.append(score);
    	#print(phone_score)
    except IndexError as ie:
       	break 
       	
        #try:
        #	tmp_post = float(posterior[cum_number_of_segments[x]+y][tmp_pdf]);
        #except ValueError as e:
        #	tmp_post = 0.0
        #score = score + math.log(tmp_prob) + math.log(tmp_post);
    
    #tmp_pdf = int(lookup_tab[req_t_id[-1]-1][1]);
    #tmp_post = float(posterior[cum_number_of_segments[x+1]-1][tmp_pdf]);
    #score = (score + math.log(tmp_post) + float(number_of_segments[x]-1)*math.log(num_of_senones)) / float(number_of_segments[x]);
    #phone_score.append(score);

# Displaying the scores :
#print('Forced aligned phonemes : ');                      
#print(aligned_phones);
#print('GOP formulated score of each phoneme : ');
#print(phone_score);   
                      
# The phoneme_list.txt file contains phoneme's in the 1st column and GoP formulated scores in the 2nd column     
#f = open('exp/compute_gop/gop_outfile.txt', 'w')
f = open(path + '/' + sys.argv[4], 'w')
for i in range(len(phone_score)):
    try:
    	f.write("%s   %f\n" % (aligned_phones[i], phone_score[i]))
    except IndexError as ie:
    	break
f.write("\n")
f.write("Mean GOP Score %s \n" % (np.mean(phone_score))) 
f.close()
