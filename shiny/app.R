# Heart Disease – Logistic Regression Explorer
# Bilingual (English / French) R Shiny portfolio application.
# Data: UCI Cleveland Heart Disease dataset; 303 observations.
# Analyses and outputs: R/analysis.R in the parent GitHub project.
# Run from the shiny/ folder: shiny::runApp('.')
# This is a statistical teaching demonstration, not a clinical diagnostic tool.

library(shiny)
library(ggplot2)

# --- Load the same data and output tables as the scientific report ------------
required_files <- c(
  "heart.csv", "primary_odds_ratios.csv", "sensitivity_odds_ratios.csv",
  "cross_validation_predictions.csv", "influence_diagnostics.csv",
  "model_metrics.csv"
)
missing_files <- required_files[!file.exists(file.path("data", required_files))]
if (length(missing_files)) {
  stop(
    "Missing application data files in shiny/data/: ",
    paste(missing_files, collapse = ", "),
    ". Copy them from the project's data/ and outputs/tables/ folders."
  )
}

heart <- read.csv("data/heart.csv", na.strings = c("?", "NA", ""))
primary <- read.csv("data/primary_odds_ratios.csv", stringsAsFactors = FALSE)
sensitivity <- read.csv("data/sensitivity_odds_ratios.csv", stringsAsFactors = FALSE)
pred <- read.csv("data/cross_validation_predictions.csv")
influence <- read.csv("data/influence_diagnostics.csv")
metrics <- read.csv("data/model_metrics.csv")

stopifnot(
  all(c("age", "sex", "trestbps", "chol", "thalach", "oldpeak", "target") %in% names(heart)),
  all(c("variable", "OR", "CI95_low", "CI95_high", "p_value") %in% names(primary)),
  all(c("variable", "OR", "CI95_low", "CI95_high", "p_value") %in% names(sensitivity)),
  all(c("row_number", "observed", "predicted_apparent", "predicted_cv") %in% names(pred)),
  all(c("row_number", "cooks_distance", "exceeds_4_over_n") %in% names(influence)),
  all(c("metric", "value") %in% names(metrics)),
  nrow(heart) == nrow(pred),
  nrow(heart) == nrow(influence),
  all(heart$target %in% 0:4),
  all(pred$observed %in% 0:1),
  all(pred$predicted_cv >= 0 & pred$predicted_cv <= 1)
)
heart$heart_disease <- as.integer(heart$target > 0)
stopifnot(identical(as.integer(heart$heart_disease), as.integer(pred$observed)))

metric <- function(key) {
  value <- metrics$value[metrics$metric == key]
  if (length(value) != 1L) stop("Missing model metric: ", key)
  as.numeric(value)
}
auc_app <- metric("auc_apparent")
auc_cv <- metric("auc_cv_5fold")
cook_threshold <- metric("cook_threshold")

# Compute the empirical ROC directly from existing out-of-fold predictions.
roc_points <- function(outcomes, probabilities) {
  cuts <- c(Inf, sort(unique(probabilities), decreasing = TRUE), -Inf)
  data.frame(
    threshold = cuts,
    fpr = vapply(cuts, function(t) mean(probabilities[outcomes == 0L] >= t), numeric(1)),
    tpr = vapply(cuts, function(t) mean(probabilities[outcomes == 1L] >= t), numeric(1))
  )
}
roc_cv <- roc_points(pred$observed, pred$predicted_cv)

