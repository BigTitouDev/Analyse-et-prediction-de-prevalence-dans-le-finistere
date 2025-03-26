# Analyse des pathologies se développant dans le Finistère et prédiction du nombre de cas pour l'année 2030

## 📌 Description du projet
Ce projet vise à analyser l'évolution des maladies en France à partir des données épidémiologiques issues de la base Ameli. L'objectif est d'identifier les pathologies ayant connu une augmentation significative de la prévalence entre 2015 et 2022 et de prévoir leur effectif en 2030.

## 🗂 Dataset utilisées
- **Source** : Pathologies : effectif de patients par pathologie, sexe, classe d'âge et territoire (département, région) - Data Ameli
- **Lien** : [https://data.ameli.fr/explore/dataset/effectifs/information/?refine.cla_age_5=tsage&refine.sexe=9&refine.region=99&refine.niveau_prioritaire=1](url)
- **Période couverte** : 2015 - 2022


## 🎯 Objectifs
1. **Analyser les tendances épidémiologiques** : Identifier les maladies avec une croissance marquée à l'aide du clustering et de la méthode des kmeans.
2. **Prédire l'évolution** : Estimer l'effectif des patients en 2030 en comparant différents algorithmes de regression.

## 🛠 Technologies utilisées
- **R** (dplyr, cluster, tidyverse, caret, randomForest, rpart)

## 📂 Structure du projet
```
📁 Analyse-et-prediction-de-prevalence-dans-le-finistere 
│── 📂 code   # Scripts d'analyse et modèles prédictifs
    │── 📄 Data_preparation.R  # Extraction et preparation des données
    │── 📄 Clustering.R  # Clustering des pathologies selon le taux d'augmentation de prevalence et du nombre de cas
    │── 📄 Regression.R  # Utilisation de différents modèles de regression pour prédire le nombre de cas en 2030
    │── 📂 data           # Données brutes et traitées
        │── 📊 data_maladie_effectifs_finistere.csv  # données issue de Amelie pour le département finistère
        │── 📊 data_preparation.csv  # Données issues de la partie data préparation
        │── 📊 data_clustering  # Données associant chaque pathologie a un cluster
│── README.md        # Documentation du projet
```

---
Titouan Cancouët & Elvan Duval
