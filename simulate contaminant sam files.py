''' simulate contaminant sam files '''
import os
import re
import sys
import subprocess
from itertools import permutations
from pathoscope_commands import pathoid_command
from joblib import Parallel, delayed
import multiprocessing
num_cores = multiprocessing.cpu_count()


def get_uid(filename):
    m = re.search('uid(.+?)/', filename)
    assert m, "UID not found for %s" % filename
    return m.group(1)


def mix_pathoid(mix_sam):
    mix_id = mix_sam.re.replace(".sam", "-sam-report.tsv")
    pathoid_command(mix_sam, mix_id)
    assert os.path.isfile(mix_id), "File %s not found" % mix_id


def make_mix(input1, input2, mixtures):
    ''' Create mix of input files for mixtures'''
    uid1 = get_uid(input1)
    uid2 = get_uid(input2)
    input_root = uid1 + "_" + uid2

    mix_sam_list = []
    for i in mixtures:
        output1 = "Sample" + input_root + str(i) + ".sam"
        output2 = "Contam" + input_root + str(i - 1) + ".sam"
        mix_out = input_root + "_" + str(i) + ".sam"
        mix_sam_list.append(mix_out)
        out1_file = open(output1, 'w')
        out2_file = open(output2, 'w')

        subprocess.call(["samtools", "view", "-s", str(i), input1],
                        stdout=out1_file)
        assert os.path.isfile(output1), "File %s not found" % output1

        subprocess.call(["samtools", "view", "-s", str(1 - i), input2],
                        stdout=out2_file)
        assert os.path.isfile(output2), "File %s not found" % output2

        subprocess.call(["samtools", "merge", "-u", mix_out, output1, output2])
        assert os.path.isfile(mix_out), "File %s not found" % mix_out

    for mix_sam in mix_sam_list:
        pathoid_command(mix_sam)


# read data
def readdat(filename):
    assert os.path.isfile(filename), "file %s not found" % filename
    with open(filename, 'r') as f:
        input_list = [line.rstrip() for line in f]
    return input_list


def main(input_list_file, mixtures):
    input_list = readdat(input_list_file)
    input_pairs = permutations(input_list, 2)

    Parallel(n_jobs=num_cores)(delayed(make_mix)(i, j, mixtures)
                               for i, j in input_pairs)


if __name__ == '__main__':
    filename = sys.argv[1]
    mixtures = [0.9, 0.99, 0.999, 0.9999, 0.99999,
                0.999999, 0.9999999, 0.99999999]
    main(filename, mixtures)
