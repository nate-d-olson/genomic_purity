#################################################################################################################
##
## Summary: Get taxon information from list of organism names. List based on folder names from NCBI Genbank 
## genome database download. The information is based on the organism's uid
## Date: 1/10/2014
## Author: Nate Olson
## Affiliation: National Institute for Standards and Technology
## Dependencies: R packages taxize, reshape2, plyr
## Input: used command line "cat /media/second/DATAFILES/Bacteria/ * > taxa_names.txt" 
##  - this is the absolute path to where the NCBI database is stored on Nate Olson's computer where the 
##    project was developed
## Output files:csv file with taxa information for provided list of organism names.
## 
## Issue to address genome names with out matches, ideal is to find a more robust method
## getting taxonomic information/ taxa matching
##
#################################################################################################################

library(NCBI2R)
library(reshape2)
library(plyr)
library(stringr)

source("file_locations.R")
sessionInfo()

##### Input list of organism names used as reference in mapping
all_bac <- readLines("taxa_names.txt")

##### Cleaning up names generating list of bacteria names and data frame of names and uid
uid <- as.numeric(gsub(".*uid","", all_bac))
all_bac <- gsub("/media/second/DATAFILES/Bacteria/", "", all_bac)
all_bac <- gsub("_uid.*", "", all_bac)
all_bac <- gsub("_"," ", all_bac)
uid_df <- data.frame(uid, full_name = all_bac)
uid_df <- uid_df[complete.cases(uid_df),]


GetTaxInfo(taxids=uid_df$uid[1])$lineage

taxa_df <- data.frame()
for(i in 1:length(uid)/200){
  taxa_df <- rbind(taxa_df, GetTaxInfo(taxids=uid[1:200*i])$lineage)
}


##### Gets taxonomic classification from NCBI database using the taxize package
taxa_list<- list()
taxa_list <- classification(unique(uid), db = 'ncbi')


### reformat taxize output to dataframe and write to file as csv
taxa_df <- ldply(taxa_list, data.frame)
#limit the taxonomic ranks included to eliminat overlap where some levels have multiple values
taxa_df <- subset(taxa_df, select = c(.id, name, rank))
taxa_df <- taxa_df[taxa_df$rank %in% c("phylum","class","order","family","genus","species"),1:3]

#note that organisms where to taxonomic classification information is obtained are not included 
#in the resulting dataframe, this could be an issue downstream
taxa_df <- rename(taxa_df, replace = c(".id"= "full_name"))
taxa <- dcast(taxa_df, full_name~rank, value.var = "name")
taxa_uid <- join(x = taxa, y = uid_df, type = "right")
write.csv(taxa_uid, str_c(working_directory, "/ref_taxa.csv", sep = ""))
