#################################################################################################################
##
## Summary: Generate combined data file from simulated mixtures
## Date: 1/10/2014
## Author: Nate Olson
## Affiliation: National Institute for Standards and Technology
## Dependencies: pase_sam_report.R (with function for parsing sam-report files)
## Output files: simulated_contam_mix.csv, simulated_full_mix.csv, simulated_single.csv
## 
#################################################################################################################
library(stringr)
# Directory with simulated mix sam-report files
source("file_locations.R")


#loading function for parsing pathoscop sam-report files
setwd(working_directory)
source("parse_sam_report.R")

#loading data from indiviudal report files
sizes <- c(75,250)
sim_ds <- data.frame()

#loading sam report files for 75 and 250 bp datasets
#------ can speed up by using plyr to loop through the files
for(i in sizes){
  setwd(str_c(sim_source_directory,"/contam_", i, sep = ""))
  files <- grep("-sam-report.tsv", list.files(), value = T)
  for(j in files){
    df <- parse_sam_report(j)
    if(length(df) > 0){
      df$size <- i
      sim_ds <- rbind(sim_ds, df) 
    }
  }
  setwd(working_directory)
}
rm("files","i","j","sizes","df")
sim_ds$input_filename <- str_replace(string=sim_ds$input_filename, 
                                     pattern="-sam-report.tsv",
                                     replacement="")
#split based on source types
#1 pure organisms
single_filenames <- unique(grep("(-75|-250)$", sim_ds$input_filename, value = T))
sim_single <- sim_ds[sim_ds$input_filename %in% single_filenames,]

#2 full mix
full_filenames <- unique(grep("bam", sim_ds$input_filename, value = T))
sim_full_mix <- sim_ds[sim_ds$input_filename %in% full_filenames,]
sim_full_mix$input_filename <- str_replace_all(string=sim_full_mix$input_filename,pattern="-75.bam-|-250.bam-","-")
sim_full_mix$input_filename <- str_replace_all(string=sim_full_mix$input_filename,pattern="-75.bam|-250.bam","-0.5-0.5")


#3 simulated contamination
sim_contam_mix <- sim_ds[!(sim_ds$input_filename %in% unique(c(single_filenames, full_filenames))),]

####
##
## Cleaning up dataframes before writing to files
##
####

## single sample
sim_single$input_filename <- str_replace(string= sim_single$input_filename, 
                                         pattern= "-75|-250",
                                         replacement= "")

## sim_contam_mix
#changing input filenames to allow for split on "-"
sim_contam_mix$input_filename <- gsub("2.5e-05",0.000025,sim_contam_mix$input_filename)
sim_contam_mix$input_filename <- gsub("5e-06",0.000005,sim_contam_mix$input_filename)
sim_contam_mix$input_filename <- gsub("2.5e-06",0.0000025,sim_contam_mix$input_filename)
sim_contam_mix$input_filename <- gsub("5e-07",0.000005,sim_contam_mix$input_filename)

#spliting input file name for use as metadata
sim_contam_mix <- cbind(sim_contam_mix, colsplit(sim_contam_mix$input_filename, 
                                                 pattern = "-", 
                                                 names = c("org1","org2","prop1","prop2")))


write.csv(sim_contam_mix, str_c(path_results_directory,"simulated_contam.csv", sep= "/"), row.names = FALSE)
write.csv(sim_full_mix, str_c(path_results_directory,"simulated_full.csv", sep= "/"), row.names = FALSE)
write.csv(sim_single, str_c(path_results_directory,"simulated_single.csv", sep= "/"), row.names = FALSE)
#rm(list = ls())