dictionary <- list(
  en = list(
    title = "Heart Disease · Logistic Regression Explorer",
    subtitle = "A reproducible epidemiological analysis built with R and Shiny",
    language = "Language", overview = "Overview", regression = "Regression",
    performance = "Model performance", diagnostics = "Influence & sensitivity",
    notice = "Educational statistical analysis only — not for clinical diagnosis, screening, or patient care.",
    size = "Observations", outcome_yes = "With heart disease", outcome_no = "Without heart disease",
    app_auc = "Apparent AUC", cv_auc = "5-fold CV AUC",
    outcome_chart = "Outcome distribution", outcome_x = "Heart disease status",
    count_y = "Number of observations", yes = "Present", no = "Absent",
    variable = "Explore a numeric variable", distribution = "Distribution by outcome",
    age = "Age (years)", trestbps = "Resting blood pressure (mmHg)",
    chol = "Serum cholesterol (mg/dL)", thalach = "Maximum heart rate (bpm)",
    oldpeak = "ST depression (oldpeak)",
    model = "Displayed model", main = "Main model (n = 303)",
    sens = "Sensitivity analysis (n = 283)", compare = "Compare both models",
    forest = "Adjusted odds ratios and 95% confidence intervals",
    or_axis = "Adjusted odds ratio (log scale)",
    term = "Predictor", or_col = "Adjusted OR", low = "95% CI lower", high = "95% CI upper", p = "p-value",
    note_or = "Odds ratios represent adjusted associations, not causal effects. Confidence intervals are profile-likelihood intervals.",
    threshold = "Classification threshold", curve = "ROC curve · Out-of-fold predictions",
    x_roc = "False positive rate (1 − specificity)", y_roc = "True positive rate (sensitivity)",
    sensitivity_metric = "Sensitivity", specificity = "Specificity", precision = "Precision",
    positives = "True positives", negatives = "True negatives", false_pos = "False positives", false_neg = "False negatives",
    validation = "AUC values summarize discrimination. The 5-fold estimate uses one stratified internal split; external validation has not been performed.",
    cook = "Cook's distance for individual observations", cook_x = "Observation number", cook_y = "Cook's distance",
    flagged = "Observations flagged (> 4/n)", retained = "Observations retained in sensitivity analysis",
    sensitivity_note = "Excluding influential observations is exploratory, not a correction or a preferred model. Large changes in estimates indicate instability and possible selection bias.",
    source = "Source: UCI Cleveland Heart Disease dataset. Outcome is presence of disease in this dataset, not future cardiovascular risk.",
    link = "Scientific Quarto report", missing = "Missing values in non-model fields",
    rows = "Rows", patients = "Observations", info = "About this dashboard"
  ),
  fr = list(
    title = "Maladies cardiovasculaires · Exploration de la régression logistique",
    subtitle = "Analyse épidémiologique reproductible réalisée avec R et Shiny",
    language = "Langue", overview = "Vue d'ensemble", regression = "Régression",
    performance = "Performance du modèle", diagnostics = "Influence et sensibilité",
    notice = "Démonstration statistique pédagogique uniquement — ne convient ni au diagnostic, ni au dépistage, ni à la prise en charge médicale.",
    size = "Observations", outcome_yes = "Avec maladie cardiaque", outcome_no = "Sans maladie cardiaque",
    app_auc = "AUC apparente", cv_auc = "AUC validation croisée (5 plis)",
    outcome_chart = "Répartition des événements", outcome_x = "Présence de maladie cardiaque",
    count_y = "Nombre d'observations", yes = "Présente", no = "Absente",
    variable = "Explorer une variable quantitative", distribution = "Distribution selon l'événement",
    age = "Âge (années)", trestbps = "Pression artérielle au repos (mmHg)",
    chol = "Cholestérol sérique (mg/dL)", thalach = "Fréquence cardiaque maximale (bpm)",
    oldpeak = "Sous-décalage ST (oldpeak)",
    model = "Modèle affiché", main = "Modèle principal (n = 303)",
    sens = "Analyse de sensibilité (n = 283)", compare = "Comparer les deux modèles",
    forest = "Odds ratios ajustés et intervalles de confiance à 95 %",
    or_axis = "Odds ratio ajusté (échelle logarithmique)",
    term = "Variable", or_col = "OR ajusté", low = "Borne IC 95 %", high = "Borne IC 95 %", p = "Valeur p",
    note_or = "Les odds ratios représentent des associations ajustées, non des effets causaux. Les intervalles de confiance sont obtenus par vraisemblance profilée.",
    threshold = "Seuil de classification", curve = "Courbe ROC · Prédictions hors échantillon d'entraînement",
    x_roc = "Taux de faux positifs (1 − spécificité)", y_roc = "Taux de vrais positifs (sensibilité)",
    sensitivity_metric = "Sensibilité", specificity = "Spécificité", precision = "Valeur prédictive positive",
    positives = "Vrais positifs", negatives = "Vrais négatifs", false_pos = "Faux positifs", false_neg = "Faux négatifs",
    validation = "L'AUC mesure la discrimination. La validation croisée utilise un seul découpage stratifié à 5 plis ; aucune validation externe n'a été réalisée.",
    cook = "Distance de Cook pour chaque observation", cook_x = "Numéro de l'observation", cook_y = "Distance de Cook",
    flagged = "Observations signalées (> 4/n)", retained = "Observations conservées dans l'analyse de sensibilité",
    sensitivity_note = "L'exclusion des observations influentes est exploratoire, et ne constitue ni une correction ni un modèle préférable. De fortes variations suggèrent une instabilité des estimations et un possible biais de sélection.",
    source = "Source : jeu de données Cleveland Heart Disease (UCI). La variable étudiée représente la présence de la maladie dans ce jeu de données, et non un risque cardiovasculaire futur.",
    link = "Rapport scientifique Quarto", missing = "Valeurs manquantes hors variables du modèle",
    rows = "Lignes", patients = "Observations", info = "À propos de ce tableau de bord"
  )
)

