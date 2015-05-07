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
	1. pure isolate pipe: sim_fastq -> patho_qc_map -> patho_id
	2. contam pipe: sim_fastq -> patho_qc_map -> sim_contam -> patho_id
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

def make_sim_fastq_pipeline():
	"""
		generates simulated fastq datasets for a set of defined genomes
		input: genome fasta
		output: fastq datasets
		%%TBD%% if this will work for both Illumina and PGM and how parameters will be defined
	"""
	pass


def make_patho_qc_map_pipeline(pipeline_name = "qc_map"):
	qc_map_pipe = Pipeline(pipeline_name)

	## pathoqc_command
	## def pathoqc_command(input_file, output_file, out_dir, proc)
	qc_map_pipe.transform(task_func  = pathoqc_command,
	                      input      = None, #placehlder: will be replaced with set_input()
	                      filter     = suffix('.fastq'),
	                      output     = '_qc.fq.gz',
	                      output_dir = '../test_files',
	                      proc 		 = '8')

	## pathomap_command
	## def pathomap_command(input_file, output_file, ref_path, index_dir, out_dir, exptag)
	qc_map_pipe.transform(task_func  = pathoqc_command,
	                      input      = starting_files,
	                      filter     = suffix('.fastq'),
	                      output     = '_qc.fq.gz',
	                      output_dir = '../test_files',
	                      proc 		 = '8')

	##  Set the tail task so that users of sub pipeline can use it as a dependency
    ##     without knowing the details of task names 
    qc_map_pipe.set_tail_tasks([pathoqc_command])

    ## allow input without knowing task names
    if not DEBUG_do_not_define_head_task:
	    qc_map_pipe.set_head_tasks([qc_map_pipe[pathoqc_command]])

    return qc_map_pipe

def make_patho_id_pipeline(pipeline_name, starting_files):
	## single command subpipeline - a bit unecessary ....
	patho_pipe = Pipeline(pipeline_name)

	## pathoid_command
	## def pathoid_command(input_file, output_file, out_dir, exptag)
	id_pipe.transform(task_func  	= pathoid_command,
                      input_file 	= None,
                      filter     	=  suffix("-appendAlign.sam"),
                      output_file	= "-sam-report.tsv",
                      output_dir 	= '../test_files',
                      exptag 		= 'T')

	##  Set the tail task so that users of sub pipeline can use it as a dependency
    ##     without knowing the details of task names 
    id_pipe.set_tail_tasks([pathoid_command])

    ## allow input without knowing task names
    if not DEBUG_do_not_define_head_task:
	    id_pipe.set_head_tasks([id_pipe[pathoid_command]])

	return id_pipe


###############################################################################
##
## Defining full pipelines
##
###############################################################################



