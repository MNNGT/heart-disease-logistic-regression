# Heart Disease Logistic Regression - Reproducible Analysis
# Portfolio exercise based on the UCI Cleveland Heart Disease dataset.
# Data source and terms of reuse must be acknowledged in the README.
# Run from the project root: source("R/analysis.R")

# 0. Check project setup -----------------------------------------------------
if (!file.exists("data/heart.csv")) {
  stop("Cannot find data/heart.csv. Set RStudio's working directory to the project root.")
}
if (!requireNamespace("ggplot2", quietly = TRUE)) {
  stop("Package 'ggplot2' is required. Install it using install.packages('ggplot2').")
}

dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)

# 1. Import and validate data -----------------------------------------------
heart <- read.csv("data/heart.csv", na.strings = c("NA", "?", ""),
                  stringsAsFactors = FALSE)
required <- c("age", "sex", "cp", "trestbps", "chol", "fbs", "restecg",
              "thalach", "exang", "oldpeak", "slope", "ca", "thal", "target")
if (!all(required %in% names(heart))) {
  stop("Unexpected dataset columns: required Cleveland variables are missing.")
}
if (anyNA(heart$target) || !all(heart$target %in% 0:4)) {
  stop("Unexpected target coding. Expected integer categories 0, 1, 2, 3, 4.")
}
if (!all(na.omit(heart$sex) %in% c(0, 1)) ||
    !all(na.omit(heart$fbs) %in% c(0, 1))) {
  stop("Unexpected sex or fbs coding; expected 0 and 1.")
}

# The Cleveland 'num/target' variable is 0 (no disease) or 1-4 (disease).
heart$heart_disease <- as.integer(heart$target > 0)
heart$ca <- as.numeric(heart$ca)
heart$thal <- factor(heart$thal)
heart$sex <- factor(heart$sex, levels = c(0, 1),
                    labels = c("Female", "Male"))
heart$fbs <- factor(heart$fbs, levels = c(0, 1),
                    labels = c("No", "Yes"))

model_vars <- c("heart_disease", "age", "sex", "trestbps", "chol",
                "fbs", "thalach", "oldpeak")
heart_model <- heart[, model_vars]
if (!all(complete.cases(heart_model))) {
  stop("Some model variables have missing data. Review the analysis plan before fitting.")
}

quality <- data.frame(variable = names(heart),
                      missing_n = vapply(heart, function(x) sum(is.na(x)), integer(1)))
write.csv(quality, "outputs/tables/data_quality.csv", row.names = FALSE)

target_summary <- as.data.frame(table(heart_model$heart_disease))
names(target_summary) <- c("heart_disease", "n")
target_summary$percent <- round(100 * target_summary$n / nrow(heart_model), 1)
write.csv(target_summary, "outputs/tables/outcome_summary.csv", row.names = FALSE)

# 2. Main multivariable logistic regression ---------------------------------
model_logit <- glm(
  heart_disease ~ age + sex + trestbps + chol + fbs + thalach + oldpeak,
  data = heart_model,
  family = binomial(link = "logit")
)

# Profile-likelihood intervals (same method as confint(model_logit)).
make_or_table <- function(model) {
  sm <- summary(model)$coefficients
  ci <- suppressMessages(confint(model))
  data.frame(
    variable = rownames(sm),
    beta = unname(sm[, "Estimate"]),
    std_error = unname(sm[, "Std. Error"]),
    p_value = unname(sm[, "Pr(>|z|)"]),
    OR = unname(exp(sm[, "Estimate"])),
    CI95_low = unname(exp(ci[, 1])),
    CI95_high = unname(exp(ci[, 2])),
    row.names = NULL
  )
}

primary_or <- make_or_table(model_logit)
write.csv(primary_or, "outputs/tables/primary_odds_ratios.csv", row.names = FALSE)

# 3. Influence diagnostics and exploratory sensitivity -----------------------
cook <- cooks.distance(model_logit)
cook_threshold <- 4 / nobs(model_logit)
flag <- cook > cook_threshold
influence_tbl <- data.frame(
  row_number = seq_along(cook),
  cooks_distance = as.numeric(cook),
  exceeds_4_over_n = as.logical(flag)
)
write.csv(influence_tbl, "outputs/tables/influence_diagnostics.csv",
          row.names = FALSE)

# These exclusions are exploratory, NOT a correction or preferred model.
model_sens <- glm(formula(model_logit), data = heart_model[!flag, , drop = FALSE],
                  family = binomial(link = "logit"))
sensitivity_or <- make_or_table(model_sens)
write.csv(sensitivity_or, "outputs/tables/sensitivity_odds_ratios.csv",
          row.names = FALSE)

or_comparison <- merge(
  primary_or[, c("variable", "OR", "CI95_low", "CI95_high")],
  sensitivity_or[, c("variable", "OR", "CI95_low", "CI95_high")],
  by = "variable", suffixes = c("_primary", "_sensitivity"), sort = FALSE
)
write.csv(or_comparison, "outputs/tables/or_comparison.csv", row.names = FALSE)

# 4. AUC calculation (Mann-Whitney/rank approach) ----------------------------
auc_rank <- function(labels, scores) {
  stopifnot(length(labels) == length(scores), !anyNA(labels), !anyNA(scores))
  n1 <- sum(labels == 1L)
  n0 <- sum(labels == 0L)
  if (n1 == 0L || n0 == 0L) stop("Both outcome classes must be present.")
  (sum(rank(scores)[labels == 1L]) - n1 * (n1 + 1) / 2) / (n1 * n0)
}

