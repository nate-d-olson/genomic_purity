#################################################################################################################
##
## Summary: Score matches for single orangism simulated data 
## Date: 4/25/2014
## Author: Nate Olson
## Affiliation: National Institute for Standards and Technology
## Dependencies: output from gather_sim.R (simulated_mix.csv)
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

single_org_match <- function (inputfile) {
  
  ## pathoscope matches
  #--------------------
  path_matches <- read.csv(str_c(path_results_directory,inputfile, sep= "/"), stringsAsFactors = F)
  
  # compare taxonomy of match and source
  orgs <- unique(path_matches$input_filename)
  for(i in orgs){
    taxid <- GetTaxid(i, 'uid')
    path_matches$org_tid[path_matches$input_filename == i] <- taxid 
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
  
  
  #The following were removed from the NCBI database - all three were submitted by the FDA
  path_matches$match_tid[path_matches$Genome == "gi|538360566|ref|NC_022241.1|"] <- 1320309
  path_matches$match_tid[path_matches$Genome == "gi|538397725|ref|NC_022248.1|"] <- 1320309
  path_matches$match_tid[path_matches$Genome == "gi|525826475|ref|NC_021812.1|"] <- 1271864
  
  #finding match level
  ## need to find a way to make unique set not just strings
  genome_hits <- unique(str_c(path_matches$match_tid, path_matches$org_tid, sep = "_"))
  for(i in genome_hits){
    hits <- as.integer(str_split(string=i,pattern="_")[[1]])
    if(hits[1] == hits[2]){
      path_matches$match[path_matches$match_tid == hits[1] &
                                path_matches$org_tid == hits[2]] <- "exact"    
    } else {
      match_level <- GetMatchLevel(id1=hits[1],id2=hits[2])
      path_matches$match[path_matches$match_tid == hits[1] &
                                path_matches$org_tid == hits[2]] <- match_level  
    }
  }
  rm(genome_hits, i, match_level,hits)
  return(path_matches)
}

single_mix_matches <- single_org_match(inputfile="simulated_single.csv")
write.csv(single_mix_matches,str_c(path_results_directory,"sim_single_matches.csv", sep="/"), row.names = F)

BA_matches <- single_org_match(inputfile="simulated_BA.csv")
write.csv(BA_matches,str_c(path_results_directory,"sim_BA_matches.csv", sep="/"), row.names = F)

EC_matches <- single_org_match(inputfile="simulated_EC.csv")
write.csv(EC_matches,str_c(path_results_directory,"sim_EC_matches.csv", sep="/"), row.names = F)


