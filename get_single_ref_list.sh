#!/usr/bin/sh
## script to generate reference genome list
ls -d Bacteria/Escherichia_coli* Bacteria/Shigella_* > expanded_genome_list.txt
ls -d Bacteria/Yersinia_* >> expanded_genome_list.txt                                                  
ls -d Bacteria/Francisella_* >> expanded_genome_list.txt          
ls -d Bacteria/Salmonella_* >> expanded_genome_list.txt            
ls -d Bacteria/Staphylococcus_aureus_* >> expanded_genome_list.txt
ls -d Bacteria/Pseudomonas_* >> expanded_genome_list.txt
ls -d Bacteria/Bacillus_* >> expanded_genome_list.txt
ls -d Bacteria/Listeria_* >> expanded_genome_list.txt
ls -d Bacteria/Clostridium_* >> expanded_genome_list.txt