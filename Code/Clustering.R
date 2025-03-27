# Librairies

library(dplyr)  
library(cluster)


# Importation des données (issue de la data preparation)
data_maladie_preparation <- read.csv("Data/data_maladie_preparation.csv", sep = ",")

## Mise en forme du jeu de données pour l'application du clustering ##

# On pivote le dataset de sorte à avoir une instance par pathologie associée à une prevalence et un nombre de cas pour chaque année
data_clustering <- reshape(data_maladie_preparation, idvar = 'patho_niv2', timevar = 'annee', direction = 'wide')
rownames(data_clustering) <- 1:nrow(data_clustering)
data_clustering <- na.omit(data_clustering)

# calcul du taux de variation de la prévalence entre chaque année (ex : le taux d'augmentation entre 2017 et 2018)
for (year in 2016:2022) {
  prev_current <- paste0('prev.', year)
  prev_previous <- paste0('prev.', year - 1)
  taux_column <- paste0('taux.', year)
  
  data_clustering[[taux_column]] <- (data_clustering[[prev_current]] - data_clustering[[prev_previous]]) / data_clustering[[prev_previous]] * 100  # En pourcentage
}


# On va s'interesser à la variation moyenne du taux sur ces 5 dernieres années, on calcul donc la moyenne des taux de variation pour chaque pathologie et la moyenne du nombre de cas
data_clustering$moyenne_cas <- rowMeans(data_clustering[, c('ntop.2015', 'ntop.2016','ntop.2017', 'ntop.2018', 'ntop.2019', 'ntop.2020', 'ntop.2021', 'ntop.2022')], na.rm = TRUE)
data_clustering$moyenne_taux <- rowMeans(data_clustering[, c('taux.2016','taux.2017', 'taux.2018', 'taux.2019', 'taux.2020', 'taux.2021', 'taux.2022')], na.rm = TRUE)

# Suppression des colonnes inutiles pour le clustering
data_clustering <- data_clustering[, c('patho_niv2', 'moyenne_cas', 'moyenne_taux')]

#Duplication du dataset pour l'analyse des cluster
data_clustering_analyse <- data_clustering


# Normalisation des données
data_clustering[, c('moyenne_cas', 'moyenne_taux')] <- scale(data_clustering[, c('moyenne_cas', 'moyenne_taux')])


## Clustering ##


set.seed(123)

# Sélection des colonnes pour le clustering
X <- data_clustering[, c('moyenne_cas', 'moyenne_taux')]

#Détermination du score silhouette
silhouette_scores <- c()

for (n_clusters in 2:20) {
  model <- kmeans(X, centers = n_clusters, nstart = 10)
  sil <- silhouette(model$cluster, dist(X))
  score_moyen <- mean(sil[, 3])  
  silhouette_scores <- c(silhouette_scores, score_moyen)
  print(paste("Clusters:", n_clusters, "- Silhouette Score:", round(score_moyen, 4)))
}

plot(2:20, silhouette_scores, type = "b", pch = 19, col = "blue",
     xlab = "Nombre de clusters (k)", ylab = "Score de silhouette moyen",
     main = "Courbe du Score de Silhouette")


# Clustering des données
model <- kmeans(X, centers = 8, nstart = 10)
data_clustering$cluster <- model$cluster

# Affichage des clusters
plot(data_clustering$moyenne_taux,data_clustering$moyenne_cas , col = data_clustering$cluster, pch = 19, cex = 2, main = "Moyenne des cas par pathologie et par nombre de cas", xlab = "Moyenne des taux de progression", ylab = "Moyenne des cas")


#On recupere le dataset avant normalisation afin d'analyser les données des clusters
data_analyse <- merge(data_clustering, data_clustering_analyse, by = "patho_niv2")

data_analyse %>%
  group_by(cluster) %>%
  summarise(
    patho_niv2 = n(),  # Nombre de pathologies
    moyenne_cas = mean(moyenne_cas.y),  # Moyenne des cas
    moyenne_taux = mean(moyenne_taux.y)  # Moyenne des taux
  ) %>% arrange(-moyenne_taux)

write.csv(data_clustering, "Data/data_clustering.csv", row.names = FALSE)
