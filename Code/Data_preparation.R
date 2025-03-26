
# Importation des données
data_maladie_effectifs <- read.csv("effectifs.csv", sep = ";")

# Selection des données des pathologies du finistere pour age et sexe confondu

data_maladie_effectifs_finistere <- data_maladie_effectifs[data_maladie_effectifs$dept == '29', ]
data_maladie_effectifs_finistere <- data_maladie_effectifs_finistere[data_maladie_effectifs_finistere$annee >= 2015 & data_maladie_effectifs_finistere$annee <= 2023, ]
data_maladie_effectifs_finistere <- data_maladie_effectifs_finistere[data_maladie_effectifs_finistere$cla_age_5 == 'tsage', ]
data_maladie_effectifs_finistere <- data_maladie_effectifs_finistere[data_maladie_effectifs_finistere$sexe == 9, ]
data_maladie_effectifs_finistere <- data_maladie_effectifs_finistere[!is.na(data_maladie_effectifs_finistere$patho_niv2), ]
data_maladie_effectifs_finistere <- data_maladie_effectifs_finistere[, c('annee', 'patho_niv2', 'ntop', 'npop')]

# Supprimer les valeurs des pathologies non intéressantes ou qui peuvent induire des biais dans les modèles :

data_maladie_effectifs_finistere <- data_maladie_effectifs_finistere[data_maladie_effectifs_finistere$patho_niv2 != 'Total consommants tous régimes', ]
data_maladie_effectifs_finistere <- data_maladie_effectifs_finistere[data_maladie_effectifs_finistere$patho_niv2 != 'Pas de pathologie repérée, traitement, maternité, hospitalisation ou traitement antalgique ou anti-inflammatoire', ]
data_maladie_effectifs_finistere <- data_maladie_effectifs_finistere[data_maladie_effectifs_finistere$patho_niv2 != '', ]


# On regroupe les données par année et par pathologie et on fait la somme des cas et de la population concernée
data_maladie_effectifs_finistere <- aggregate(cbind(ntop, npop) ~ annee + patho_niv2, data = data_maladie_effectifs_finistere, mean)

# On calcul un taux de prévalence pour chaque pathologie (nombre de cas / population concernée) et années
data_maladie_effectifs_finistere$prev <- data_maladie_effectifs_finistere$ntop / data_maladie_effectifs_finistere$npop

# On supprime la colonne de la population concernée
data_maladie_effectifs_finistere <- data_maladie_effectifs_finistere[, c('annee', 'patho_niv2','ntop', 'npop', 'prev')]


write.csv(data_maladie_effectifs_finistere, "data_maladie_effectifs_finistere.csv", row.names = TRUE)