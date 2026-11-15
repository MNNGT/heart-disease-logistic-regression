# Heart Disease Risk Factors – Multivariable Logistic Regression in R

**Epidemiological Data Analysis | R | Logistic Regression | Quarto | Reproducible Research**

## Project Overview

This project investigates associations between selected clinical characteristics and the presence of heart disease using the Cleveland Heart Disease dataset.

The analysis demonstrates a reproducible epidemiological workflow, including data preparation, multivariable logistic regression, adjusted odds ratios, model diagnostics, sensitivity analyses, and internal validation.

The results are presented in an English-language scientific report generated with R and Quarto.

## Objectives

- Explore and validate a cardiovascular health dataset.
- Fit a multivariable logistic regression model.
- Estimate adjusted odds ratios (ORs) and 95% confidence intervals.
- Assess influential observations using Cook's distance.
- Evaluate the robustness of model estimates.
- Assess discriminatory performance using the area under the ROC curve (AUC).
- Produce a reproducible scientific report.

## Data Source

**Dataset:** Cleveland Heart Disease  
**Source:** UCI Machine Learning Repository  
https://archive.ics.uci.edu/dataset/45/heart+disease

The dataset contains 303 observations and 14 original variables.

The original outcome variable was recoded into a binary indicator of heart disease (0 = absence; 1–4 = presence).

Missing values in `ca` and `thal` were identified and documented. Neither variable was included in the primary model.

## Statistical Methods

A multivariable logistic regression model was fitted using R's `glm()` function with a binomial family and logit link.

The explanatory variables included age, sex, resting blood pressure, cholesterol, fasting blood sugar status, maximum heart rate, and ST depression (`oldpeak`).

Model coefficients were exponentiated to obtain adjusted odds ratios and 95% confidence intervals.

Influential observations were investigated using Cook's distance, followed by an exploratory sensitivity analysis. Model discrimination was assessed using the apparent AUC and stratified five-fold cross-validation.

## Main Results

- **Sample size:** 303 patients
- **Heart disease cases:** 139 (45.9%)
- **Male sex:** adjusted OR = 5.69 (95% CI: 2.91–11.71)
- **Cholesterol:** adjusted OR = 1.007 (95% CI: 1.001–1.013)
- **Maximum heart rate:** adjusted OR = 0.963 (95% CI: 0.948–0.978)
- **ST depression:** adjusted OR = 1.90 (95% CI: 1.45–2.55)
- **Apparent AUC:** 0.839
- **Five-fold cross-validated AUC:** 0.823

An exploratory influence analysis identified 20 observations exceeding the Cook's distance screening threshold. The sensitivity model showed substantial changes in some estimates, particularly the association with male sex.

These results describe statistical associations and should not be interpreted as causal effects.

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

The analysis generates tables and figures under `outputs/`.

## Scientific Report

The complete report is available in `report.html`, generated from `report.qmd` with the Quarto **Flatly** theme.

It includes statistical methods, adjusted odds ratios, graphical diagnostics, ROC analysis, sensitivity analyses, interpretation and study limitations.

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

GitHub: https://github.com/MNNGT