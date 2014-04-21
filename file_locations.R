# folder locations
library(stringr)
working_directory <- "/media/nolson/second/mirror/purity_study/pathoscope_pure_id"
if(grepl("apple", sessionInfo()$R.version$platform)){
  working_directory <- "~/Documents/mirror/purity_study/pathoscope_pure_id"
}
real_source_directory <- str_c(working_directory, "/sam-report/", sep="")
sim_source_directory <- str_c(working_directory, "/sam-report/2013_11_23/", sep="")
