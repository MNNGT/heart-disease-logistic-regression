
**Language / Langue:** [English](README.md) | [Français](README.fr.md)

---

# Heart Disease Risk Factors – Multivariable Logistic Regression in R

**Epidemiological Data Analysis | R | Logistic Regression | Quarto | R Shiny | Reproducible Research**

## Explore the Project

**📊 [Scientific Report – English](https://mnngt.github.io/heart-disease-logistic-regression/report.html)**

**📊 [Rapport scientifique – Français](https://mnngt.github.io/heart-disease-logistic-regression/report.fr.html)**

**🖥️ [Interactive R Shiny Dashboard – English / Français](https://mnngt-epi.shinyapps.io/heart-disease-logistic-explorer/)**


The scientific report provides a detailed interpretation of the statistical methods and results. The interactive dashboard offers exploratory visualizations, model performance metrics, and sensitivity analyses, with an interface available in **English and French**.

---

## Project Overview

This project investigates associations between selected clinical characteristics and the presence of heart disease using the Cleveland Heart Disease dataset.

The analysis demonstrates a reproducible epidemiological workflow, including data preparation, multivariable logistic regression, adjusted odds ratios, model diagnostics, sensitivity analyses, and internal validation.

The project combines statistical programming in R, scientific reporting with Quarto, and interactive visualization with R Shiny.

## Objectives

- Explore and validate a cardiovascular health dataset.
- Fit a multivariable logistic regression model.
- Estimate adjusted odds ratios (ORs) and 95% confidence intervals.
- Assess influential observations using Cook's distance.
- Evaluate the robustness of model estimates.
- Assess discriminatory performance using the area under the ROC curve (AUC).
- Produce a reproducible scientific report and an interactive statistical dashboard.

## Data Source

**Dataset:** Cleveland Heart Disease  
**Source:** [UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/45/heart+disease)

The dataset contains 303 observations and 14 original variables.

The original outcome variable was recoded into a binary indicator of heart disease (0 = absence; 1–4 = presence).

Missing values in `ca` and `thal` were identified and documented. Neither variable was included in the primary model.

## Statistical Methods

A multivariable logistic regression model was fitted using R's `glm()` function with a binomial family and logit link.

The explanatory variables included age, sex, resting blood pressure, cholesterol, fasting blood sugar status, maximum heart rate, and ST depression (`oldpeak`).

Model coefficients were exponentiated to obtain adjusted odds ratios and 95% confidence intervals.

Influential observations were investigated using Cook's distance, followed by an exploratory sensitivity analysis.

Model discrimination was assessed using the apparent AUC and stratified five-fold cross-validation.

## Main Results

- **Sample size:** 303 patients
- **Heart disease cases:** 139 (45.9%)
- **Male sex:** adjusted OR = 5.69 (95% CI: 2.91–11.71)
- **Cholesterol:** adjusted OR = 1.007 (95% CI: 1.001–1.013)
- **Maximum heart rate:** adjusted OR = 0.963 (95% CI: 0.948–0.978)
- **ST depression:** adjusted OR = 1.90 (95% CI: 1.45–2.55)
- **Apparent AUC:** 0.839
- **Five-fold cross-validated AUC:** 0.823

An exploratory influence analysis identified 20 observations exceeding the Cook's distance screening threshold.

The sensitivity model showed substantial changes in some estimates, particularly the association with male sex.

These results describe statistical associations and should not be interpreted as causal effects.

## Interactive R Shiny Dashboard

The dashboard allows users to explore the cardiovascular dataset and statistical models through four analytical components:

1. **Exploratory Data Analysis:** Descriptive epidemiological indicators and interactive visualizations.
2. **Logistic Regression:** Adjusted odds ratios, 95% confidence intervals, and graphical interpretation.
3. **Model Performance:** ROC analysis, AUC metrics, and classification performance.
4. **Sensitivity Analysis:** Influence diagnostics and comparison of model estimates.

The application includes a bilingual **English / French** interface.

**[Launch the R Shiny Dashboard](https://mnngt-epi.shinyapps.io/heart-disease-logistic-explorer/)**

## Scientific Report

The full scientific report was generated using R and Quarto with the Flatly theme.

It includes statistical methods, adjusted odds ratios, graphical diagnostics, ROC analysis, sensitivity analyses, interpretation, and study limitations.

**[Read the Full Scientific Report](https://mnngt.github.io/heart-disease-logistic-regression/report.html)**

## Project Structure

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
└── README.md
```

## Reproducibility

Open RStudio and set the working directory to the project root.

Run the complete analysis:

`source("R/analysis.R")`

Generate the scientific report:

`quarto::quarto_render("report.qmd")`

Launch the interactive dashboard:

`shiny::runApp("shiny")`

The analysis generates tables and figures under `outputs/`.

## Limitations

- The dataset is relatively small and comes from a specific clinical setting.
- The analysis is observational and cannot establish causality.
- Some model estimates are sensitive to influential observations.
- The five-fold cross-validation is a single internal validation exercise.
- External validation would be required before considering clinical applications.

This project is intended to demonstrate statistical programming and epidemiological research skills. It is not a clinical decision-support tool.

## Author

**Marie-Noëlle Nogeant**  
MSc Public Health – Quantitative and Econometric Methods for Health Research  
Aix-Marseille University

**GitHub:** https://github.com/MNNGT
