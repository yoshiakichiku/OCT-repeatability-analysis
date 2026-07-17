# ============================================================
# Retinal thickness repeatability analysis
#
# Three-level linear mixed-effects model:
#   measurement = overall mean
#               + subject effect
#               + eye-within-subject effect
#               + residual measurement error
#
# Model:
#   measurement ~ 1 + (1 | subject_id) + (1 | subject_id:eye)
#
# Eye-level ICC:
#   (subject variance + eye variance) /
#   (subject variance + eye variance + residual variance)
#
# 95% difference threshold:
#   1.96 * sqrt(2) * Imprecision SD
#
# Required Excel columns:
#   subject_id, eye, repeat, sector0-sector12
#
# eye:
#   R or L
#
# repeat:
#   1, 2, or 3
# ============================================================


# ---------- 1. Package checks ----------

required_packages <- c(
  "readxl",
  "lme4"
)

missing_packages <- required_packages[
  !vapply(
    required_packages,
    requireNamespace,
    logical(1),
    quietly = TRUE
  )
]

if (length(missing_packages) > 0) {
  stop(
    "Missing package(s): ",
    paste(missing_packages, collapse = ", "),
    "\nInstall them using:\ninstall.packages(c(",
    paste(
      paste0('"', missing_packages, '"'),
      collapse = ", "
    ),
    "))"
  )
}

library(readxl)
library(lme4)


# ---------- 2. Read Excel data ----------

message("Select the Excel file containing the repeatability data.")

data <- read_excel(
  file.choose()
)


# ---------- 3. Settings ----------

sector_names <- paste0(
  "sector",
  0:12
)

required_columns <- c(
  "subject_id",
  "eye",
  "repeat",
  sector_names
)


# ---------- 4. Check required columns ----------

missing_columns <- setdiff(
  required_columns,
  names(data)
)

if (length(missing_columns) > 0) {
  stop(
    "Missing required column(s): ",
    paste(
      missing_columns,
      collapse = ", "
    )
  )
}


# ---------- 5. Prepare variables ----------

data$subject_id <- factor(
  data$subject_id
)

data$eye <- toupper(
  trimws(
    as.character(
      data$eye
    )
  )
)

invalid_eye_values <- setdiff(
  unique(
    na.omit(
      data$eye
    )
  ),
  c("R", "L")
)

if (length(invalid_eye_values) > 0) {
  stop(
    "Invalid value(s) in the eye column: ",
    paste(
      invalid_eye_values,
      collapse = ", "
    ),
    "\nThe eye column must contain only R or L."
  )
}

data$eye <- factor(
  data$eye,
  levels = c(
    "R",
    "L"
  )
)

data[["repeat"]] <- suppressWarnings(
  as.integer(
    data[["repeat"]]
  )
)

invalid_repeat_values <- setdiff(
  unique(
    na.omit(
      data[["repeat"]]
    )
  ),
  c(
    1L,
    2L,
    3L
  )
)

if (length(invalid_repeat_values) > 0) {
  stop(
    "Invalid value(s) in the repeat column: ",
    paste(
      invalid_repeat_values,
      collapse = ", "
    ),
    "\nThe repeat column must contain only 1, 2, or 3."
  )
}

# Unique eye identifier nested within subject
data$subject_eye <- interaction(
  data$subject_id,
  data$eye,
  drop = TRUE,
  sep = "_"
)


# ---------- 6. Display dataset structure ----------

cat(
  "\nNumber of participants:\n"
)

print(
  length(
    unique(
      data$subject_id
    )
  )
)

cat(
  "\nNumber of eyes:\n"
)

print(
  length(
    unique(
      data$subject_eye
    )
  )
)

cat(
  "\nNumber of rows by eye:\n"
)

print(
  table(
    data$eye,
    useNA = "ifany"
  )
)

cat(
  "\nNumber of rows by repeat:\n"
)

print(
  table(
    data[["repeat"]],
    useNA = "ifany"
  )
)

