# OCT Repeatability Analysis

R script for estimating retinal thickness repeatability using a three-level linear mixed-effects model.

## Overview

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

## Author

Yoshiaki Chiku
Shinshu University School of Medicine