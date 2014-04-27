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
library(plyr)
source("file_locations.R")
source("parse_sam_report.R")

#loading data from indiviudal report files
size <- c(75, 250)
sim_ds <- data.frame()

#loading sam report files for 75 and 250 bp datasets
#------ can speed up by using plyr to loop through the files
for(i in size){
  setwd(str_c(sim_source_directory, "/contam_", i, sep = ""))
  files <- grep("-sam-report.tsv", list.files(), value = T)
  df <- ldply(files,parse_sam_report)
  df$size <- i
  sim_ds <- rbind(sim_ds, df)
}
setwd(working_directory)
sim_ds$input_filename <- str_replace(string=sim_ds$input_filename, 
                                     pattern="-sam-report.tsv",
                                     replacement="")


mod_input_filename <- function(df){
  df$input_filename <- str_replace(string=df$input_filename, 
                                       pattern="-sam-report.tsv",
                                       replacement="")
  df <- cbind(df,colsplit(string=df$input_filename,pattern="-", names=c("org","size")))
  df$input_filename <- str_replace(string= df$input_filename, 
                                           pattern= "-75|-250",
                                           replacement= "")
  return(df)
}




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
sim_single <- mod_input_filename(sim_single)

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

## Simulated BA
setwd(str_c(results_directory, "2013_12_04/BA", sep = "/"))
files <- grep("-sam-report.tsv", list.files(), value = T)
sim_BA <- ldply(files,parse_sam_report)
setwd(working_directory)
sim_BA <- mod_input_filename(sim_BA)
write.csv(sim_BA, str_c(path_results_directory,"simulated_BA.csv", sep= "/"), row.names = FALSE)

## Simulated Ecoli
setwd(str_c(results_directory, "2013_12_09", sep = "/"))
files <- grep("-sam-report.tsv", list.files(), value = T)
sim_EC <- ldply(files,parse_sam_report)
setwd(working_directory)
sim_EC <- mod_input_filename(sim_EC)
write.csv(sim_EC, str_c(path_results_directory,"simulated_EC.csv", sep= "/"), row.names = FALSE)

rm(list = ls())
