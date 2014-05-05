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

Plot showing the number of hits for the simualted contamined datasets.
```{r}
#other factor is the org2 proportions
ggplot(contam_filtered) + geom_bar(aes(x = org2_tid, fill = match)) + facet_grid(org1_tid~size) 
ggplot(contam_filtered[contam_filtered$org2_match == "exact",]) + geom_raster(aes(x = org2_tid, y = as.factor(prop2), fill = match)) + facet_grid(org1_tid~size) 
ggplot(contam_filtered[contam_filtered$org2_match == "species",]) + geom_raster(aes(x = org2_tid, y = as.factor(prop2), fill = match)) + facet_grid(org1_tid~size) 
```
```{r}
contam_LOD <- ddply(contam_filtered,.(org1_tid,org2_tid, size, org2_match), summarize, LOD = min(prop2))
ggplot(contam_LOD) + geom_raster(aes(x = size, y = as.factor(LOD))) + facet_grid(org1_tid~org2_tid) 
```
```{r}
contam_unique <- ddply(contam_filtered, .(org1_tid,org2_tid, Genome, match_tid,org2_match,size), summarize, count = length(prop2))
ggplot(contam_unique) + geom_bar(aes(x = org2_tid, fill = org2_match)) + facet_grid(size~org1_tid)
```
The proportion of the values for Final.Guess is dependent on the match level and the genus of the target organims.  

```{r single-line-plot, echo=FALSE, message=FALSE, fig.width=12}
#line plot showing Final.Gues relationship with match level read size and genus for single organisms
sim_quant <- ddply(single_matches, .(genus,match,size),summarize, p90 = quantile(Final.Guess, probs=0.9))
ggplot(sim_quant) + geom_line(aes(x = as.numeric(match), y = p90, color = genus)) + scale_y_log10() + scale_x_continuous(breaks = 1:length(levels(sim_quant$match)), labels = levels(sim_quant$match)) + labs(y = "Final.Guess value 90th Percentile", x = "Shared Taxonomic Level with Match") + facet_wrap(~size) + theme_bw()
```
```{r contam-counts, echo=FALSE, message=FALSE}
ggplot(sim_unique_counts) + 
  geom_boxplot(aes(x = size, y = count), color = "grey") +
  geom_point(aes(x = size, y = count, color = org1_tid), size = 4) + 
  geom_line(aes(x = as.numeric(size), y = count, color = org1_tid)) +
  labs(x = "Read Size (bp)", y = "Number of hits to unique organisms", color = "Organism")+
  theme_bw()
```
Between 50 and 200 unique organism hits for each of the dataset combinations.  The difference in the number of unique matches has a much larger decrease compared to single organisms.  

To hits to the single organism simulated datasets were removed from the contaminant datasets if the Final.Guess for the hit was less than 10 times the Final.Guess for the single organism.

```{r single-counts-plot, echo=FALSE, fig.width = 6, fig.height=12}
#need to order x axis species - genus
ggplot(single_counts) + 
  geom_line(aes(x = -as.numeric(variable), y = value, color = as.character(org_tid)), 
            alpha = 0.5, show_guide = F) +
  geom_point(aes(x = -as.numeric(variable), y = value, color = as.character(org_tid)), 
             size = 4, alpha = 0.5, show_guide = F) + 
  scale_x_continuous(breaks = -length(levels(single_counts$variable)):-1, 
                     labels = c("Genus", "Strain")) +
  labs(x = "Match Level", y = "Number of unqiue hits", color = "Target\nGenus")+
  theme_bw() +
  facet_grid(target_genus~size) +
  theme(strip.text.y = element_text(face="italic"))
```