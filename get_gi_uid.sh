#!/bin/bash -       
#title           :get_gi_uid.sh
#description     :Script for generating a organism name,uid, gi flat file
#author		 :Nate Olson
#date            :2014-04-21
#version         :0.1   
#usage		 :bash get_gi_uid.sh
#notes           :Need to make sure the DB_DIR points to the location for a local GenBank database
#==============================================================================


# variables
DB_DIR="/Users/nolson/Documents/ncbi_bac"
> /Users/nolson/Documents/mirror/purity_study/pathoscope_pure_id/gi_uid_db.csv
DB_OUT=/Users/nolson/Documents/mirror/purity_study/pathoscope_pure_id/gi_uid_db.csv

#functions
function parse_directory_name(){
	# take the folder name as input and return the organism name and uid number
	ORG_NAME_UID=$(echo $1 | sed 's|/Users/nolson/Documents/ncbi_bac/||')
	ORG_NAME=$(echo $ORG_NAME_UID | sed 's/_uid.*//')
	
	uid=$(echo $ORG_NAME_UID | sed "s/$ORG_NAME\_uid//")
	
	echo $uid
}

function parse_fasta_names(){
	#take fasta file and returns the gi
	
	#get first line in fasta
	FNA=$(grep '^>' $1)
	
	#get gi from fasta line
	gi=$(echo $FNA | sed 's/.*gi|//')
	gi=$(echo $gi | sed 's/|.*//')
	
	echo $gi
}


#loop through directories
for DIR in $DB_DIR/*;
do
	DIR_PARSE=$(parse_directory_name $DIR)
	for FASTA in $DIR/*fna;
		do
			FASTA_GI=$(parse_fasta_names $FASTA)
			echo $DIR_PARSE,$FASTA_GI >> $DB_OUT
		done
done
	