plot_theme <- theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold", colour = "#17324d"),
        panel.grid.minor = element_blank(),
        legend.position = "bottom")
palette <- c("0" = "#256d85", "1" = "#d47b39")

ui <- fluidPage(
  tags$head(tags$style(HTML("\n    body { background: #f5f8fa; color: #17324d; }\n    .app-header { background: #17324d; color: white; padding: 22px 26px;\n                  border-radius: 12px; margin: 14px 0 18px 0; }\n    .app-header h2 { margin: 0 0 6px 0; font-weight: 700; font-size: 26px; }\n    .app-header p { margin: 0; opacity: .86; }\n    .stat-box { background: white; border-radius: 10px; padding: 14px 18px;\n                box-shadow: 0 1px 4px rgba(0,0,0,.07); margin-bottom: 14px; }\n    .stat-box .value { font-size: 29px; font-weight: 700; color: #17324d; }\n    .stat-box .label { font-size: 12px; color: #66788a; line-height: 1.5; }\n    .panel-lite { background: white; border-radius: 10px; padding: 18px;\n                  box-shadow: 0 1px 4px rgba(0,0,0,.05); margin-bottom: 18px; }\n    .alert-info-custom { border-left: 4px solid #b67828; padding: 12px 15px;\n                         background: #fff6e9; margin: 18px 0; border-radius: 4px; }\n    .nav-tabs > li.active > a { color: #17324d; font-weight: 700; }\n    .well { background: white; border: none; box-shadow: none; }\n    .footer { margin: 18px 0 24px; color: #66788a; font-size: 12px; }\n  "))),
  fluidRow(
    column(9, uiOutput("header_ui")),
    column(3, div(style = "padding-top: 22px;",
                  selectInput("lang", "Language / Langue",
                              choices = c("English" = "en", "Français" = "fr"),
                              selected = "en", width = "100%")))
  ),
  uiOutput("notice_ui"),
  uiOutput("tabs_ui"),
  tags$div(class = "footer", uiOutput("footer_ui"))
)

