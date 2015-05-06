# folder locations
library(stringr)
purity_directory <- "/media/nolson/second/mirror/purity_study"

if(grepl("apple", sessionInfo()$R.version$platform)){
  purity_directory <- "~/Documents/mirror/purity_study"
}
working_directory <- str_c(purity_directory, "/pathoscope_pure_id", sep = "")
results_directory <- str_c(purity_directory, "/results")
#real_source_directory <- str_c(working_directory, "/sam-report", sep="")
sim_source_directory <- str_c(results_directory, "/2013_12_04", sep="")
path_results_directory <- str_c(working_directory,"/results", sep = "")
