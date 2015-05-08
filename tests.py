## Tests 
import filecmp

### ngs_simulate_commands.py
from ngs_simulate_commands import *

#### get_genome_fasta
test_dir = "test_files/Acaryochloris_marina_MBIC11017_uid12997"
get_genome_fasta(test_dir, "test.fasta")
print "Compare output to test_files:"
print filecmp.cmp("test.fasta", "test_files/test_uid12997.fasta")
## note that the order of the seqs would cause an error in the diff

### simulate_miseq
test_fasta = "test_files/test_uid12997.fasta"
simulate_miseq(test_fasta, "")