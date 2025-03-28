
library(dplyr) 
library(tidyverse)
library(caret)
library(randomForest)
library(rpart)

# Importation des données (Data preparation et data clustering)
data_maladie_preparation <- read.csv("Data/data_maladie_preparation.csv", sep = ",")
data_clustering <- read.csv("Data/data_clustering.csv", sep = ",")

# Fusion des datasets sur la colonne 'patho_niv2'
data_regression <- merge(data_clustering, data_maladie_preparation, by = "patho_niv2")

# Filtrage des clusters qui nous interessent pour la régression

data_regression <- data_regression[data_regression$cluster %in% c(2, 4), ]

#Selection des colonnes pour la régression
data_regression <- data_regression %>% select(-moyenne_cas, -moyenne_taux, -cluster)

# Création d'une liste pour stocker les résultats
results <- data.frame(
  Pathologie = character(),
  Prediction_LM = numeric(),
  Erreur_moyenne_LM = numeric(),
  Prediction_Tree = numeric(),
  Erreur_moyenne_Tree = numeric(),
  Prediction_RF = numeric(),
  Erreur_moyenne_RF = numeric(),
  stringsAsFactors = FALSE
)

pathologies <- unique(data_regression$patho_niv2)

set.seed(123)

# Pour chaque pathologie, on predit le nombre de personnes atteintes et on calcul l'erreur moyenne (racine de MSE) par modèle 
for (patho in pathologies) {
  
  data_patho <- filter(data_regression, patho_niv2 == patho)

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
    
    # Prédiction pour 2030
    new_data <- data.frame(annee = 2030, npop = 1000000)
    prediction_lm <- predict(lm_model, newdata = new_data)
    prediction_tree <- predict(tree_model, newdata = new_data)
    prediction_rf <- predict(rf_model, newdata = new_data)
    
    # Ajouter les résultats dans le dataframe
    results <- rbind(results, data.frame(
      Pathologie = patho,
      Prediction_LM = prediction_lm,
      Erreur_moyenne_LM = sqrt(mse_lm),
      Prediction_Tree = prediction_tree,
      Erreur_moyenne_Tree = sqrt(mse_tree),
      Prediction_RF = prediction_rf,
      Erreur_moyenne_RF = sqrt(mse_rf)
    ))
  }
}

print(results)



write.csv(results, "Data/resultats_prediction.csv", row.names = FALSE)
