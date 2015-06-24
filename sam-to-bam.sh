#!/usr/bin/sh
## compressing fastq files
#for sam in Escherichia*/*sam;
# for sam in Listeria*/*sam
for sam in Bacillus*/*sam
do
	samtools view -bS -@ 8 -o $sam.bam $sam
	rm $sam
done