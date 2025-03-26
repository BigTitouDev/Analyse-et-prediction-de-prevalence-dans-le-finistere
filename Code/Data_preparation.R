
# Importation des données
data_maladie_effectifs <- read.csv("Data/data_maladie_effectifs_finistere.csv", sep = ",")

# Selection des données des pathologies du finistere pour age et sexe confondu

data_maladie_preparation <- data_maladie_effectifs[data_maladie_effectifs$annee >= 2015 & data_maladie_effectifs$annee <= 2023, ]
data_maladie_preparation <- data_maladie_preparation[data_maladie_preparation$cla_age_5 == 'tsage', ]
data_maladie_preparation <- data_maladie_preparation[data_maladie_preparation$sexe == 9, ]
data_maladie_preparation <- data_maladie_preparation[!is.na(data_maladie_preparation$patho_niv2), ]
data_maladie_preparation <- data_maladie_preparation[, c('annee', 'patho_niv2', 'ntop', 'npop')]

# Supprimer les valeurs des pathologies non intéressantes ou qui peuvent induire des biais dans les modèles :

data_maladie_preparation <- data_maladie_preparation[data_maladie_preparation$patho_niv2 != 'Total consommants tous régimes', ]
data_maladie_preparation <- data_maladie_preparation[data_maladie_preparation$patho_niv2 != 'Pas de pathologie repérée, traitement, maternité, hospitalisation ou traitement antalgique ou anti-inflammatoire', ]
data_maladie_preparation <- data_maladie_preparation[data_maladie_preparation$patho_niv2 != '', ]


# On regroupe les données par année et par pathologie et on fait la somme des cas et de la population concernée
data_maladie_preparation <- aggregate(cbind(ntop, npop) ~ annee + patho_niv2, data = data_maladie_preparation, mean)

# On calcul un taux de prévalence pour chaque pathologie (nombre de cas / population concernée) et années
data_maladie_preparation$prev <- data_maladie_preparation$ntop / data_maladie_preparation$npop

# On supprime la colonne de la population concernée
data_maladie_preparation <- data_maladie_preparation[, c('annee', 'patho_niv2','ntop', 'npop', 'prev')]


write.csv(data_maladie_preparation, "Data/data_maladie_preparation.csv", row.names = FALSE)