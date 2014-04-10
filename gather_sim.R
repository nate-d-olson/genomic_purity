#################################################################################################################
##
## Summary: Generate combined data file from simulated mixtures
## Date: 1/10/2014
## Author: Nate Olson
## Affiliation: National Institute for Standards and Technology
## Dependencies: pase_sam_report.R (with function for parsing sam-report files)
## Output files: simulated_mix.csv
## 
#################################################################################################################

# Directory with simulated mix sam-report files
source("file_locations.R")


#loading function for parsing pathoscop sam-report files
setwd(working_directory)
source("parse_sam_report.R")

#loading data from indiviudal report files
sizes <- c(75,250)
sim_mix <- data.frame()

#loading sam report files for 75 and 250 bp datasets
for(i in sizes){
  setwd(paste(sim_source_directory, i, sep = ""))
  files <- list.files()
  sim_mix <- data.frame()
  for(j in files){
    df <- parse_sam_report(j)
    if(length(df) > 0){
      df$size <- i
      sim_mix <- rbind(sim_mix, df) 
    }
  }
  setwd(working_directory)
}

#cleaning dataframe
sim_mix$input_filename <- gsub("-sam-report.tsv","", sim_mix$input_filename)
sim_mix$input_filename <- gsub(".bam","", sim_mix$input_filename)

#changing input filenames to allow for split on "-"
sim_mix$input_filename <- gsub("2.5e-05",0.000025,sim_mix$input_filename)
sim_mix$input_filename <- gsub("5e-06",0.000005,sim_mix$input_filename)
sim_mix$input_filename <- gsub("2.5e-06",0.0000025,sim_mix$input_filename)
sim_mix$input_filename <- gsub("5e-07",0.000005,sim_mix$input_filename)

#spliting input file name for use as metadata
sim_mix <- cbind(sim_mix, 
                 colsplit(sim_mix$input_filename, 
                          pattern = "-", 
                          names = c("org1","org2","prop1","prop2")))

#changing the names for sam reports from non-downsampled files
sim_mix$org2[sim_mix$org2 %in% c(75,250)] <- sim_mix$prop1[sim_mix$org2 %in% c(75,250)]
sim_mix$prop1[sim_mix$prop2 %in% c(75,250)] <- 1
sim_mix$prop2[sim_mix$prop2 %in% c(75,250)] <- 1

write.csv(sim_mix, "simulated_mix.csv")
rm(list = ls())
