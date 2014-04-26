library(ggplot2)

sim_matches <- read.csv("results//sim_contam_matches.csv", stringsAsFactor = F)

#figures
ggplot(sim_matches) + geom_bar(aes(x = as.factor(prop1), 
                                   fill = org1_match), position = "fill") + 
  facet_wrap(~org1)+ 
  theme(axis.text.x=element_text(angle=-90))

ggplot(sim_matches) + geom_bar(aes(x = as.factor(prop2), 
                                   fill = org2_match),position = "fill") + 
  facet_wrap(~org1)+ 
  theme(axis.text.x=element_text(angle=-90))

ggplot(sim_matches) + geom_bar(aes(x = as.factor(org2), 
                                   fill = match), position = "fill") + 
  facet_grid(size~org1)+ 
  theme(axis.text.x=element_text(angle=-90))

ggplot(sim_matches) + 
  geom_bar(aes(x = match, fill = as.character(size)),position = "dodge")  + 
  theme(axis.text.x=element_text(angle=-90))
