### Read simulation functions for genomic contamination pipeline
import os
import subprocess
from random import randint

## Get reference genomes
## generating genome fasta files for the genomes of interest by suppling a 
#list of folders for the desired organisms
def get_genome_fasta(input, output):
	# input - name of bacterial genome directory 
	# output - directory name with fasta extension
	
	filenames = []
	for file in os.listdir(input):
		if file.endswith(".fna"):
			filenames.append(input + "/" + file)

	with open(output, 'w') as outfile:
		for fname in filenames:
			with open(fname) as infile:
				for line in infile:
					outfile.write(line)


### simulate illumina
def simulate_miseq(input, output):
	print input
	print output
	# input fasta file
	random_num = randint(1,100000)
	# may cause an error if a "." is in the file name before the extension
	out_root = os.path.splitext(input)[0] 
	art_command = ["art_illumina","-i",input,"-o",out_root,
				   "-ss","MS","-na","-rs",str(random_num),
				   "-p","-f","20","-l", "230","-m", "690","-s","10"]
	print "Print command for record - note random number!"
	print art_command
	subprocess.call(art_command)

#modifed to generate 250 bp paried end reads based on current 
#MiSeq read lengths 11/22/2013
 
# for fasta in *fasta;
# do
# ref=$(echo $fasta | sed 's/.fasta//')
# ~/src/ART_read_simulator/art_illumina -na -p -i $fasta -l 250 -f 20 -m 1000 -s 100 -o $fasta-250.fastq 
# done


### simulate PGM

########################################################################################
### simulate contamination
## process - merge paired bams, get list of read name in subset, 
########################################################################################
## from old study
## sam_pair_merge.sh
# #added sam_to_bam.sh code 12/4/2013 NDO
# for i in *sam;
# do
# 	bam=$(echo $i | sed 's/sam/bam/')
# 	samtools view -bhSu -o $bam $i
# done

# i=0
# bams=$(ls *bam)
# for bam1 in $bams;
# do
# 	i=$i+1	
# 	j=0
# 	for bam2 in $bams;
# 	do
# 		j=$j+1
# 		if [[ "$bam1" != "$bam2" ]];
# 		then
# 			if [[ "$j" > "$i" ]];
# 			then
# 				merge="$bam1-$bam2"
# 				merge=$(echo $merge | sed 's/-250-Ill-2.bam//g')
# 				echo $bam1 $bam2 $merge				
# 				samtools merge -un $merge.bam $bam1 $bam2
# 				samtools view -h -o $merge.sam $merge.bam
# 			fi
# 		fi
# 	done
# done

## insilico_contaminator.py
# Generating the simulated contaminated datasets from a set of fastq files.
# ====================================================================


# import sys, random, itertools, os,re
# import HTSeq

# # Code for this function from [seqanswers](http://seqanswers.com/forums/show thread.php?t=12070,"seqanswers"). 

# def sub_sampler(frac, in_fastq, out_name):
#     fraction = float( frac )
#     seqs = iter( HTSeq.FastqReader( in_fastq ) )
#     out_file = open( out_name, "a" )

#     for read in seqs:
#         if random.random() < fraction:
#             out_file.write(read.name + '\n')
#     out_file.close()

# files = sys.argv[1:]

# # Looping through the datasets and generating subset datasets for each pair and fraction and generating a single output file.
# # Truncated the initial list of fractions due to limited hard drive size.

# fractions = [(0.95,0.05), (0.975,0.025), (0.995,0.005), (0.9975,0.0025), \
#              (0.9995,0.0005),(0.999975, 0.000025),(0.999995,0.000005),(0.9999975, 0.0000025),(0.9999995,0.0000005)]

# for i in range(0,len(files)):
#    for j in range(0, len(files)):
#         if i is not j:
#             for k in fractions:
#                 print i, j, k
# 		#changed output files to .mix to avoid issues with other .txt files
#                 out_name = files[i].split(".")[0] + "-" + files[j].split(".")[0] + "-" + str(k[0]) + "-" + str(k[1]) + ".mix"
#                 sub_sampler(k[0], files[i], out_name)
#                 sub_sampler(k[1], files[j], out_name)

# #########################################################
# #
# # filter merged sam files based on read names
# #
# # 
# #Objective filter sam file based on read names
# import os, re, time, sys

# #load list of read list files and bam files
# mix_names = sys.argv[1:]

# #list of read files and mapping files
# read_files = filter(re.compile('mix').search, mix_names)
# map_names = filter(re.compile('sam').search, mix_names)

# #getting the sam file to match the read list file
# def get_sam(org1, org2, sam):
#     pattern = org1 + ".*" + org2 + ".*"
#     pattern2 = org2 + ".*" + org1 + ".*"
#     for i in sam:
# 	if re.match(pattern, i):
#             return i
#         elif re.match(pattern2, i):
# 	    return i

# #generating a list of tuples: (mixed read list,appropriate merged sam file)
# def get_read_sam_list(read_files, sam):
#     read_merge = []
#     for i in read_files:
#         name_split = i.split("-")
#         org1 = name_split[0]
#         org2 = name_split[1]
#         sam_match = get_sam(org1,org2,sam)
# 	read_merge.append((i, sam_match))
#     return read_merge

# read_merge = get_read_sam_list(read_files, map_names)

# print "Start loop " + time.strftime('%X %x %Z')
# for read_file, map_file in read_merge:
#     print read_file

#     #input files
#     sam = open(map_file,'r')
#     reads = open(read_file, 'r').readlines()
#     #output
#     mix_sam = open(re.sub('mix','sam',read_file), 'w')

#     mix_read_names = [j.replace('/1\n','') for j in reads]
#     mix_reads = dict((el,0) for el in mix_read_names)

#     sam_out = ""    
#     print "Start:" + time.strftime('%X %x %Z')
#     k = sam.readline()
#     while k:
#         if k.startswith("@"):
#             sam_out = sam_out + k
#         else:
#             read_name = k.split('\t')[0]
#             if read_name in mix_reads:
#                 sam_out = sam_out + k
# 	k = sam.readline()
#     mix_sam.write(sam_out)
#     print "End:" + time.strftime('%X %x %Z')
