**Langue / Language :** [Français](README.fr.md) | [English](README.md)

---

# Facteurs associés aux maladies cardiovasculaires – Régression logistique multivariable avec R

**Analyse de données épidémiologiques | R | Régression logistique | Quarto | R Shiny | Recherche reproductible**

## Explorer le projet


**📊 [Rapport scientifique – Français](https://mnngt.github.io/heart-disease-logistic-regression/report.fr.html)**

**📊 [Scientific Report – English](https://mnngt.github.io/heart-disease-logistic-regression/report.html)**

**🖥️ [Application interactive R Shiny – Français / English](https://mnngt-epi.shinyapps.io/heart-disease-logistic-explorer/)**


Le rapport scientifique présente les méthodes statistiques, les résultats et leur interprétation détaillée. Le tableau de bord interactif permet d'explorer les données, les performances du modèle et les analyses de sensibilité, grâce à une interface disponible **en français et en anglais**.

---

## Présentation du projet

Ce projet étudie les associations entre certaines caractéristiques cliniques et la présence d'une maladie cardiaque à partir du jeu de données *Cleveland Heart Disease*.

Il illustre une démarche reproductible d'analyse épidémiologique comprenant la préparation des données, une régression logistique multivariable, l'estimation d'odds ratios ajustés, les diagnostics du modèle, les analyses de sensibilité et la validation interne.

Le projet associe la programmation statistique avec **R**, la rédaction scientifique avec **Quarto** et la visualisation interactive avec **R Shiny**.

## Objectifs

- Explorer et contrôler la qualité d'un jeu de données cardiovasculaires.
- Ajuster un modèle de régression logistique multivariable.
- Estimer des odds ratios (OR) ajustés et leurs intervalles de confiance à 95 %.
- Identifier les observations influentes à l'aide de la distance de Cook.
- Évaluer la robustesse des estimations du modèle.
- Étudier la capacité de discrimination à l'aide de l'aire sous la courbe ROC (AUC).
- Produire un rapport scientifique reproductible et un tableau de bord statistique interactif.

## Source des données

**Jeu de données :** Cleveland Heart Disease  
**Source :** [UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/45/heart+disease)

Le jeu de données comprend **303 observations et 14 variables initiales**.

La variable de résultat initiale a été recodée en un indicateur binaire de présence d'une maladie cardiaque : **0 = absence ; valeurs initiales de 1 à 4 = présence**.

Des valeurs manquantes ont été identifiées et documentées dans les variables `ca` et `thal`. Aucune de ces deux variables n'a été incluse dans le modèle principal.

## Méthodes statistiques

Une régression logistique multivariable a été ajustée avec la fonction `glm()` de R, en utilisant une famille binomiale et une fonction de lien logit.

Les variables explicatives comprenaient l'âge, le sexe, la pression artérielle au repos, le cholestérol, le statut glycémique à jeun, la fréquence cardiaque maximale et le sous-décalage du segment ST (`oldpeak`).

Les coefficients du modèle ont été exponentiés afin d'obtenir les **odds ratios ajustés** et leurs **intervalles de confiance à 95 %**.

Les observations influentes ont été étudiées au moyen de la distance de Cook, puis une analyse de sensibilité exploratoire a été réalisée.

La capacité de discrimination du modèle a été évaluée à partir de l'AUC apparente et d'une **validation croisée stratifiée à cinq plis**.

## Principaux résultats

- **Effectif total :** 303 patients.
- **Patients présentant une maladie cardiaque :** 139 (45,9 %).
- **Sexe masculin :** OR ajusté = **5,69** (IC à 95 % : **2,91–11,71**).
- **Cholestérol :** OR ajusté = **1,007** (IC à 95 % : **1,001–1,013**).
- **Fréquence cardiaque maximale :** OR ajusté = **0,963** (IC à 95 % : **0,948–0,978**).
- **Sous-décalage du segment ST (`oldpeak`) :** OR ajusté = **1,90** (IC à 95 % : **1,45–2,55**).
- **AUC apparente :** **0,839**.
- **AUC après validation croisée à cinq plis :** **0,823**.

Une analyse exploratoire de l'influence a repéré **20 observations** dépassant le seuil de dépistage établi à partir de la distance de Cook.

Le modèle de sensibilité a mis en évidence des variations importantes de certaines estimations, particulièrement pour l'association avec le sexe masculin.

**Ces résultats décrivent des associations statistiques et ne doivent pas être interprétés comme des effets causaux.**

## Tableau de bord interactif R Shiny

Le tableau de bord permet d'explorer les données cardiovasculaires et les résultats des modèles statistiques à travers quatre composantes :

1. **Analyse exploratoire des données :** indicateurs épidémiologiques descriptifs et visualisations interactives.
2. **Régression logistique :** odds ratios ajustés, intervalles de confiance à 95 % et interprétation graphique.
3. **Performance du modèle :** courbes ROC, indicateurs d'AUC et performances de classification.
4. **Analyse de sensibilité :** diagnostics d'influence et comparaison des estimations des modèles.

L'application dispose d'une interface bilingue **français / anglais**.

**[Ouvrir l'application R Shiny](https://mnngt-epi.shinyapps.io/heart-disease-logistic-explorer/)**

## Rapport scientifique

Le rapport scientifique a été produit avec **R et Quarto**, en utilisant le thème **Flatly**.

Il présente les méthodes statistiques, les odds ratios ajustés, les diagnostics graphiques, l'analyse ROC, les analyses de sensibilité, l'interprétation des résultats et les limites de l'étude.

**[Lire le rapport scientifique complet (en anglais)](https://mnngt.github.io/heart-disease-logistic-regression/report.html)**

*Une version française du rapport Quarto est prévue ; ce lien pointe pour l'instant vers la version anglaise.*

## Structure du projet

```text
heart-disease-logistic-regression/
├── R/
│   └── analysis.R
├── data/
│   └── heart.csv
├── outputs/
│   ├── figures/
│   └── tables/
├── shiny/
│   ├── app.R
│   └── data/
├── report.qmd
├── report.html
├── README.md
└── README.fr.md
```

## Reproductibilité

Ouvrir **RStudio** et définir le dossier racine du projet comme répertoire de travail.

Exécuter l'analyse complète :

```r
source("R/analysis.R")
```

Générer le rapport scientifique :

```r
quarto::quarto_render("report.qmd")
```

Lancer le tableau de bord interactif :

```r
shiny::runApp("shiny")
```

L'analyse produit des tableaux et des figures dans le dossier `outputs/`.

## Limites

- Le jeu de données est de taille relativement limitée et provient d'un contexte clinique particulier.
- L'analyse est observationnelle et ne permet pas d'établir un lien de causalité.
- Certaines estimations du modèle sont sensibles aux observations influentes.
- La validation croisée à cinq plis constitue un seul exercice de validation interne.
- Une validation externe serait nécessaire avant d'envisager toute application clinique.

Ce projet a pour objectif de présenter des compétences en **programmation statistique** et en **recherche épidémiologique**. Il ne constitue **pas un outil d'aide à la décision clinique ni de diagnostic médical**.

## Autrice

**Marie-Noëlle Nogeant**  
Master en santé publique – Méthodes quantitatives et économétriques pour la recherche en santé (MQERS)  
Aix-Marseille Université

**GitHub :** [MNNGT](https://github.com/MNNGT)
