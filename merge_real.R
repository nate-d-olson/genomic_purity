#################################################################################################################
##
## Summary: Generate combined data file from pathoscope analysis of real data
## Date: 1/11/2014
## Author: Nate Olson
## Affiliation: National Institute for Standards and Technology
## Dependencies: output from gather_real.R and SraRunInfo.csv file, R packages plyr and gdata
##  GenBank run info files for any datasets analyzed
##  searchered SRA database using GenomeTakr and Bacillus
## Output files: real_data_meta.csv
## 
#################################################################################################################
library(plyr)
library(gdata)
sessionInfo()


#Loading parsed combinded pathoscope output
real_data <- read.csv("real_data.csv")

#subset of real data for developing code
#real_data <- real_data[1:100,]
real_data <- plyr::rename(real_data, replace= c("input_filename" = "Run"))
real_data <- gdata::remove.vars(data = real_data, names = c("X"))

#Loading metadata
genome_trakr_meta <- read.csv("SraRunInfo-GenomeTrakr.csv")
bacillus_meta <- read.csv("SraRunInfo-Bacillus.csv")
meta <- rbind(genome_trakr_meta, bacillus_meta)

#cleaning up, removing columns unnecessaary columns
meta<- meta[,colSums(is.na(meta ))<nrow(meta)]
meta <- gdata::remove.vars(data = meta, names = c("ReleaseDate",
                                                   "spots",
                                                   "bases",
                                                   "spots_with_mates",
                                                   "size_MB", 
                                                   "AssemblyName", 
                                                   "download_path", 
                                                   "LibraryName", 
                                                   "Study_Pubmed_id", 
                                                   "Tumor", 
                                                   "Submission",
                                                   "Consent"))

#merging dataframes
real_data_meta <- merge(real_data, meta,
                        union = "Run",
                        all.x = TRUE)

write.csv(real_data_meta, "real_data_meta.csv")
rm(list = ls())
