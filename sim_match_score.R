#################################################################################################################
##
## Summary: Score matches for simulated data 
## Date: 1/11/2014
## Author: Nate Olson
## Affiliation: National Institute for Standards and Technology
## Dependencies: output from gather_sim.R (simulated_mix.csv)
##  GenBank run info files for any datasets analyzed
##  searchered SRA database using GenomeTakr and Bacillus
## Output files: real_data_2.csv
## 
#################################################################################################################

####------------------------------
# OBJECTIVE
# score matches on taxonomic level
####------------------------------

####-----------------
##
## required functions
##
####-----------------
source("file_locations.R")
source("match_tid.R")
library(stringr)

####--------------
##
## required inputs
##
####--------------

## pathoscope matches
#--------------------
path_matches <- read.csv(str_c(path_results_directory,"simulated_contam.csv", sep= "/"), stringsAsFactors = F)

# compare taxonomy of match and source
#get org1 and org2 taxid
orgs <- unique(path_matches$org1)
for(i in orgs){
  taxid <- GetTaxid(i, 'uid')
  path_matches$org1_tid[path_matches$org1 == i] <- taxid 
  path_matches$org2_tid[path_matches$org2 == i] <- taxid 
}
rm(orgs)
#get match taxid
matches <- unique(path_matches$Genome)
for(i in matches){
  gi <- str_extract(string=i,pattern='[0-9]+')
  taxid <- GetTaxid(gi, 'gi')
  path_matches$match_tid[path_matches$Genome == i] <- taxid 
}
rm(matches, gi, taxid)


#The following were removed from the NCBI database
##three submitted by the FDA
path_matches$match_tid[path_matches$Genome == "gi|538360566|ref|NC_022241.1|"] <- 1320309
path_matches$match_tid[path_matches$Genome == "gi|538397725|ref|NC_022248.1|"] <- 1320309
path_matches$match_tid[path_matches$Genome == "gi|525826475|ref|NC_021812.1|"] <- 1271864

## submitted by others
path_matches$match_tid[path_matches$Genome == "gi|541862390|ref|NC_022268.1|"] <- 104623
path_matches$match_tid[path_matches$Genome == "gi|264676136|ref|NC_013446.1|"] <- 688245


#finding match level
## need to find a way to make unique set not just strings
genome_hits <- unique(c(str_c(path_matches$match_tid, path_matches$org1_tid, sep = "_"),str_c(path_matches$match_tid, path_matches$org2_tid, sep = "_")))
for(i in genome_hits){
  hits <- as.integer(str_split(string=i,pattern="_")[[1]])
  if(hits[1] == hits[2]){
    path_matches$org1_match[path_matches$match_tid == hits[1] &
                              path_matches$org1_tid == hits[2]] <- "exact" 
    path_matches$org2_match[path_matches$match_tid == hits[1] &
                              path_matches$org2_tid == hits[2]] <- "exact"     
  } else {
    match_level <- GetMatchLevel(id1=hits[1],id2=hits[2])
    path_matches$org1_match[path_matches$match_tid == hits[1] &
                              path_matches$org1_tid == hits[2]] <- match_level 
    path_matches$org2_match[path_matches$match_tid == hits[1] &
                              path_matches$org2_tid == hits[2]] <- match_level  
  }
}
rm(genome_hits, i, match_level,hits)

## match reporting
# keeping lowest
path_matches$match <- "no match"
for(i in rev(c("phylum","class","order","family","genus","species","exact"))){
  path_matches$match[path_matches$org2_match == i] <- str_c(i, "org2", sep = " ") 
  path_matches$match[path_matches$org1_match == i] <- str_c(i, "org1", sep = " ") 
}

# writing match data to file
write.csv(path_matches,str_c(path_results_directory,"sim_contam_matches.csv", sep="/"), row.names = F)
