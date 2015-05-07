#!/usr/bin/env python
from __future__ import print_function
"""


        Ruffus pipeline for genomic contaminant study
        Author: Nathan Olson
        Organization: NIST
        Email: nolson@nist.gov
        Date: 5/7/2015
        Version: 0.0.0.9000

        Code based on Ruffus OO syntax worked example
        http://www.ruffus.org.uk/tutorials/new_syntax_worked_example.html

"""
import os
import sys
from ruffus import *
from pathoscope_commands import *

"""		
	## sub pipelines
	1. patho_qc_map - qc, map
	2. patho_id - id
	3. sim_fastq - simulate fastq from list of genomes/ fasta files
	4. sim_contam - generates contaminanted datasets
	5. real_fastq - downloads fastq files from genbank given accession list

	## Full pipelines
	1. simulated pure isolate pipe: sim_fastq -> patho_qc_map -> patho_id
	2. simulated contam pipe: sim_fastq -> patho_qc_map -> sim_contam -> patho_id
	3. real pipe: real_fastq -> patho_qc_map -> patho_id
"""

DEBUG_do_not_define_tail_task = False
DEBUG_do_not_define_head_task = False

#import unittest ## need to add tests ....

###############################################################################
##
## Subpipeline Definitions
##
###############################################################################

def make_sim_fastq_pipeline(pipeline_name = "sim_fastq"): ## %%TODO%%
	"""
		generates simulated fastq datasets for a set of defined genomes
		input: genome fasta
		output: fastq datasets
		%%TBD%% if this will work for both Illumina and PGM and how parameters will be defined
	"""

	pass

def make_real_fastq_pipeline(pipeline_name = "real_fastq"): ## %%TODO%%
	"""
		download fastq data from sra archive
		input: sra accession
		output: fastq datasets
		%%TBD%% how parameters will be defined
	"""
	pass

def make_sim_contam_pipeline(pipeline_name = "sim_contam"): ## %%TODO%%
	"""
		generates simulated contaminated datasets for a set of fastq files
		input: fastq list, single sample bams
		output: mixed bams
		%%TBD%% how parameters will be defined
	"""
	pass

def make_patho_qc_map_pipeline(pipeline_name = "qc_map"):
	"""
	processing fastq input file with pathoqc and pathomap modules
	input: fastq
	output: sam file with fastq aligned to ref
	%%TBD%% how parameters will be defined
	"""
	qc_map_pipe = Pipeline(pipeline_name)

	## pathoqc_command
	## def pathoqc_command(input_file, output_file, out_dir, proc)
	qc_map_pipe.transform(task_func  	= pathoqc_command,
	                      input      	= None, #placehlder: will be replaced with set_input()
	                      filter     	= suffix('.fastq'),
	                      output		= '_qc.fq.gz',
	                      # out_dir 		= 'test_files',
	                      # proc 		 	= '8'
	                      )

	## pathomap_command
	## def pathomap_command(input_file, output_file, ref_path, index_dir, out_dir, exptag)

	qc_map_pipe.transform(task_func    	= pathomap_command,
						  input        	= pathoqc_command,
						  filter	   	= suffix('._qc.fq.gz'),
						  output  		= '-appendAlign.sam',
						  # ref_path	   	=  'test_files/CFSAN030013.fasta',
						  # index_dir		=  'test_files',
						  # out_dir   	=  'test_files',
						  # exptag	   	= 'T'
						  )

	##  Set the tail task so that users of sub pipeline can use it as a dependency
    ##     without knowing the details of task names 
	qc_map_pipe.set_tail_tasks([pathomap_command])

    ## allow input without knowing task names
	if not DEBUG_do_not_define_head_task:
		qc_map_pipe.set_head_tasks([qc_map_pipe[pathoqc_command]])

	return qc_map_pipe

def make_patho_id_pipeline(pipeline_name = "id"):
	## single command subpipeline - a bit unecessary ....
	id_pipe = Pipeline(pipeline_name)

	## pathoid_command
	## def pathoid_command(input_file, output_file, out_dir, exptag)
	id_pipe.transform(task_func  	= pathoid_command,
                      input 		= None,
                      filter     	=  suffix("-appendAlign.sam"),
                      output		= "-sam-report.tsv",
                      # output_dir 	= '../test_files',
                      # exptag 		= 'T'
                      )

	##  Set the tail task so that users of sub pipeline can use it as a dependency
    ##     without knowing the details of task names 
	# id_pipe.set_tail_tasks([pathoid_command])

    ## allow input without knowing task names
	if not DEBUG_do_not_define_head_task:
		id_pipe.set_head_tasks([id_pipe[pathoid_command]])

	return id_pipe

