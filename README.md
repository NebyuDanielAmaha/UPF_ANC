# UPF_ANC: Ultra-Processed Food Consumption and ANC Dietary Counseling in Tanzania

This repository contains Stata code for the analysis of ultra-processed food (UPF) consumption among women in Tanzania, using the 2022 Tanzania Demographic and Health Survey (TDHS). The study examines the relationship between antenatal care (ANC) dietary counseling and UPF consumption, mediated by maternal dietary diversity (MDD-W).

## Repository Structure

- `code/`: Stata `.do` files for data cleaning and analysis.
  - `main_analysis.do`: Master script to run all analyses.
  - `data_cleaning.do`: Data filtering and variable creation.
  - `analysis_tables.do`: Descriptive statistics, tables, and mediation/IPTW analyses.
- `data/`: Placeholder for the TDHS dataset (not included; see `data/README.md`).
- `output/`: Exported tables and logs.
  - `tables/`: Tables 1–4, Supplementary Tables 1–3, and Foodsum analysis (RTF, XLSX).
  - `logs/`: Stata log files.
- `README.md`: This file.
- `LICENSE`: MIT License.
- `.gitignore`: Excludes data, logs, and temporary files.

## Requirements

- **Software**: Stata 15 or later.
- **Packages**: `table1`, `estout`, `psmatch2` (installed via `ssc install`).
- **Data**: Tanzania DHS 2022 dataset (obtain from https://dhsprogram.com).

## Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/NebyuDanielAmaha/UPF_ANC.git
   cd UPF_ANC# UPF_ANC
