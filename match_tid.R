### functions for matching taxonomy
## using the pyphy.py code
require(rPython)
python.load("pyphy.py",get.exception=TRUE)

GetTaxInfoLocal <- function(ids){
  #gets the tid lineage for the specified taxid
  tid <- python.call("getPathByTaxid", ids)
  rank <- c()
  name <- c()
  for(i in tid){
    rank <- c(rank,python.call("getRankByTaxid", i))
    name <- c(name,python.call("getNameByTaxid", i))
  }
  lineage <- data.frame(tid,rank,name)
  lineage <- lineage[lineage$rank %in% c("kingdom","phylum","class","order","family","genus","species"),]
  return(lineage)
}

CompareTaxInfoLocal <- function(id1, id2){
    require(plyr)
    if (length(id1) != 1 | length(id2) != 1) 
      stop("Error: One item sep by columns please.")
    g1 <- GetTaxInfoLocal(id1)
    g2 <- GetTaxInfoLocal(id2)
    common <- join(x=g1, y=g2, by= "tid", type="inner")
    return(common)
}

GetTaxid <- function(id, type){
  if (type == 'uid'){
    return(python.call("getTaxidByUid", id))
  }else if (type == 'gi'){
    return(python.call("getTaxidByGi", id))
  } else {
    stop("Error: Id number must be specified at 'gi' or 'uid'.")    
  }
}

GetMatchLevel <- function(id1, id2){
  matches <- CompareTaxInfoLocal(id1, id2)
  
  #all pairs share this same match - not sure where the error is ...
  matches <- matches[matches$tid != 131567,]
  for(level in rev(c("domain","kingdom","phylum","class","order","family","genus","species")))
    if(level %in% matches$rank){
      return(level)
  }
  return("no match")
}