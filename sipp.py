#!/usr/bin/env python
import yaml
"""
        Simulated isolate purity pipeline
        Author: Nathan Olson
        Organization: NIST
        Email: nolson@nist.gov
        Date: 5/11/2015
        Version: 0.0.0.9000

        Code based on Ruffus OO syntax worked example
        http://www.ruffus.org.uk/tutorials/new_syntax_worked_example.html
"""
import os
import sys
from ruffus import *
from pathoscope_commands import *
from ngs_simulate_commands import *

#import unittest ## need to add tests ....

###############################################################################
##
## Functions for generating skeleton pipe
##
###############################################################################

import shutil


def touch (outfile):
    with open(outfile, "w"):
        pass

# def get_genome_fasta(input,output,extras):
# 	touch(output)

# def simulate_miseq(input,output,extras):
# 	for i in output:
# 		touch(i)

# def pathoqc_command(input,output, extras):
# 	for i in output:
# 		touch(i)

# def pathomap_command(input, output,extras):
# 	touch(output)

# def pathoid_command(input,output,extras):
# 	touch(output)


tempdir = "tempdir/"
def task_originate(o):
    """
    Makes new files
    """
    touch("start_" + o)

###############################################################################
##
## Skeleton pipe
##
###############################################################################
def make_sipp(org_list, config, pipeline_name = 'sipp'):
	sip_pipe = Pipeline(pipeline_name)

	sip_pipe.originate(task_originate, org_list) 
	

	sip_pipe.transform(get_genome_fasta,org_list,formatter("(?P<org>\w+)_uid(?P<uid>\w+)"),
						"{org[0]}_uid{uid[0]}/{uid[0]}_.fasta", config['genome_dir'])\
        				.follows(mkdir(org_list), mkdir([i + "/logs/" for i in org_list]), 
        							mkdir([i + "/tmp/" for i in org_list]))

	sip_pipe.transform(	simulate_miseq, output_from("get_genome_fasta"),
						suffix(".fasta"),["1.fq","2.fq"])#, extras = ['a'])

	# sip_pipe.transform(pathoqc_command,output_from("simulate_miseq"),
	# 					regex(r"_[12].fq"), ["_1_qc.fq.gz", "_2_qc.fq.gz"],config['pathoqc'])

	sip_pipe.transform(pathoqc_command,output_from("simulate_miseq"),
						formatter("(?P<rooot>)_1.fq", "(?P<rooot>)_2.fq"), 
                        # ["test1","test2"],
                        ["{root[0]}_1_qc.fq.gz","{root[1]}_2_qc.fq.gz"],
                        config['pathoqc'])

# 	sip_pipe.transform(	pathomap_command,output_from("pathoqc_command"),
# 					formatter(".+/(?P<uid>\w+)_[12]_qc_fq.gz"), "{path[0]}/pathomap-"+ config['pathomap']['ref_root']+ ".sam", config['pathomap']) #may need to change output suffix to -appendAlign.sam, for larger ref files
# #regex(r"_[12]_qc.fq.gz")
# 	sip_pipe.transform(pathoid_command,output_from("pathomap_command"),
# 						suffix(".sam"),"-sam-report.tsv")#may need to change input suffix to -appendAlign.sam, for larger ref files

	sip_pipe.set_head_tasks([sip_pipe[task_originate]])

	return sip_pipe
# test_org_list = ["/current_projects/genomic_purity/test_files/Acaryochloris_marina_MBIC11017_uid12997"]
# pipeline1a = make_sipp(org_list = test_org_list)

###############################################################################
##
## Commandline iterface
##
###############################################################################

import ruffus.cmdline as cmdline
parser = cmdline.get_argparse(description='Pipelines for genomic contaminant study',
                              version = "genomic_contamination_study_pipe.py v. 0.0.0.9000")

# parser.add_argument('--pipeline', "-p", 
# 					type=str, 
# 					choices = ['sim_pure', 'sim_contam','real_pure','test_pipe'],
#                     help="Defining which pipeline to run")

parser.add_argument('--config_file', "-cf", 
					type=str,
					#metavar="config_file",
					help="yaml file with pipeline parameters")

options = parser.parse_args()



## standard python logger which can be synchronised across concurrent Ruffus tasks
## define logging output with --log_file  log_file_name
logger, logger_mutex = cmdline.setup_logging (__name__, options.log_file, options.verbose)


# if we are printing only
if  not options.just_print and \
    not options.flowchart and \
    not options.touch_files_only:

    config_file= file(options.config_file, 'r')
    config = yaml.load(config_file)

    print config
    pipeline1a = make_sipp(org_list = config['org_list'], config = config)
    cmdline.run (options, logger = logger)
    sys.exit()