#################################################################################################################
##
## Summary: Get taxon information from list of organism names. List based on folder names from NCBI Genbank 
## genome database download.
## Date: 1/10/2014
## Author: Nate Olson
## Affiliation: National Institute for Standards and Technology
## Dependencies: R packages taxize, reshape2, plyr
## Input: used command line "cat /media/second/DATAFILES/Bacteria/ * > taxa_names.txt" 
##  - this is the absolute path to where the NCBI database is stored on Nate Olson's computer where the 
##    project was developed
## Output files:csv file with taxa information for provided list of organism names.
## 
#################################################################################################################

library(taxize)
library(reshape2)
library(plyr)

sessionInfo()

# Input list of organism names used as reference in mapping
all_bac <- readLines("~/Desktop/taxa_names.txt")

#cleaning up names
#uid <- gsub(".*uid","", all_bac) - may want to incorporate in output later as the uid are unique to each genome
all_bac <- gsub("/media/second/DATAFILES/Bacteria/", "", all_bac)
all_bac <- gsub("_uid.*", "", all_bac)
all_bac <- gsub("_"," ", all_bac)
taxa_list<- list()

#gets taxonomic classification from NCBI database using the taxize package
taxa_list <- classification(unique(all_bac), db = 'ncbi')


#reformat taxize output to dataframe and write to file as csv
taxa_df <- ldply(taxa_list, data.frame)
#limit the taxnomic ranks included to eliminat overlap where some levels have multiple values
taxa_df <- taxa_df[taxa_df$Rank %in% c("phylum","class","order","family","genus","species"),1:3]

#note that organisms where to taxnomic classification information is obtained are not included 
#in the resulting dataframe, this could be an issue downstream
taxa <- dcast(taxa_df, .id~Rank, value.var = "ScientificName")
write.csv(taxa, "~/Desktop/ref_taxa.csv")