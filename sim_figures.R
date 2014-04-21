library(ggplot2)

sim_matches <- read.csv("sim_path_matches.csv")

ggplot(sim_matches) + geom_bar(aes(x = as.character(org1), fill = org1_match)) + facet_wrap(~prop1)
ggplot(sim_matches) + geom_bar(aes(x = as.character(org2), fill = org2_match))
