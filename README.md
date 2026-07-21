# OCT Repeatability Analysis

R script for estimating retinal thickness repeatability using a three-level linear mixed-effects model.

## Overview

This repository provides a reproducible workflow for estimating retinal thickness repeatability from repeated OCT measurements using a three-level linear mixed-effects model.

This script analyzes repeated retinal thickness measurements obtained from both eyes of multiple participants.

The model partitions the total variance into:

- Between-subject variance
- Between-eye variance (nested within subject)
- Within-eye measurement error (imprecision)

The script calculates:

- Estimated mean
- Subject SD
- Subject CV
- Eye SD
- Eye CV
- Imprecision SD
- Imprecision CV
- 95% difference threshold
- Eye-level ICC

## Statistical model

Linear mixed-effects model (REML):

measurement ~ 1 + (1 | subject_id) + (1 | subject_id:eye)

Eye-level ICC:

(subject variance + eye variance) /
(subject variance + eye variance + residual variance)

95% difference threshold:

1.96 × √2 × Imprecision SD

## Required packages

- readxl
- lme4

## Input file

An Excel file containing the following columns:

| Column | Description |
|--------|-------------|
| subject_id | Participant identifier |
| eye | R or L |
| repeat | Measurement number (1–3) |
| sector0–sector12 | Retinal thickness values |

The script prompts the user to select the Excel file.

## Output

Two CSV files are exported to the Desktop:

- Repeatability_main_table.csv
- Repeatability_full_results.csv

## Software

- R 4.6.1
- readxl
- lme4

## Code availability

The R code implementing the repeatability analysis described in this study is publicly available in this repository.

The repository contains the complete workflow, including:

- Data import
- Three-level linear mixed-effects model fitting
- Variance component estimation
- ICC calculation
- 95% difference threshold calculation
- CSV export

## Data availability

The raw OCT data used in this study are not publicly available because they contain potentially identifiable clinical information and are subject to institutional ethical restrictions.

No participant data are included in this repository.

## License

This software is released for non-commercial academic research and educational use only.

Commercial use, redistribution for commercial purposes, or incorporation into commercial products or services is prohibited without prior written permission from Shinshu University.

See the LICENSE file for complete terms.

## Citation

If you use this repository in your research, please cite both:

1. the corresponding publication
2. this GitHub repository

Citation metadata are provided in the CITATION.cff file.

## Disclaimer

This software is provided for research purposes only.

It is distributed "as is" without warranty of any kind.

The author and Shinshu University assume no responsibility for any results, damages, or consequences arising from the use of this software.

## Methodological References

The statistical methodology and implementation were developed with reference to the following publications and resources.

### Linear mixed-effects models

- Bates D, Mächler M, Bolker B, Walker S.
  *Fitting Linear Mixed-Effects Models Using lme4.*
  Journal of Statistical Software. 2015;67(1):1–48.
  https://doi.org/10.18637/jss.v067.i01

- lme4 package documentation.
  https://lme4.github.io/lme4/reference/lmer.html

- Park S, Chung Y.
  *The Effect of Missing Levels of Nesting in Multilevel Analysis.*
  Epidemiology and Health. 2022.
  PMCID: PMC9576476.
  PMID: 36239111.

- *Applying Linear Mixed Models to Estimate Reliability in Clinical Trial Data with Repeated Measurements.*
  Genomics & Informatics. 2022;20(3):e34.
  https://doi.org/10.5808/gi.22052

### Reliability and repeatability

- Bland JM, Altman DG.
  *Statistical Methods for Assessing Agreement Between Two Methods of Clinical Measurement.*
  Lancet. 1986;1(8476):307–310.

- Bland M.
  *An Introduction to Medical Statistics.*
  Oxford University Press.

- *Quantitative Imaging Biomarkers: A Review of Statistical Methods for Technical Performance Assessment.*

### Intraclass correlation coefficient (ICC)

- Koo TK, Li MY.
  *A Guideline of Selecting and Reporting Intraclass Correlation Coefficients for Reliability Research.*
  Journal of Chiropractic Medicine. 2016;15(2):155–163.

- Hedges LV, Hedberg EC.
  *Intraclass Correlation Values for Planning Group Randomized Trials in Education.*
  William T. Grant Foundation.
  https://wtgrantfoundation.org/wp-content/uploads/2015/10/Intraclass-Correlation-Values-for-Planning-Group-Randomized-Trials-in-Education.pdf

### Statistical computing

- R Core Team.
  *R: A Language and Environment for Statistical Computing.*
  R Foundation for Statistical Computing.
  https://www.R-project.org/

**Note**

The implementation and workflow in this repository were independently developed by the author based on the statistical methodology described in the references above. The source code was originally written by the author. ChatGPT (OpenAI, GPT-5.5) was used only to assist with code refinement, explanation, documentation, and readability improvements. Responsibility for the implementation, validation, and interpretation remains solely with the author.

## Repository structure

```text
.
├── repeatability_analysis.R   # Main analysis script
├── README.md                  # Project documentation
├── LICENSE                    # License terms
└── CITATION.cff               # Citation metadata
```

## Author

Yoshiaki Chiku
Shinshu University School of Medicine