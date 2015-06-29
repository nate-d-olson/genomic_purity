#!/usr/bin/sh
## compressing fastq files
#for sam in Escherichia*/*sam;
# for sam in Listeria*/*sam
#for sam in Bacillus*/*sam
for sam in Clostridium*/*sam
do
	samtools view -bS -@ 8 -o $sam.bam $sam
	rm $sam
done

## adding parallization
# maxjobs=$( ls -d /sys/devices/system/cpu/cpu[[:digit:]]* | wc -w )
# parallelize () {
#         while [ $# -gt 0 ] ; do
#                 jobcnt=(`jobs -p`)
#                 if [ ${#jobcnt[@]} -lt $maxjobs ] ; then
#                         compress_sam $1 &
#                         shift  
#                 fi
#         done
#         wait
# }


# compress_sam () {
# 	samtools view -bS -@ 8 -o $1.bam $1
# 	rm $1
# }

# parallelize Clostridium*/*sam