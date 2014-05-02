library(ape)
library(phyloseq)
#New thought for each org pair create a phylogenetic tree
#annotate the phylogenetic tree with the presence/absence for each prop
#create tree
  #load NCBI tree
  #prune tree based on unqiue branches
  taxids <- unique(contam_filtered$match_tid[contam_filtered$org1_tid == 99287 & contam_filtered$org2_tid == 177416])
  tr <- read.tree("~/Downloads//ncbi_complete_collapsed_with_taxIDs.newick")
  trim_tree <- phyloseq(drop.tip(tr,tr$tip.label[-taxids]))
  plot_tree(trim_tree,
            nodelabf = nodeplotblank, 
            ladderize = "left", 
            label.tips = tip.name)

Need to work on tree generation
need to think if this is the best approach
is there a better way to determine the relationship of the matches

  