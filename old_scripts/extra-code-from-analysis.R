#Old code from poster
```{r contam-match-levels, echo=FALSE, message=FALSE}
#match table taxonomic names find lowest shared common taxonomic level
org_sets <- combn(as.numeric(levels(contam_matches$org1_tid)), m = 2, simplify=F)
org_taxa_share <- ldply(org_sets,function(x){GetMatchLevel(id1 =x[1], id2= x[2])})
org_taxa_share <- cbind(org_taxa_share, ldply(org_sets))
colnames(org_taxa_share) <- c("match", "org1_tid","org2_tid")
org_taxa_share2 <- data.frame(match = org_taxa_share$match, 
                              org1_tid = org_taxa_share$org2_tid,
                              org2_tid = org_taxa_share$org1_tid)
org_taxa_share <- rbind(org_taxa_share, org_taxa_share2)
```

```{r baselines, echo=FALSE, message=FALSE}
#baseline values
#from single matches get the Final.Guess values for the appropriate match level
#what are you defining as base line- max Final.Guess for each level
single_matches <- join(single_matches, org_df)
baseline <- ddply(single_matches, .(genus, match), summarize, min = min(Final.Guess), median = mean(Final.Guess),max = max(Final.Guess), p90 = quantile(Final.Guess, probs=0.9))
```

```{r echo=FALSE, message=FALSE, fig.width=12}
#line plotshowing Final.Gues relationship with match level read size and genus for single organisms
sim_quant <- ddply(single_matches, .(genus,match,size),summarize, p90 = quantile(Final.Guess, probs=0.9))
ggplot(sim_quant) + geom_line(aes(x = as.numeric(match), y = p90, color = genus)) + scale_y_log10() + scale_x_continuous(breaks = 1:length(levels(sim_quant$match)), labels = levels(sim_quant$match)) + labs(y = "Final.Guess value 90th Percentile", x = "Shared Taxonomic Level with Match") + facet_wrap(~size) + theme_bw()
```

#### LOD by organism and contaminant
```{r echo=FALSE, message=FALSE}
sim_LOD <- ddply(.data=contam_matches[grep("org2",contam_matches$match),],
                 .variables=.(size, org1_tid, org2_tid, org2_match), 
                 summarize, LOD = min(prop2))
sim_LOD$match <- factor(sim_LOD$org2_match, levels = c("exact", "species", "genus","family","order","class", "phylum"))
sim_LOD$name <- single_matches$name[match(sim_LOD$org1_tid, single_matches$org_tid)]
sim_LOD$genus <- single_matches$genus[match(sim_LOD$org1_tid, single_matches$org_tid)]
sim_LOD <- join(sim_LOD, org_taxa_share)
```
Limit of detection is defined as the proportion of contaminants with the lowest proportion.  The contaminant proportion is representative of the proprotion of the sample and not the proportion of reads.


```{r }
#creating baseline dataset for org1 org2 pairs
#base line defined as the max Final.Guess value in the simulated dataset for org1 genus as the shared taxa level
org_taxa_share$genus <- single_matches$genus[match(org_taxa_share$org1_tid, single_matches$org_tid)]

org_share_base <- join(org_taxa_share,baseline, type="inner")

sim_LOD$genus <- single_matches$genus[match(sim_LOD$org1_tid, single_matches$org_tid)]

org_share_base$org1_tid <- factor(org_share_base$org1_tid)
org_share_base$org2_tid <- factor(org_share_base$org2_tid)
ggplot(org_share_base) + 
  #geom_point(aes(x = 1, y = median, color = match), shape = 3, size = 3) +
  #geom_linerange(aes(x = size,ymax = max, ymin = min ), color = "grey") +
  geom_hline(aes(yintercept = median, color = match)) +
  geom_point(data = contam_matches[grep("org2", contam_matches$match),], 
             aes(x = size, y = prop2, color = org2_match), position = position_dodge(width=1)) + 
  scale_y_log10() + 
  #scale_x_continuous(breaks = 1:length(levels(sim_quant$match)), labels = levels(sim_quant$match)) + 
  labs(y = "Final.Guess value 90th Percentile", x = "Shared Taxonomic Level with Match") + 
  facet_grid(org1_tid~org2_tid) + 
  theme_bw()


ggplot(sim_LOD) + 
  geom_point(aes(x = org2_tid, y = LOD, color = org2_tid)) + 
  geom_point(aes(x = match, y = median)) +
  geom_linerange(aes(x = match,ymax = max, ymin = min )) +
  scale_y_log10() + 
  #  #scale_x_continuous(breaks = 1:length(levels(sim_quant$match)), labels = levels(sim_quant$match)) + 
  # labs(y = "Final.Guess value 90th Percentile", x = "Shared Taxonomic Level with Match") + 
  facet_grid(size~genus) + 
  theme_bw()
```
Matches at any level to the contaminant genome.

```{r message=FALSE, fig.height=6, fig.width=18}
ggplot(sim_LOD) + 
  geom_point(aes(x = org1_tid, y= LOD, color = org2_match),alpha = 0.75, position = position_dodge(width = 0.5), size = 3) +
  geom_line(aes(x = org1_tid, y = LOD)) +
  labs(linetype = "Read Size (bp)", x = "Match Level") + 
  scale_y_log10() + 
  theme_bw() +
  theme(axis.text.x=element_text(angle=-90)) +
  facet_grid(size~org2_tid, scale = "free")
```
```{r echo=FALSE, message=FALSE}
LOD_table <-dcast(sim_LOD,org2_tid*org1_tid~org2_match*size, value.var = "LOD", fill= "")
```
```{r results='asis', echo=FALSE}
library(xtable)
print(xtable(LOD_table),type='html')
```
