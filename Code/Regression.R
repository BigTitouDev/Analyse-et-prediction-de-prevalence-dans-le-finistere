
library(dplyr) 
library(tidyverse)
library(caret)
library(randomForest)
library(rpart)

# Importation des données (Data preparation et data clustering)
data_maladie_effectifs_finistere <- read.csv("data_maladie_effectifs_finistere.csv", sep = ",")
data_clustering <- read.csv("data_clustering.csv", sep = ",")

# Fusion des datasets sur la colonne 'patho_niv2'
data_regression <- merge(data_clustering, data_maladie_effectifs_finistere, by = "patho_niv2")

# Filtrage des clusters avec un taux d'augmentation de prévalence elevé (cluster 1 et 5 pour le seed 128)

data_regression <- data_regression[data_regression$cluster %in% c(1, 5), ]

# Suppression des colonnes 'moyenne_cas', 'moyenne_taux' et 'cluster'
data_regression <- data_regression %>% select(-moyenne_cas, -moyenne_taux, -cluster)

# Liste de toutes les pathologies dans votre dataset
pathologies <- unique(data_regression$patho_niv2)

# Pour chaque pathologie, calculer la régression, la MSE et prédire pour 2030
for (patho in pathologies) {
  
  # Filtrer les données pour la pathologie actuelle
  data_patho <- filter(data_regression, patho_niv2 == patho)
  
  # Vérifier si la pathologie a suffisamment de données (au moins 2 années)
  if (nrow(data_patho) > 1) {
    
    # Modèle de régression linéaire
    lm_model <- lm(ntop ~ annee + npop, data = data_patho)
    lm_predictions <- predict(lm_model, newdata = data_patho)
    mse_lm <- mean((lm_predictions - data_patho$ntop)^2)
    
    # Modèle d'arbre de décision
    tree_model <- rpart(ntop ~ annee + npop, data = data_patho)
    tree_predictions <- predict(tree_model, newdata = data_patho)
    mse_tree <- mean((tree_predictions - data_patho$ntop)^2)
    
    # Modèle de forêt aléatoire
    rf_model <- randomForest(ntop ~ annee + npop, data = data_patho)
    rf_predictions <- predict(rf_model, newdata = data_patho)
    mse_rf <- mean((rf_predictions - data_patho$ntop)^2)
    
    # Prédiction pour 2030 (pour chaque modèle)
    prediction_lm <- predict(lm_model, newdata = data.frame(annee = 2030, npop = 950000))
    prediction_tree <- predict(tree_model, newdata = data.frame(annee = 2030, npop = 950000))
    prediction_rf <- predict(rf_model, newdata = data.frame(annee = 2030, npop = 950000))
    
    # Afficher les résultats pour la pathologie actuelle
    cat("\nPathologie:", patho, "\n")
    cat("MSE (Régression Linéaire):", sqrt(mse_lm), "\n")
    cat("MSE (Arbre de Décision):", sqrt(mse_tree), "\n")
    cat("MSE (Forêt Aléatoire):", sqrt(mse_rf), "\n")
    cat("Prédiction pour 2030 (Régression Linéaire):", prediction_lm, "\n")
    cat("Prédiction pour 2030 (Arbre de Décision):", prediction_tree, "\n")
    cat("Prédiction pour 2030 (Forêt Aléatoire):", prediction_rf, "\n")
  } else {
    cat("\nPas assez de données pour la pathologie:", patho, "\n")
  }
}
