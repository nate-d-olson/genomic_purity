library(ggplot2)

sim_matches <- read.csv("sim_path_matches.csv")

ggplot(sim_matches) + geom_bar(aes(x = as.character(prop1), 
                                   fill = org1_match), position = "fill") + 
  facet_wrap(~org1)
ggplot(sim_matches) + geom_bar(aes(x = as.character(org2), 
                                   fill = org2_match),position = "fill")