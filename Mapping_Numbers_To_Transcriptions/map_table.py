import sys
import os

path = os.getcwd()

d_phone={}
d_word={}
start_time=[]
stop_time=[]
transcription_phone=[]
transcription_word=[]
for line in open(path + '/' + sys.argv[1],'r'):
    split = line.strip().split(' ', 1)
    d_phone[split[0]] = split[1]
#print(d_phone)
for line in open(path + '/' + sys.argv[2],'r'):
    split = line.strip().split(' ', 1)
    d_word[split[0]] = split[1]
#print(d_word)
f = open(path + '/' + sys.argv[3], "r")
for line in f.readlines():
    [start,stop,label] = line.split()
    start_time.append(start)
    stop_time.append(stop)
    transcription_phone.append(label)
    transcription_word.append(label)
f.close()
#print(start_time)
#print(stop_time)
#print(transcription)
char_repl={'_1':'','_2':'','_3':'','_4':'','_5':'','_6':'','_7':'','_8':'','_9':'','_10':'','_a':'','_b':'','_c':''}
for k,v in char_repl.items():
    transcription_word = [w.replace(k,v) for w in transcription_word]
    transcription_phone = [x.replace(k,v) for x in transcription_phone]
transcription_word = [w.replace("sil","SIL") for w in transcription_word]
transcription_word = [w.replace("x","SIL") for w in transcription_word]
transcription_phone = [x.replace("sil","SIL") for x in transcription_phone]
transcription_phone = [x.replace("x","SIL") for x in transcription_phone]
#print(transcription_phone)

for i in range(len(transcription_word)):
    if transcription_word[i] in d_word.keys():
        transcription_word = [w.replace(transcription_word[i],d_word[transcription_word[i]]) for w in transcription_word]

for j in range(len(transcription_phone)):
    if transcription_phone[j] in d_phone.keys():
        transcription_phone = [x.replace(transcription_phone[j],d_phone[transcription_phone[j]]) for x in transcription_phone]
    #else:
    #   transcription_word = [w.replace(transcription_word[i],"SIL") for w in transcription_word]
        
    #print(transcription_word[i])
    #transcription_word = [w.replace(transcription_word[i],d_word[transcription_word[i]]) for w in transcription_word]
#print(transcription_phone)

c1= [start_time,stop_time,transcription_word]
c2= [start_time,stop_time,transcription_phone]

with open(path + '/' + sys.argv[4],"w") as f:
    for x in zip(*c1):
        f.write("{0}\t{1}\t{2}\n".format(*x))
f.close()
with open(path + '/' + sys.argv[5],"w") as f:
    for x in zip(*c2):
        f.write("{0}\t{1}\t{2}\n".format(*x))
f.close()
