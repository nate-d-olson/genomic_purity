## Pathoscope Ruffus Pipeline functions
## ruffus pipeline command require Input at the first parameter and Output at the Second
## functions from pepr pathoscope_commands.py 

from ruffus import *
import sys
import time
import subprocess
from re import sub
# starting_files = ["TSRR1979039_1.fastq", "TSRR1979039_2.fastq"] #'SRR2002412.fastq'] #

## working with file pairs
## template from http://www.ruffus.org.uk/tutorials/new_tutorial/inputs_code.html example 4
# @transform( source_files,
#             formatter(".cpp$"),
#                         # corresponding header for each source file
#             add_inputs("{basename[0]}.h",
#                        # add header to the input of every job
#                        "universal.h"),
#             "{basename[0]}.o")


## need to use new object oriented syntax
## - minimizes need for modifying existing pipeline functions


# @transform(starting_files, suffix(".fastq"),"_qc.fq.gz", '../test_files','4')
def pathoqc_command(input, output, out_dir, proc):
    # ## log file stores standard out
    # log_file = open(log_dir + "/pathoqc"+ time.strftime("-%Y-%m-%d-%H-%M-%S.log"),'w')
    # stderr_file = open(log_dir + "/pathoqc"+ time.strftime("-%Y-%m-%d-%H-%M-%S.stder"),'w')
    
    qc_cmd = ["python","/PathoScope/pathoqc_v0.1.2/pathoqc.py"]
    
    # if fastq2 != None:
    #     pathoqc_command = pathoqc_command #+ ['-1',fastq1, '-2',fastq2,'-s',plat,'-p',str(thread_num),'-o',out_dir]
    # else:
    qc_cmd = qc_cmd + ['-1',input, '-o', out_dir,'-p', proc]
    # subprocess.call(pathoqc_command) #, stdout=log_file, stderr=stderr_file) 
    print qc_cmd       
    subprocess.call(qc_cmd)


# @transform(pathoqc_command, suffix("_qc.fq.gz"), "-appendAlign.sam", 
# 			# using MG002 pacbio as ref - smaller, quicker!
# 			'CFSAN030013.fasta',
# 			'../test_files',
# 			# '/current_projects/micro_rm/micro_rm_dev/utilities/patho_utils/micro_rm_patho_db_ti_0.fa', 
# 			# '/current_projects/micro_rm/micro_rm_dev/utilities/patho_utils/',
# 			'../test_files',"T")
def pathomap_command(input, output, ref_path, index_dir, exptag):
    ## log file stores standard out
    # log_file = open(log_dir + "/pathomap"+time.strftime("-%Y-%m-%d-%H-%M-%S.log"),'w')
    # stderr_file = open(log_dir + "/pathomap"+ time.strftime("-%Y-%m-%d-%H-%M-%S.stder"),'w')

    ## pathoscope command root
    pathomap_command = ["python", "/PathoScope/pathoscope/pathoscope.py",
    					'--verbose','MAP', '-targetRefFiles',ref_path,
                        '-indexDir',index_dir, '-outAlign', output, '-expTag', input]
    
    # if fastq2:
    #     pathomap_command = pathomap_command + ['-1',fastq1, '-2',fastq2]
    # else:
    pathomap_command = pathomap_command + ['-U',input]
    subprocess.call(pathomap_command)#, stdout=log_file, stderr=stderr_file)

# @transform(pathomap_command, suffix("-appendAlign.sam"), "-sam-report.tsv", '../test_files','T')
def pathoid_command(input, output, out_dir, exptag):
    # command for running pathoid

    # ## log file stores standard out
    # log_file = open(log_dir + "/pathoid"+time.strftime("-%Y-%m-%d-%H-%M-%S.log"),'w')
    # stderr_file = open(log_dir + "/pathoid"+ time.strftime("-%Y-%m-%d-%H-%M-%S.stder"),'w')
    
    ## pathoscope command root
    pathoid_command = ["python","/PathoScope/pathoscope/pathoscope.py",'--verbose','ID', 
    					'-alignFile',input,'-fileType',
                       'sam','--outMatrix','-expTag', input]
    subprocess.call(pathoid_command)#, stdout=log_file,stderr=stderr_file)

# pipeline_run()