cat(
  "\nNumber of repeated measurements per eye:\n"
)

print(
  table(
    table(
      data$subject_eye
    )
  )
)


# ---------- 7. Analysis function ----------

calculate_repeatability <- function(
  input_data,
  outcome
) {

  analysis_data <- input_data[
    ,
    c(
      "subject_id",
      "eye",
      "subject_eye",
      "repeat",
      outcome
    )
  ]

  names(
    analysis_data
  )[
    names(
      analysis_data
    ) == outcome
  ] <- "measurement"

  analysis_data <- analysis_data[
    complete.cases(
      analysis_data
    ),
  ]

  if (nrow(analysis_data) == 0) {
    warning(
      outcome,
      ": No complete observations were available."
    )

    return(
      data.frame(
        Estimated_mean = NA_real_,
        Subject_SD = NA_real_,
        Subject_CV = NA_real_,
        Eye_SD = NA_real_,
        Eye_CV = NA_real_,
        Imprecision_SD = NA_real_,
        Imprecision_CV = NA_real_,
        Difference_threshold_95 = NA_real_,
        Eye_ICC = NA_real_,
        N_subjects = NA_integer_,
        N_eyes = NA_integer_,
        N_measurements = 0L
      )
    )
  }

  analysis_data$subject_id <- factor(
    analysis_data$subject_id
  )

  analysis_data$subject_eye <- factor(
    analysis_data$subject_eye
  )

  analysis_data$measurement <- suppressWarnings(
    as.numeric(
      analysis_data$measurement
    )
  )

  analysis_data <- analysis_data[
    complete.cases(
      analysis_data
    ),
  ]

  n_subjects <- length(
    unique(
      analysis_data$subject_id
    )
  )

  n_eyes <- length(
    unique(
      analysis_data$subject_eye
    )
  )

  n_measurements <- nrow(
    analysis_data
  )

  if (n_subjects < 2) {
    warning(
      outcome,
      ": Fewer than two participants were available."
    )
  }

  if (n_eyes < 2) {
    warning(
      outcome,
      ": Fewer than two eyes were available."
    )
  }

  # Three-level random-intercept model
  model <- lmer(
    measurement ~ 1 +
      (1 | subject_id) +
      (1 | subject_eye),
    data = analysis_data,
    REML = TRUE,
    control = lmerControl(
      optimizer = "bobyqa"
    )
  )

  variance_components <- as.data.frame(
    VarCorr(
      model
    )
  )

  get_variance_component <- function(
    group_name
  ) {

    value <- variance_components$vcov[
      variance_components$grp == group_name
    ]

    if (length(value) != 1) {
      stop(
        outcome,
        ": Could not uniquely identify variance component for ",
        group_name,
        "."
      )
    }

    as.numeric(
      value
    )
  }

  subject_variance <- get_variance_component(
    "subject_id"
  )

  eye_variance <- get_variance_component(
    "subject_eye"
  )

  residual_variance <- get_variance_component(
    "Residual"
  )

  estimated_mean <- as.numeric(
    fixef(
      model
    )[
      "(Intercept)"
    ]
  )

  subject_sd <- sqrt(
    subject_variance
  )

  eye_sd <- sqrt(
    eye_variance
  )

  imprecision_sd <- sqrt(
    residual_variance
  )

  if (
    is.na(
      estimated_mean
    ) ||
    estimated_mean == 0
  ) {

    subject_cv <- NA_real_
    eye_cv <- NA_real_
    imprecision_cv <- NA_real_

  } else {

    subject_cv <-
      subject_sd /
      estimated_mean *
      100

    eye_cv <-
      eye_sd /
      estimated_mean *
      100

    imprecision_cv <-
      imprecision_sd /
      estimated_mean *
      100
  }

  total_variance <-
    subject_variance +
    eye_variance +
    residual_variance

  if (
    is.na(
      total_variance
    ) ||
    total_variance <= 0
  ) {

    eye_icc <- NA_real_

  } else {

    eye_icc <-
      (
        subject_variance +
          eye_variance
      ) /
      total_variance
  }

  difference_threshold_95 <-
    1.96 *
    sqrt(
      2
    ) *
    imprecision_sd

  singular_fit <- isSingular(
    model,
    tol = 1e-4
  )

  if (singular_fit) {
    warning(
      outcome,
      ": The mixed-effects model produced a singular fit."
    )
  }

  data.frame(
    Estimated_mean = estimated_mean,
    Subject_SD = subject_sd,
    Subject_CV = subject_cv,
    Eye_SD = eye_sd,
    Eye_CV = eye_cv,
    Imprecision_SD = imprecision_sd,
    Imprecision_CV = imprecision_cv,
    Difference_threshold_95 = difference_threshold_95,
    Eye_ICC = eye_icc,
    N_subjects = n_subjects,
    N_eyes = n_eyes,
    N_measurements = n_measurements
  )
}


