## Header ###############################################################################
##
## Summary: Script for generating datasets for publication figures and tables
## Date: 5/7/2014
## Author: Nate Olson
## Affiliation: National Institute for Standards and Technology
## Dependencies: R packages ggplot2, stringr,reshape2, plyr, xtable
##               R scripts - purity_functions.R, file_locations.R, match_tid.R
##               Data - sim_single_matches.csv, sim_contam_matches.csv
## Output files: figure-final-guess-exact.pdf
## 

## requirements ----------------------------------------------------
## loading required packages and sourcing files
library(ggplot2)
library(stringr)
library(reshape2)
library(plyr)
library(xtable)
source("purity_functions.R")
source("file_locations.R")
source("match_tid.R")

## loading-data ----------------------------------------------------
#loading single organisms datasets
single_matches <- read.csv(str_c(path_results_directory,c("/sim_single_matches.csv"), sep=""), stringsAsFactors = F)
single_matches$match <- factor(single_matches$match, levels = c("exact", "species", "genus","family","order","class", "phylum","no match"))
single_matches <- clean_match_df(single_matches)


#loading simualted contaminant datasets
contam_matches <- read.csv(str_c(path_results_directory,"/sim_contam_matches.csv", sep=""), stringsAsFactor = F)
for(i in c("org1_tid","org2_tid","size")){
  contam_matches[,i] <- as.factor(contam_matches[,i])
}
contam_matches <- clean_match_df(contam_matches)

## org-names ----------------------------------------------------
# Getting organism name and genus for matches and single organisms
org_df <- genusNameTable(unique(single_matches$org_tid))
single_matches <- join(single_matches, org_df)
single_matches <- rename(single_matches, c("name" = "target_name",
                                           "genus" = "target_genus"))

org_match_df <- genusNameTable(unique(c(contam_matches$match_tid, single_matches$match_tid)))
org_match_df <- rename(org_match_df,replace = c("org_tid" = "match_tid",
                                                "name" = "match_name",
                                                "genus" = "match_genus"))
contam_matches <- join(contam_matches, org_match_df)
single_matches <- join(single_matches, org_match_df)

## ds-summary-table ---------------------------------------------------------------------
#modifying org_df for single dataset genus summary table
org_table <- dcast(org_df, genus~.)
colnames(org_table) <- c("Genus", "Total Strains")
org_table$Genus <- as.character(org_table$Genus)
org_table2 <- rbind(org_table, c(Genus = "Total", "Total Strains" = sum(org_table[,"Total Strains"])))

## contam-props -------------------------------------------------------------------------
## contaminat proportions - for text
proportions <- str_c(unique(contam_matches$prop1),signif(1 - unique(contam_matches$prop1),2), sep = ":")

## legacy -------------------------------------------------------------------------------
## Summary of single dataset match counts
## Not sure I need this anymore
## sim_unique_counts <- ddply(contam_matches, .(org1_tid, size), summarize, count = length(unique(match_tid)))
## sim_unique_counts$name <- single_matches$name[match(sim_unique_counts$org1_tid, single_matches$org_tid)]
##sim_unique_counts$genus <- single_matches$genus[match(sim_unique_counts$org1_tid, single_matches$org_tid)]

## contam-filter ---------------------------------------------------------
baseline_df <-  single_matches[single_matches$size == 250 & single_matches$org %in% unique(contam_matches$org1),] 
contam_filtered_250 <- filter_noise(contam_matches[contam_matches$size == 250,])
org_df$org2_tid <- org_df$org_tid
contam_filtered_250 <- join(contam_filtered_250, org_df)
contam_filtered_250 <- rename(contam_filtered_250, replace = c("name" = "contam_name",
                                                               "genus" = "contam_genus"))
contam_filtered_250$match_genus <- factor(contam_filtered_250$match_genus, 
                                          levels = c(levels(contam_filtered_250$match_genus),
                                                     "unc. Enterobacteriaceae"))
contam_filtered_250$match_genus[contam_filtered_250$match_tid == 693444] <- "unc. Enterobacteriaceae"

## single-counts-data ----------------------------------------
## Modifying single matches dataframe for figure-single-counts
single_counts <- ddply(single_matches, 
                       .(org_tid, target_genus, size), 
                       summarize, 
                       genus_count = length(unique(match_genus)), 
                       tid_counts = length(unique(match_tid)))
single_counts <- melt(single_counts,id.vars=c("org_tid", "target_genus", "size"))
single_counts$size <- as.factor(single_counts$size)

write.csv(single_counts,"results/data-single-counts.csv", row.names=FALSE)

## single-specificity-data ------------------------------------
## Saving data for single-specificity-plot
single_specificity <- subset(single_counts[single_counts$size == 250,], select = c(value, variable))
write.csv(single_specificity,"results/data-single-specificity.csv", row.names=FALSE)

## final-guess-data --------------------------------------------
## Saving data for final-guess-plot
single_final_guess <- subset(single_matches, select = c(Final.Guess, match))
write.csv(single_final_guess,"results/data-final-guess.csv", row.names=FALSE)


contam_names <- org_df[org_df$org_tid %in% as.character(unique(contam_matches$org2_tid)),]
contam_names$ab_names <- c("S. aureus", "F. tularensis","Y. pestis","S. enterica", "B. anthracis", "P. aeruginosa", "E. coli")
ab_name_order <- c("B. anthracis",  "E. coli", "F. tularensis", "P. aeruginosa", "S. enterica", "S. aureus","Y. pestis" ) 
contam_names$ab_names <- factor(contam_names$ab_names,levels=ab_name_order)

# adding strain names and metadata to org_table2 
org_table2[,"Representative Strain"] <- contam_names$name[match(org_table2$Genus, contam_names$genus)]

#add genome size
#add number of reads/ number of uniquely mapped reads

contam_counts <- ddply(contam_filtered_250, 
                       .(org1_tid, org2_tid, match_genus), 
                       summarize, 
                       counts =length(unique(match_tid)))
contam_counts$org2_name <- contam_names$ab_name[match(as.character(contam_counts$org2_tid),as.character(contam_names$org_tid))]
contam_counts$org2_name <- factor(contam_counts$org2_name,levels=ab_name_order)
contam_counts$org1_name <- contam_names$ab_name[match(as.character(contam_counts$org1_tid),as.character(contam_names$org_tid))]    
contam_counts$org1_name <- factor(contam_counts$org1_name,levels=ab_name_order)

## contam-genus-data --------------------------------------------------------------------
## Saving data for contam_counts
contam_genus <- subset(contam_counts, select = c(org2_name, org1_name, match_genus))
write.csv(contam_genus,"results/data-contam-genus.csv", row.names=FALSE)

## contam-LOD-data ----------------------------------------------------------------------
contam_genus_match <- contam_filtered_250[as.character(contam_filtered_250$match_genus) == as.character(contam_filtered_250$contam_genus),]
contam_genus_match <- contam_genus_match[!is.na(contam_genus_match$Genome),]
contam_genus_match$org1_name <- contam_names$ab_name[match(as.character(contam_genus_match$org1_tid),as.character(contam_names$org_tid))]    
contam_genus_match$org1_name <- factor(contam_genus_match$org1_name,levels=ab_name_order)

contam_LOD <- subset(contam_genus_match, select = c(prop2,org2_tid, match_genus, org1_name))
write.csv(contam_LOD,"results/data-contam-LOD.csv", row.names=FALSE)
