## Script for processing info from single org simulation run
## parses the art read simulation log files to get the read name and random number used to generate the dataset
## parses the fasta refences sequences used to generate the reads to get the id for each sequence in the file
## get the number of reads simulated for each genome

import re
import sys
from os import walk
from Bio import SeqIO 
from Bio.SeqUtils import GC
import pandas as pd

def get_art_dat(art_log):
    f = open(art_log, 'r')
    log_file = f.readlines()
    
    org_name = ""; rand = ""
    
    for line in log_file:
        searchObj = re.search(r'.*the 1st reads: (.*)/.*\n', line)
        if searchObj != None:
            org_name = searchObj.group(1)  
        searchObj = re.search( r'The random seed for the run: (.*)\n', line)
        if searchObj != None:
            rand = searchObj.group(1)
            
    return [org_name, rand]

def get_ref_accessions(fasta):
    seq_id = []
    for seq_record in SeqIO.parse(fasta, "fasta"):
        seq_id.append([fasta, seq_record.id, GC(seq_record.seq), seq_record.description]) 
    return seq_id

def get_fq_dat(fastq):
    f = open(fastq, 'r')
    fq = f.readlines()
    return [fastq, len(fq)/4]

def process_results_dir(results_directory):
    art_dat = []
    seq_dat = []
    fq_dat = []
    for (dirpath, dirnames, filenames) in walk(results_directory):
        for f in filenames:
            if re.search(r'art_sim.+log', f):
                art_dat.append(get_art_dat(dirpath + "/" + f))
            if re.search(r'.*fasta', f):
                seq_dat += get_ref_accessions(dirpath + "/" + f)
                
            if re.search(r'.*[1|2].fq',f):
                fq_dat.append(get_fq_dat(dirpath + "/" + f))
    return {"art": art_dat, "seq": seq_dat, "fq" : fq_dat}

def write_output_files(sim_dat, out_dir):
	art_df = pd.DataFrame(sim_dat['art'])
	art_df.columns = ["org", "rand"]
	art_df.to_csv(out_dir + '/'+'singleOrgArt.csv', index = False)

	seq_df = pd.DataFrame(sim_dat["seq"])
	seq_df.columns = ['file', 'seq_id', 'GC', 'description']
	seq_df.to_csv(out_dir + '/' +'singleOrgRef.csv', index = False)

	fq_df = pd.DataFrame(sim_dat["fq"])
	fq_df.columns = ['file', 'read_count']
	fq_df.to_csv(out_dir + '/' + 'singleOrgFq.csv', index = False)

def main(sim_path, out_dir):
	sim_dat = process_results_dir(sim_path)
	write_output_files(sim_dat, out_dir)

main(sim_path = sys.argv[1], out_dir = sys.argv[2])

