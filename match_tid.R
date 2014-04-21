### function for matching taxonomy
match_tid <- function(tid1, tid2){
  require(NCBI2R)
  common <- CompareTaxInfo(id1=tid1, id2=tid2)$common
  return(common[common$line.rank %in% c("kingdom","phylum","class","order","family","genus","species"),])
}