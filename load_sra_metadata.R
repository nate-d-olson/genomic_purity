#################################################################################################################
##
## Summary: Load metadata from SRA runs from genome tracker run info file
## File obtained from GenBank SRA 
## Date: 1/10/2014
## Author: Nate Olson
## Affiliation: National Institute for Standards and Technology
## Dependencies: R packages reshape2
## Output:
## 
#################################################################################################################

inputfile <- "~/Downloads/SraRunInfo.csv"
sra_meta <- read.csv(inputfile)