server <- function(input, output, session) {
  tr <- reactive(dictionary[[input$lang]])

  outcome_labels <- reactive(c("0" = tr()$no, "1" = tr()$yes))

  output$header_ui <- renderUI({
    d <- tr()
    tags$div(class = "app-header", tags$h2(d$title), tags$p(d$subtitle))
  })
  output$notice_ui <- renderUI({
    tags$div(class = "alert-info-custom", tr()$notice)
  })
  output$footer_ui <- renderUI({
    tags$div(tr()$source, " · ",
             tags$a(href = "https://mnngt.github.io/heart-disease-logistic-regression/report.html",
                    target = "_blank", tr()$link))
  })

  stat_box <- function(label, value) {
    tags$div(class = "stat-box", tags$div(class = "value", value),
             tags$div(class = "label", label))
  }

  output$tabs_ui <- renderUI({
    d <- tr()
    tabsetPanel(id = "section",
      tabPanel(d$overview,
        br(),
        fluidRow(
          column(3, stat_box(d$size, nrow(heart))),
          column(3, stat_box(d$outcome_yes, sum(heart$heart_disease == 1L))),
          column(3, stat_box(d$outcome_no, sum(heart$heart_disease == 0L))),
          column(3, stat_box(d$cv_auc, sprintf("%.3f", auc_cv)))
        ),
        fluidRow(
          column(5, div(class = "panel-lite", h4(d$outcome_chart),
                        plotOutput("outcome_plot", height = "310px"))),
          column(7, div(class = "panel-lite",
                        selectInput("explore_var", d$variable,
                                    choices = setNames(c("age", "trestbps", "chol", "thalach", "oldpeak"),
                                                       c(d$age, d$trestbps, d$chol, d$thalach, d$oldpeak)),
                                    selected = "age"),
                        plotOutput("distribution_plot", height = "300px")))
        )
      ),
      tabPanel(d$regression,
        br(),
        fluidRow(
          column(4, div(class = "panel-lite",
                        selectInput("model_view", d$model,
                                    choices = setNames(c("primary", "sensitivity", "compare"),
                                                       c(d$main, d$sens, d$compare)),
                                    selected = "primary"),
                        p(d$note_or))),
          column(8, div(class = "panel-lite", h4(d$forest),
                        plotOutput("forest_plot", height = "440px")))
        ),
        div(class = "panel-lite", tableOutput("or_table"))
      ),
      tabPanel(d$performance,
        br(),
        fluidRow(
          column(3, stat_box(d$app_auc, sprintf("%.3f", auc_app))),
          column(3, stat_box(d$cv_auc, sprintf("%.3f", auc_cv))),
          column(6, div(class = "panel-lite",
                        sliderInput("threshold", d$threshold,
                                    min = 0, max = 1, value = 0.5, step = 0.01)))
        ),
        fluidRow(
          column(7, div(class = "panel-lite", h4(d$curve),
                        plotOutput("roc_plot", height = "415px"))),
          column(5, div(class = "panel-lite", h4(d$performance),
                        tableOutput("classification_table"),
                        p(d$validation)))
        )
      ),
      tabPanel(d$diagnostics,
        br(),
        fluidRow(
          column(3, stat_box(d$flagged, metric("n_flagged_cook"))),
          column(3, stat_box(d$retained, metric("n_sensitivity"))),
          column(6, div(class = "panel-lite", p(d$sensitivity_note)))
        ),
        div(class = "panel-lite", h4(d$cook), plotOutput("cook_plot", height = "360px")),
        div(class = "panel-lite", h4(d$forest), plotOutput("sensitivity_plot", height = "500px"))
      )
    )
  })

  output$outcome_plot <- renderPlot({
    d <- tr()
    counts <- as.data.frame(table(factor(heart$heart_disease, levels = 0:1)))
    names(counts) <- c("status", "n")
    ggplot(counts, aes(status, n, fill = status)) +
      geom_col(width = .62, show.legend = FALSE) +
      geom_text(aes(label = n), vjust = -0.5, size = 5) +
      scale_fill_manual(values = palette) +
      scale_x_discrete(labels = outcome_labels()) +
      scale_y_continuous(expand = expansion(mult = c(0, .15))) +
      labs(x = d$outcome_x, y = d$count_y) + plot_theme
  })

  output$distribution_plot <- renderPlot({
    req(input$explore_var)
    d <- tr()
    validate(need(input$explore_var %in% c("age", "trestbps", "chol", "thalach", "oldpeak"),
                  "Unknown variable"))
    dat <- data.frame(value = as.numeric(heart[[input$explore_var]]),
                      status = factor(heart$heart_disease, levels = 0:1))
    ggplot(dat, aes(value, fill = status)) +
      geom_histogram(position = "identity", bins = 18, alpha = .55, colour = "white") +
      scale_fill_manual(values = palette, labels = outcome_labels()) +
      labs(x = unname(c(age = d$age, trestbps = d$trestbps, chol = d$chol,
                        thalach = d$thalach, oldpeak = d$oldpeak)[[input$explore_var]]),
           y = d$count_y, fill = d$outcome_x) + plot_theme
  })

  display_or <- reactive({
    req(input$model_view)
    make_df <- function(df, group) {
      df <- df[df$variable != "(Intercept)", , drop = FALSE]
      df$model <- group
      df
    }
    if (input$model_view == "primary") return(make_df(primary, tr()$main))
    if (input$model_view == "sensitivity") return(make_df(sensitivity, tr()$sens))
    rbind(make_df(primary, tr()$main), make_df(sensitivity, tr()$sens))
  })

  forest_plot_fn <- function(dat, comparison = FALSE) {
    d <- tr()
    dat$variable <- factor(dat$variable, levels = rev(unique(primary$variable[primary$variable != "(Intercept)"])))
    p <- ggplot(dat, aes(x = OR, y = variable)) +
      geom_vline(xintercept = 1, linetype = "dashed", colour = "#8192a0") +
      geom_pointrange(aes(xmin = CI95_low, xmax = CI95_high), colour = "#1d7690") +
      scale_x_log10() +
      labs(x = d$or_axis, y = NULL) + plot_theme
    if (comparison) p <- p + facet_wrap(~ model, ncol = 1, scales = "free_x")
    p
  }

  output$forest_plot <- renderPlot({
    req(input$model_view)
    forest_plot_fn(display_or(), input$model_view == "compare")
  })
  output$or_table <- renderTable({
    d <- tr()
    data <- display_or()
    out <- data.frame(
      Variable = data$variable,
      OR = round(data$OR, 3),
      CI_low = round(data$CI95_low, 3),
      CI_high = round(data$CI95_high, 3),
      p = signif(data$p_value, 3), check.names = FALSE
    )
    names(out) <- c(d$term, d$or_col, d$low, d$high, d$p)
    if (input$model_view == "compare") out[[d$model]] <- data$model
    out
  }, striped = TRUE, bordered = FALSE, spacing = "s")

  confusion <- reactive({
    req(input$threshold)
    predicted <- as.integer(pred$predicted_cv >= input$threshold)
    observed <- pred$observed
    tp <- sum(predicted == 1 & observed == 1)
    tn <- sum(predicted == 0 & observed == 0)
    fp <- sum(predicted == 1 & observed == 0)
    fn <- sum(predicted == 0 & observed == 1)
    list(tp = tp, tn = tn, fp = fp, fn = fn,
         sensitivity = tp / (tp + fn), specificity = tn / (tn + fp),
         precision = if (tp + fp > 0) tp / (tp + fp) else NA_real_)
  })

  output$roc_plot <- renderPlot({
    d <- tr()
    point <- confusion()
    ggplot(roc_cv, aes(fpr, tpr)) +
      geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "#94a4ad") +
      geom_line(linewidth = 1.15, colour = "#256d85") +
      geom_point(data = data.frame(fpr = 1 - point$specificity,
                                   tpr = point$sensitivity),
                 size = 4, colour = "#d47b39") +
      coord_equal(xlim = c(0, 1), ylim = c(0, 1)) +
      labs(x = d$x_roc, y = d$y_roc) + plot_theme
  })
  output$classification_table <- renderTable({
    d <- tr()
    m <- confusion()
    data.frame(
      Metric = c(d$positives, d$negatives, d$false_pos, d$false_neg,
                 d$sensitivity_metric, d$specificity, d$precision),
      Value = c(as.character(m$tp), as.character(m$tn),
                as.character(m$fp), as.character(m$fn),
                sprintf("%.1f%%", 100 * m$sensitivity),
                sprintf("%.1f%%", 100 * m$specificity),
                if (is.na(m$precision)) "N/A" else sprintf("%.1f%%", 100 * m$precision))
    )
  }, striped = TRUE, spacing = "s")

  output$cook_plot <- renderPlot({
    d <- tr()
    ggplot(influence, aes(x = row_number, y = cooks_distance)) +
      geom_col(fill = "#256d85", width = .8) +
      geom_hline(yintercept = cook_threshold, colour = "#d47b39",
                 linetype = "dashed", linewidth = 1) +
      labs(x = d$cook_x, y = d$cook_y) + plot_theme
  })
  output$sensitivity_plot <- renderPlot({
    dat <- rbind(
      transform(primary[primary$variable != "(Intercept)", ], model = tr()$main),
      transform(sensitivity[sensitivity$variable != "(Intercept)", ], model = tr()$sens)
    )
    forest_plot_fn(dat, comparison = TRUE)
  })
}

shinyApp(ui = ui, server = server)