# ---------- 8. Calculate sector0-sector12 ----------

results_list <- lapply(
  sector_names,
  function(
    current_sector
  ) {

    sector_result <- calculate_repeatability(
      input_data = data,
      outcome = current_sector
    )

    sector_result$Sector <- current_sector

    sector_result
  }
)

results <- do.call(
  rbind,
  results_list
)


# ---------- 9. Arrange columns ----------

results <- results[
  ,
  c(
    "Sector",
    "Estimated_mean",
    "Subject_SD",
    "Subject_CV",
    "Eye_SD",
    "Eye_CV",
    "Imprecision_SD",
    "Imprecision_CV",
    "Difference_threshold_95",
    "Eye_ICC",
    "N_subjects",
    "N_eyes",
    "N_measurements"
  )
]


# ---------- 10. Create publication table ----------

publication_table <- results[
  ,
  c(
    "Sector",
    "Estimated_mean",
    "Subject_SD",
    "Subject_CV",
    "Eye_SD",
    "Eye_CV",
    "Imprecision_SD",
    "Imprecision_CV",
    "Difference_threshold_95",
    "Eye_ICC"
  )
]

publication_table[
  ,
  c(
    "Estimated_mean",
    "Subject_SD",
    "Eye_SD",
    "Imprecision_SD",
    "Difference_threshold_95"
  )
] <- lapply(
  publication_table[
    ,
    c(
      "Estimated_mean",
      "Subject_SD",
      "Eye_SD",
      "Imprecision_SD",
      "Difference_threshold_95"
    )
  ],
  function(
    x
  ) {
    round(
      x,
      3
    )
  }
)

publication_table[
  ,
  c(
    "Subject_CV",
    "Eye_CV",
    "Imprecision_CV"
  )
] <- lapply(
  publication_table[
    ,
    c(
      "Subject_CV",
      "Eye_CV",
      "Imprecision_CV"
    )
  ],
  function(
    x
  ) {
    round(
      x,
      2
    )
  }
)

publication_table$Eye_ICC <- round(
  publication_table$Eye_ICC,
  3
)


# ---------- 11. Display results ----------

cat(
  "\nFull analysis results:\n"
)

print(
  results
)

cat(
  "\nPublication table:\n"
)

print(
  publication_table
)


# ---------- 12. Export CSV files ----------

output_directory <- path.expand(
  "~/Desktop"
)

publication_output_file <- file.path(
  output_directory,
  "Repeatability_main_table.csv"
)

full_output_file <- file.path(
  output_directory,
  "Repeatability_full_results.csv"
)

write.csv(
  publication_table,
  file = publication_output_file,
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

write.csv(
  results,
  file = full_output_file,
  row.names = FALSE,
  fileEncoding = "UTF-8"
)


# ---------- 13. Completion message ----------

message(
  "Publication table exported to: ",
  publication_output_file
)

message(
  "Full results exported to: ",
  full_output_file
)