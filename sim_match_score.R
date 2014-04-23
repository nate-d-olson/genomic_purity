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
source("match_tid.R")
library(stringr)

####--------------
##
## required inputs
##
####--------------

## pathoscope matches
#--------------------
path_matches <- read.csv("simulated_mix.csv", stringsAsFactors = F)
path_matches$X <- NULL
# 'data.frame':  8190 obs. of  20 variables:
# $ Genome                       : chr  "gi|384546269|ref|NC_017337.1|" "gi|387779217|ref|NC_017349.1|" "gi|82749777|ref|NC_007622.1|" "gi|255961454|ref|NC_006570.2|" ...
# $ Final.Guess                  : num  0.997463 0.000821 0.000435 0.000361 0.000286 ...
# $ Final.Best.Hit               : num  0.997463 0.000821 0.000435 0.000361 0.000286 ...
# $ Final.Best.Hit.Read.Numbers  : int  80206 66 35 29 23 12 11 7 5 2 ...
# $ Final.High.Confidence.Hits   : num  0.997463 0.000821 0.000435 0.000361 0.000286 ...
# $ Final.Low.Confidence.Hits    : int  0 0 0 0 0 0 0 0 0 0 ...
# $ Initial.Guess                : num  0.997463 0.000821 0.000435 0.000361 0.000286 ...
# $ Initial.Best.Hit             : num  0.997463 0.000821 0.000435 0.000361 0.000286 ...
# $ Initial.Best.Hit.Read.Numbers: int  80206 66 35 29 23 12 11 7 5 2 ...
# $ Initial.High.Confidence.Hits : num  0.997463 0.000821 0.000435 0.000361 0.000286 ...
# $ Initial.Low.Confidence.Hits  : int  0 0 0 0 0 0 0 0 0 0 ...
# $ input_filename               : chr  "159689-250-57589-250" "159689-250-57589-250" "159689-250-57589-250" "159689-250-57589-250" ...
# $ Aligned_Reads                : int  80410 80410 80410 80410 80410 80410 80410 80410 80410 80410 ...
# $ Mapped_Genome                : int  22 22 22 22 22 22 22 22 22 22 ...
# $ size                         : int  250 250 250 250 250 250 250 250 250 250 ...
# $ org1                         : int  159689 159689 159689 159689 159689 159689 159689 159689 159689 159689 ...
# $ org2                         : int  57589 57589 57589 57589 57589 57589 57589 57589 57589 57589 ...
# $ prop1                        : num  1 1 1 1 1 1 1 1 1 1 ...
# $ prop2                        : num  1 1 1 1 1 1 1 1 1 1 ...

## org1 and org2 indicate the source organisms, numbers are source directory uid
path_matches <- subset(path_matches, select = c(Genome,org1,org2,prop1,prop2))


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

#The following were removed from the NCBI database - all three were submitted by the FDA
path_matches$match_tid[path_matches$Genome == "gi|538360566|ref|NC_022241.1|"] <- 1320309
path_matches$match_tid[path_matches$Genome == "gi|538397725|ref|NC_022248.1|"] <- 1320309
path_matches$match_tid[path_matches$Genome == "gi|525826475|ref|NC_021812.1|"] <- 1271864

#finding match level
genome_hits <- unique(str_c(path_matches$match_tid, path_matches$org1_tid, sep = "_"),str_c(path_matches$match_tid, path_matches$org2_tid, sep = "-"))
for(i in genome_hits){
  hits <- as.integer(str_split(string=i,pattern="_")[[1]])
  match_level <- GetMatchLevel(id1=hits[1],id2=hits[2])
  path_matches$org1_match[path_matches$match_tid == hits[1] &
                            path_matches$org1_tid == hits[2]] <- match_level 
  path_matches$org2_match[path_matches$match_tid == hits[1] &
                            path_matches$org2_tid == hits[2]] <- match_level 
}
rm(genome_hits, i, match_level,hits)
# writing match data to file
write.csv(path_matches,"sim_path_matches.csv", row.names = F)
