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

applyfilter <- function(org1, Genome, Final.Guess, size){  
  if(Genome %in% single_matches$Genome[single_matches$org == org1 & single_matches$size == size]){
    if(Final.Guess < 10*single_matches$Final.Guess[single_matches$org == org1 & 
                                                   single_matches$Genome == Genome & 
                                                   single_matches$size ==size]){
      return(0)
    }
    return(1)
  }
  return(1)
}

# subtracting single org hits 
#if Genome in single dataset and final genome in contam less than 10*Final.Guess in single remove from contam dataset
filter_noise <- function(single_matches, contam_matches){
  contam_filt <- ddply(contam_matches, 
                .(org1,Genome,input_filename, Final.Guess, size), 
                transform, 
                filtered=applyfilter(org1, Genome, Final.Guess,size)) 
  return(contam_filt[contam_filt$filter == 1,])
}

