# Librairies

library(dplyr)  
library(cluster)


# Importation des données (issue de la data preparation)
data_maladie_effectifs_finistere <- read.csv("Data/data_maladie_effectifs_finistere.csv", sep = ",")

## Mise en forme du jeu de données pour l'application du clustering ##

# On pivote le dataset de sorte à avoir une instance par pathologie associée à une prevalence et un nombre de cas pour chaque année
data_maladie_effectifs_finistere <- reshape(data_maladie_effectifs_finistere, idvar = 'patho_niv2', timevar = 'annee', direction = 'wide')

# Réinitialiser l'index
rownames(data_maladie_effectifs_finistere) <- 1:nrow(data_maladie_effectifs_finistere)

data_maladie_effectifs_finistere <- na.omit(data_maladie_effectifs_finistere)

# Afin d'analyser les variation de la prévalence des pathologies, on calcul le taux de variation de la prévalence pour chaque année (ex : le taux d'augmentation entre 2017 et 2018)
for (year in 2016:2022) {
  prev_current <- paste0('prev.', year)
  prev_previous <- paste0('prev.', year - 1)
  taux_column <- paste0('taux.', year)
  
  data_maladie_effectifs_finistere[[taux_column]] <- (data_maladie_effectifs_finistere[[prev_current]] - data_maladie_effectifs_finistere[[prev_previous]]) / data_maladie_effectifs_finistere[[prev_previous]] * 100  # En pourcentage
}


# On va s'interesser à la variation moyenne du taux sur ces 5 dernieres années, on calcul donc la moyenne des taux de variation pour chaque pathologie et la moyenne du nombre de cas
data_maladie_effectifs_finistere$moyenne_cas <- rowMeans(data_maladie_effectifs_finistere[, c('ntop.2015', 'ntop.2016','ntop.2017', 'ntop.2018', 'ntop.2019', 'ntop.2020', 'ntop.2021', 'ntop.2022')], na.rm = TRUE)

data_maladie_effectifs_finistere$moyenne_taux <- rowMeans(data_maladie_effectifs_finistere[, c('taux.2016','taux.2017', 'taux.2018', 'taux.2019', 'taux.2020', 'taux.2021', 'taux.2022')], na.rm = TRUE)

# Suppression des colonnes inutiles pour le clustering
data_maladie_effectifs_finistere <- data_maladie_effectifs_finistere[, c('patho_niv2', 'moyenne_cas', 'moyenne_taux')]

# Normalisation des données
data_maladie_effectifs_finistere[, c('moyenne_cas', 'moyenne_taux')] <- scale(data_maladie_effectifs_finistere[, c('moyenne_cas', 'moyenne_taux')])


## Clustering ##


set.seed(123)

data_clustering <- data_maladie_effectifs_finistere

# Sélection des colonnes pour le clustering
X <- data_clustering[, c('moyenne_cas', 'moyenne_taux')]

# Initialisation des scores de silhouette
silhouette_scores <- c()

# Boucle pour tester différents nombres de clusters
for (n_clusters in 2:30) {
  model <- kmeans(X, centers = n_clusters, nstart = 10)
  
  # Calcul du score de silhouette
  sil <- silhouette(model$cluster, dist(X))
  
  # Stocker la moyenne du score de silhouette
  score_moyen <- mean(sil[, 'sil_width'])
  silhouette_scores <- c(silhouette_scores, score_moyen)
  
  # Affichage du score de silhouette pour chaque nombre de clusters
  print(paste("Clusters:", n_clusters, "- Silhouette Score:", round(score_moyen, 4)))
}

# Clustering des données
model <- kmeans(X, centers = 7, nstart = 10)
data_clustering$cluster <- model$cluster


# PROBLEME D'affichage des clusters


# Affichage des clusters
plot(data_clustering$moyenne_taux,data_clustering$moyenne_cas , col = data_clustering$cluster, pch = 19, cex = 2, main = "Moyenne des cas par pathologie et par nombre de cas", xlab = "Moyenne des taux de progression", ylab = "Moyenne des cas")
legend('topright', legend = unique(data_clustering$cluster), col = 1:10, pch = 19, cex = 1, title = 'Cluster')


# Affichage des données des clusters
data_clustering %>%
  group_by(cluster) %>%
  summarise(
    patho_niv2 = n(),  # Nombre de pathologies
    moyenne_cas = mean(moyenne_cas),  # Moyenne des cas
    moyenne_taux = mean(moyenne_taux)  # Moyenne des taux
  ) %>% arrange(-moyenne_taux)

write.csv(data_clustering, "Data/data_clustering.csv", row.names = FALSE)
