# function for removing unused columns
clean_match_df <- function(match_df){
  return(subset(match_df, select = -c(Final.Best.Hit, 
                                      Final.High.Confidence.Hits, 
                                      Final.Low.Confidence.Hits, 
                                      Initial.Guess, 
                                      Initial.Best.Hit, 
                                      Initial.Best.Hit.Read.Numbers, 
                                      Initial.High.Confidence.Hits, 
                                      Initial.Low.Confidence.Hits)))
}

unique_count_plot <- function (df) {
  sim_unique_counts <- ddply(df, .(org, org_tid, size), summarize, count = length(unique(match_tid)))
  sim_unique_counts$size <- as.factor(sim_unique_counts$size)
  sim_unique_counts <- join(sim_unique_counts, org_df)
  sim_plot<- ggplot(sim_unique_counts) + 
    geom_boxplot(aes(x = size, y = count), color = "grey") +
    geom_point(aes(x = size, y = count, color = as.character(org_tid)), size = 4, alpha = 0.5, show_guide = F) + 
    geom_line(aes(x = as.numeric(size), y = count, color = as.character(org_tid)), alpha = 0.5, show_guide = F) +
    labs(x = "Read Size (bp)", y = "Number of hits to unique organisms", color = "Organism")+
    theme_bw() +
    facet_wrap(~genus)
  return(sim_plot)
}


## Register parallel backend
#library(doParallel)
#cl <- makeCluster(5)
#registerDoParallel(cl)

applyfilter <- function(org1, Genome, Final.Guess){  
  baseline_genomes <- baseline_df$Genome[baseline_df$org == org1]
  baseline_guess <- single_matches$Final.Guess[baseline_df$org == org1 & baseline_df$Genome == Genome]
  if(Genome %in% baseline_genomes && Final.Guess < 10*baseline_guess ){
    return(0)
  }
  return(1)
}

# subtracting single org hits 
#if Genome in single dataset and final genome in contam less than 10*Final.Guess in single remove from contam dataset
filter_noise <- function(toFilter_df){
  contam_filt <- ddply(toFilter_df, 
                .(org1,Genome,input_filename, Final.Guess), 
                transform, 
                filtered=applyfilter(org1, Genome, Final.Guess)) #,
                #.parallel = T) 
                # parallel not working receiving the following error message
                # warning message - <anonymous>: ... may be used in an incorrect context: ‘.fun(piece, ...)’
                # filtered assigned 0 for all entries
  contam_filt <- contam_filt[contam_filt$filtered == 1,]
  contam_filt$filtered <- NULL
  return(contam_filt)
}

genusNameTable <- function (tids) {
  #idea to speed up adply?
  org_name <- c()
  org_genus <- c()
  for(i in tids){
    org_name <- c(org_name,python.call("getNameByTaxid", i))
    org_taxa <- GetTaxInfoLocal(i)
    org_genus <- c(org_genus, as.character(org_taxa$name[org_taxa$rank == "genus"][1]))
  }
  return(data.frame(org_tid = tids, name = org_name, genus = org_genus)) 
}
