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