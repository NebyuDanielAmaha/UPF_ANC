* main_analysis.do
* Purpose: Master script to run UPF analysis
* Author: Nebyu Daniel Amaha
* Date: May 2025

clear all
set more off

* Run data cleaning
do "code/data_cleaning.do"

* Run analyses and generate tables
do "code/analysis_tables.do"

* Log results
log using "output/logs/analysis.log", replace
display "Analysis completed on `c(current_date)' at `c(current_time)'"
log close