pred_apparent <- predict(model_logit, type = "response")
auc_apparent <- auc_rank(heart_model$heart_disease, pred_apparent)

# Single stratified five-fold cross-validation, reproducing the earlier code.
set.seed(2026)
folds <- integer(nrow(heart_model))
for (classe in 0:1) {
  idx <- which(heart_model$heart_disease == classe)
  folds[idx] <- sample(rep(1:5, length.out = length(idx)))
}
pred_cv <- rep(NA_real_, nrow(heart_model))
for (k in 1:5) {
  model_cv <- glm(formula(model_logit),
                  data = heart_model[folds != k, , drop = FALSE],
                  family = binomial(link = "logit"))
  pred_cv[folds == k] <- predict(
    model_cv,
    newdata = heart_model[folds == k, , drop = FALSE],
    type = "response"
  )
}
stopifnot(!anyNA(pred_cv))
auc_cv <- auc_rank(heart_model$heart_disease, pred_cv)

metrics <- data.frame(
  metric = c("n_primary", "n_sensitivity", "n_flagged_cook",
             "cook_threshold", "auc_apparent", "auc_cv_5fold"),
  value = c(nrow(heart_model), nobs(model_sens), sum(flag), cook_threshold,
            auc_apparent, auc_cv)
)
write.csv(metrics, "outputs/tables/model_metrics.csv", row.names = FALSE)

prediction_tbl <- data.frame(
  row_number = seq_len(nrow(heart_model)),
  observed = heart_model$heart_disease,
  fold = folds,
  predicted_apparent = as.numeric(pred_apparent),
  predicted_cv = as.numeric(pred_cv)
)
write.csv(prediction_tbl, "outputs/tables/cross_validation_predictions.csv",
          row.names = FALSE)

# 5. Scientific figures ------------------------------------------------------
library(ggplot2)

forest <- subset(primary_or, variable != "(Intercept)")
forest$variable <- factor(forest$variable, levels = rev(forest$variable))
p_forest <- ggplot(forest, aes(x = OR, y = variable)) +
  geom_vline(xintercept = 1, linetype = "dashed", color = "gray50") +
  geom_pointrange(aes(xmin = CI95_low, xmax = CI95_high)) +
  scale_x_log10() +
  labs(title = "Adjusted associations with heart disease",
       subtitle = "Main model (n = 303), 95% profile-likelihood confidence intervals",
       x = "Adjusted odds ratio (log scale)", y = NULL) +
  theme_minimal(base_size = 12)
ggsave("outputs/figures/forest_plot.png", p_forest, width = 9, height = 5, dpi = 160)

p_cook <- ggplot(influence_tbl, aes(x = row_number, y = cooks_distance)) +
  geom_col(width = 0.9) +
  geom_hline(yintercept = cook_threshold, linetype = "dashed", color = "firebrick") +
  labs(title = "Influence diagnostics: Cook's distance",
       subtitle = "Dashed line: exploratory 4/n threshold",
       x = "Observation number", y = "Cook's distance") +
  theme_minimal(base_size = 12)
ggsave("outputs/figures/cooks_distance.png", p_cook, width = 9, height = 4.5, dpi = 160)

# ROC curve from out-of-fold predictions (internal validation, not external).
thresholds <- c(Inf, sort(unique(pred_cv), decreasing = TRUE), -Inf)
roc <- data.frame(threshold = thresholds)
roc$tpr <- vapply(thresholds, function(t) {
  mean(pred_cv[heart_model$heart_disease == 1L] >= t)
}, numeric(1))
roc$fpr <- vapply(thresholds, function(t) {
  mean(pred_cv[heart_model$heart_disease == 0L] >= t)
}, numeric(1))
write.csv(roc, "outputs/tables/cv_roc_points.csv", row.names = FALSE)

p_roc <- ggplot(roc, aes(x = fpr, y = tpr)) +
  geom_line(linewidth = 1) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray50") +
  coord_equal(xlim = c(0, 1), ylim = c(0, 1)) +
  labs(title = "5-fold cross-validated ROC curve",
       subtitle = sprintf("Out-of-fold AUC = %.3f (single stratified split)", auc_cv),
       x = "False positive rate (1 - specificity)",
       y = "True positive rate (sensitivity)") +
  theme_minimal(base_size = 12)
ggsave("outputs/figures/cv_roc_curve.png", p_roc, width = 6.5, height = 6, dpi = 160)

# 6. Console summary ---------------------------------------------------------
cat("\n=== Data quality ===\n")
print(quality)
cat("\n=== Main adjusted odds ratios (95% CI) ===\n")
print(primary_or[, c("variable", "OR", "CI95_low", "CI95_high", "p_value")],
      digits = 4, row.names = FALSE)
cat("\n=== Influence and validation ===\n")
cat(sprintf("Main model n = %d; Cook flagged = %d; sensitivity n = %d\n",
            nobs(model_logit), sum(flag), nobs(model_sens)))
cat(sprintf("Apparent AUC = %.3f; five-fold CV AUC = %.3f\n",
            auc_apparent, auc_cv))
cat("\nOutputs saved under outputs/tables and outputs/figures.\n")
cat("Interpretation: associations, not causal effects; CV is internal only.\n")