def make_pathoscope_pipe(pipeline_name):
	"""
		basic pathoscope pipeline
		input: fastq
		output: pathoscope id report
		%%TBD%% how parameters will be defined
	"""
	patho_pipe = Pipeline(pipeline_name)

	patho_pipe.transform(task_func  	= pathoqc_command,
	                      input      	= None, 
	                      filter     	= suffix('.fastq'),
	                      output		= '_qc.fq.gz',
	                      extras		= ['test_files','8'])

	patho_pipe.transform(task_func    	= pathomap_command,
						  input        	= output_from("pathoqc_command"),
						  filter	   	= suffix('_qc.fq.gz'),
						  output  		= '-appendAlign.sam',
						  extras = ['test_files/CFSAN030013.fasta','test_files', 'T'])

	patho_pipe.transform(task_func  	= pathoid_command,
		                 input 		= 	output_from("pathomap_command"),
		                 filter     	=  suffix("-appendAlign.sam"),
		                 output		= "-sam-report.tsv",
		                 extras = ['test_files', 'T'])

	## for defining inputs using set_input()
	patho_pipe.set_head_tasks([patho_pipe[pathoqc_command]])

	return patho_pipe

###############################################################################
##
## Defining full pipelines
##
###############################################################################

# sim_fastq_pipeline 		= make_sim_fastq_pipeline()
# real_fastq_pipeline 	= make_real_fastq_pipeline()
# sim_contam_pipeline 	= make_sim_contam_pipeline()
# patho_qc_map_pipeline 	= make_patho_qc_map_pipeline()
# patho_id_pipeline 		= make_patho_id_pipeline()

# ## Definition of pathoscope pipeline taking fastq as input
# patho = make_patho_id_pipeline(pipeline_name = "patho")
# patho.set_input(input = [patho_qc_map_pipeline])

# ## Definition of simulated single isolate samples pipeline
# sim_pure = make_patho_id_pipeline(pipeline_name = "sim_pure")
# sim_pure.set_input(input = [sim_fastq_pipeline, patho_qc_map_pipeline])
# ### Potential Issue !!!!!! Not sure about input and output definitions

# ## Definition of real data sample pipeline
# real_pure = make_patho_id_pipeline(pipeline_name = "real_pure")
# real_pure.set_input(input = [real_fastq_pipeline, patho_qc_map_pipeline])

# ## Definition of simulated contam pipeline
# sim_contam = make_patho_id_pipeline(pipeline_name = "sim_contam")
# sim_contam.set_input(input = [sim_fastq_pipeline, patho_qc_map_pipeline, sim_contam_pipeline])

## Pathoscope test pipe
starting_files = ["test_files/TSRR1979039_1.fastq", "test_files/TSRR1979039_2.fastq"]
test_pipe = make_pathoscope_pipe(pipeline_name = "test_pipe")
test_pipe.set_input(input = starting_files)

###############################################################################
##
## Commandline iterface
##
###############################################################################

import ruffus.cmdline as cmdline
parser = cmdline.get_argparse(description='Pipelines for genomic contaminant study',
                              version = "genomic_contamination_study_pipe.py v. 0.0.0.9000")

parser.add_argument('--pipeline', "-p", 
					type=str, 
					choices = ['sim_pure', 'sim_contam','real_pure','test_pipe'],
                    help="Defining which pipeline to run")

parser.add_argument('--config_file', "-cf", 
					type=str,
					help="yaml file with pipeline parameters")

# parser.add_argument('--cleanup', "-C",
#                     action="store_true",
#                     help="Cleanup before and after.")

options = parser.parse_args()



#  standard python logger which can be synchronised across concurrent Ruffus tasks
# define logging output with --log_file  log_file_name
logger, logger_mutex = cmdline.setup_logging (__name__, options.log_file, options.verbose)


# if we are printing only
if  not options.just_print and \
    not options.flowchart and \
    not options.touch_files_only:
    
    # %%TODO%% - need method for parsing inputs inorder to define and run pipeline

    cmdline.run (options)
    sys.exit()

#
#   Cleanup beforehand
## if using cleanup add import shutil
# if options.cleanup:
#     try:
#         shutil.rmtree(tempdir)
#     except:
#         pass

#
#   Run
#
# cmdline.run (options)

#
#   Cleanup Afterwards
#
# if options.cleanup:
#     try:
#         shutil.rmtree(tempdir)
#     except:
#         pass