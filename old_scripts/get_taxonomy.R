library(taxize)

#getting the test orgs taxa information
org <-c("B_anthracis",
        "E_coli_K12",
        "F_tularensis",
        "P_aeruginosa",
        "S_aureus_NC_17337",
        "Y_pestis",
        "S_enterica_LT2")
long_org <- c( "BACILLUS ANTHRACIS STR. AMES",
               "ESCHERICHIA COLI",
               "FRANCISELLA TULARENSIS SUBSP. TULARENSIS SCHU S4",
               "PSEUDOMONAS AERUGINOSA PAO1",
               "STAPHYLOCOCCUS AUREUS SUBSP AUREUS ED133",
               "YERSINIA PESTIS",
               "SALMONELLA ENTERICA SUBSP ENTERICA SEROVAR TYPHIMURIUM STR LT2")
#"YERSINIA PESTIS CO92",
#"ESCHERICHIA COLI STR. K-12 SUBSTR MG165",

#get classification
classifications <- list()
classifications[org] <- classification(long_org, db = 'ncbi')


#get children of each org for the species, genus, family
species_children <- list()
for(i in names(classifications)){
  species_children[i]<- col_children(name = classifications[[i]][["ScientificName"]][8])
}
genus_children <- list()
for(i in names(classifications)){
 genus_children[i]<- col_children(name = classifications[[i]][["ScientificName"]][7])
}

family_children <- list()
for(i in names(classifications)){
  family_children[i]<- col_children(name = classifications[[i]][["ScientificName"]][6])
}