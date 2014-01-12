#################################################################################################################
##
## Summary: Parse pathoscope sam-report.tsv output files from pathoscope
## Date: 1/10/2014
## Author: Nate Olson
## Affiliation: National Institute for Standards and Technology
## Dependencies: reshape2
## Output files:.
## 
#################################################################################################################

## Example input file
#====================
#Total Number of Aligned Reads:  623	Total Number of Mapped Genomes:	9
#Genome	MapQ Guess	MapQ Best Hit	MapQ Best Hit Read Numbers	MapQ High Confidence Hits	MapQ Low Confidence Hits	Alignment Guess	Alignment Best Hit	Alignment Best Hit Read Numbers	Alignment High Confidence Hits	Alignment Low Confidence Hits
#ti|1133852|org|Escherichia_coli_O104:H4_str._2011C-3493	0.9999766754464884	0.9678972712680578	603.0	0.9678972712680578	0.0	0.9999766754464884	0.9678972712680578	603.0	0.9678972712680578	0.0
#ti|585056|org|Escherichia_coli_UMN026	2.3324078726666834e-05	0.012841091492776886	8.0	0.012841091492776886	0.0	2.3324078726666834e-05	0.012841091492776886	8.0	0.012841091492776886	0.0
#ti|585397|org|Escherichia_coli_ED1a	3.8955107904062245e-10	0.0032102728731942215	2.0	0.0032102728731942215	0.0	3.8955107904062245e-10	0.0032102728731942215	2.0	0.0032102728731942215	0.0
#ti|562|org|Escherichia_coli	6.583931938866915e-11	0.009630818619582664	6.0	0.009630818619582664	0.0	6.583931938866915e-11	0.009630818619582664	6.0	0.009630818619582664	0.0
#ti|216592|org|Escherichia_coli_042	1.939460620497064e-11	0.0016051364365971107	1.0	0.0016051364365971107	0.0	1.939460620497064e-11	0.0016051364365971107	1.0	0.0016051364365971107	0.0
#ti|585055|org|Escherichia_coli_55989	2.5328608787508853e-24	0.0016051364365971107	1.0	0.0016051364365971107	0.0	2.5328608787508853e-24	0.0016051364365971107	1.0	0.0016051364365971107	0.0
#ti|566546|org|Escherichia_coli_W	7.817298332120808e-26	0.0016051364365971107	1.0	0.0016051364365971107	0.0	6.305185886832915e-26	0.0008025682182985554	0.5	0.0016051364365971107	0.0Example input file format

require(reshape2)
#sessionInfo()

parse_sam_report <- function(inputfile){
  if(file.info(inputfile)$size == 0){
    return(data.frame())
  }
  
  input_lines <- readLines(inputfile)

  #Converting input to dataframe
  col_names <- strsplit(input_lines[2], split = "\t")[[1]]
  col_names <- gsub(" ","-", col_names)
  report <- colsplit(input_lines[c(-1,-2)], pattern = "\t", names = col_names)

  #adding meta-date
  meta <- strsplit(input_lines[1], split = "\t")[[1]]
  report$input_filename <- inputfile
  report$Aligned_Reads <- meta[2]
  report$Mapped_Genome <- meta[4]

  return(report)
}