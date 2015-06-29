#!/usr/bin/sh
## compressing fastq files
#for f in */*fq */*fasta;
for f in Clostridium*/*fq Clostridium*/*fasta; #Clostridium specific
do
# adding & to loop to run the command in the background - cheap parallelization
	gzip $f &
done