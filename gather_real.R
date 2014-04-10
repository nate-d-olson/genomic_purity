#################################################################################################################
##
## Summary: Generate combined data file from pathoscope analysis of real data
## Date: 1/10/2014
## Author: Nate Olson
## Affiliation: National Institute for Standards and Technology
## Dependencies: pase_sam_report.R (with function for parsing sam-report files)
## Output files: real_data.csv
## 
#################################################################################################################

# Directory with simulated mix sam-report files
source("file_locations.R")

#loading function for parsing pathoscop sam-report files
#setwd(working_directory)
source("parse_sam_report.R")

dates <- c("2013_12_17","2013_12_20")
real_data <- data.frame()

#loading sam report files for real datasets
for(i in dates){
  setwd(paste(real_source_directory, i, sep = ""))
  files <- list.files()
  for(j in files){
    df <- parse_sam_report(j)
    if(length(df) > 0){
      real_data <- rbind(real_data, df) 
    }
  }
  setwd(working_directory)
}

#cleaning dataframe
real_data$input_filename <- gsub("-sam-report.tsv","",real_data$input_filename)

write.csv(real_data, "real_data.csv")
rm(list = ls())