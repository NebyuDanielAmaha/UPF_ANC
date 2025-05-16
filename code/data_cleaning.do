* data_cleaning.do
* Purpose: Clean Tanzania DHS 2022 data, create variables for UPF analysis
* Author: Nebyu Daniel Amaha
* Date: May 2025

clear all
set more off

* Install required packages
ssc install table1, replace
ssc install estout, replace
ssc install psmatch2, replace

* Load data (update path for portability)
use "data/tanzania.dta", clear
* Note: Data not included in repository; obtain from DHS Program

* Define survey weight
gen wt = v005 / 1000000
label variable wt "Survey weight (v005/1,000,000)"

* Filter women who gave birth in the last two years
keep if m80 == 1 & p19 < 24

* Exclude currently pregnant women
keep if v213 != 1

* Outcome: Ultra-Processed Food (UPF) Consumption
* Handle missing codes (8 = Don't know)
foreach var in v472r v472t v471d {
    replace `var' = . if `var' >= 8
}

* Binary UPF (1 = Any UPF, 0 = None)
gen upf_binary = 0
replace upf_binary = 1 if v472r == 1 | v472t == 1 | v471d == 1
replace upf_binary = . if missing(v472r) & missing(v472t) & missing(v471d)
label define upf_bin 0 "No UPF" 1 "Any UPF"
label values upf_binary upf_bin

* Frequency count (0, 1, 2, 3+ items)
egen upf_freq = rowtotal(v472r v472t v471d), missing
replace upf_freq = 3 if upf_freq > 3 & !missing(upf_freq)
label define upf_freq 0 "None" 1 "1 item" 2 "2 items" 3 "3+ items"
label values upf_freq upf_freq

* Tertiles (none, low, high)
gen upf_tertile = 0 if upf_freq == 0
xtile temp_tertile = upf_freq if upf_freq > 0 & !missing(upf_freq), nq(3)
replace upf_tertile = temp_tertile if upf_freq > 0 & !missing(upf_freq)
drop temp_tertile
label define upf_tert 0 "None" 1 "Low" 3 "High"
label values upf_tertile upf_tert

* Exposure: ANC Dietary Counseling
replace m42g = . if m42g == 8
gen anc_counsel = m42g
label define anc_counsel 0 "No" 1 "Yes"
label values anc_counsel anc_counsel

* Mediator: Minimum Dietary Diversity for Women (MDD-W)
* Define food groups (DHS8 indicators)
gen nt_wm_grains = (v472e == 1)
gen nt_wm_root = (v472f == 1)
gen nt_wm_beans = (v472o == 1)
gen nt_wm_nuts = (v472c == 1)
gen nt_wm_dairy = (v472p == 1)
gen nt_wm_meatfish = (v472b == 1 | v472h == 1 | v472m == 1 | v472n == 1)
gen nt_wm_eggs = (v472g == 1)
gen nt_wm_dkgreens = (v472j == 1)
gen nt_wm_vita = (v472i == 1 | v472k == 1)
gen nt_wm_veg = (v472a == 1)
gen nt_wm_fruit = (v472l == 1)

* Define 10 MDD-W food groups
gen group1 = (nt_wm_grains == 1 | nt_wm_root == 1)  // Grains, roots
gen group2 = (nt_wm_beans == 1)                     // Beans, peas
gen group3 = (nt_wm_nuts == 1)                      // Nuts, seeds
gen group4 = (nt_wm_dairy == 1)                     // Dairy
gen group5 = (nt_wm_meatfish == 1)                  // Meat, fish
gen group6 = (nt_wm_eggs == 1)                      // Eggs
gen group7 = (nt_wm_dkgreens == 1)                  // Dark leafy greens
gen group8 = (nt_wm_vita == 1)                      // Vitamin A-rich
gen group9 = (nt_wm_veg == 1)                       // Other vegetables
gen group10 = (nt_wm_fruit == 1)                    // Other fruits

* Sum food groups (MDD-W: ≥5 groups)
egen foodsum = rsum(group1 group2 group3 group4 group5 group6 group7 group8 group9 group10)
recode foodsum (1/4 .=0 "No") (5/10=1 "Yes"), gen(nt_wm_mdd)
label values nt_wm_mdd yesno
label var nt_wm_mdd "Minimum Dietary Diversity (≥5/10 food groups)"

* Covariates
* 1. Age
gen age_cat = 0 if v012 >= 15 & v012 <= 19
replace age_cat = 1 if v012 >= 20 & v012 <= 34
replace age_cat = 2 if v012 >= 35 & v012 <= 49
label define age_cat 0 "15–19" 1 "20–34" 2 "35–49"
label values age_cat age_cat

* 2. Education (grouped: none, primary, secondary or above)
gen educ_grouped = 0 if v106 == 0
replace educ_grouped = 1 if v106 == 1
replace educ_grouped = 2 if v106 >= 2 & v106 <= 3
replace educ_grouped = . if v106 >= 8
label define educ_grouped 0 "None" 1 "Primary" 2 "Secondary or above"
label values educ_grouped educ_grouped

* 3. Wealth Index
gen wealth = v190
replace wealth = . if v190 >= 6
label define wealth 1 "Poorest" 2 "Poorer" 3 "Middle" 4 "Richer" 5 "Richest"
label values wealth wealth

* 4. Urban/Rural
gen urban_rural = (v025 == 1)
replace urban_rural = . if v025 >= 8
label define urban 0 "Rural" 1 "Urban"
label values urban_rural urban

* 5. Marital Status
gen marital_status = (v501 == 1)
replace marital_status = . if v501 >= 8
label define marital 0 "Unmarried" 1 "Married"
label values marital_status marital

* 6. ANC Visits
gen anc_visits = 0 if m14 < 4 & !missing(m14)
replace anc_visits = 1 if m14 >= 4 & !missing(m14)
replace anc_visits = . if m14 >= 98
label define anc_visits 0 "<4 visits" 1 "≥4 visits"
label values anc_visits anc_visits

* 7. Cesarean Delivery
gen caesarean = (m17 == 1)
replace caesarean = . if m17 >= 8
label define cs 0 "No" 1 "Yes"
label values caesarean cs

* 8. Postnatal Check
gen postnatal_check = (m70 == 1)
replace postnatal_check = . if m70 >= 8
label define pnc 0 "No" 1 "Yes"
label values postnatal_check pnc

* 9. Vitamin A-Rich Foods
gen vita_binary = (nt_wm_vita > 0 & !missing(nt_wm_vita))
replace vita_binary = . if nt_wm_vita >= 8
label define vita 0 "None" 1 "Any"
label values vita_binary vita

* 10. Healthcare Access Barriers
gen serious_problem = 0
foreach var in v467b v467c v467d v467f {
    replace serious_problem = 1 if `var' == 1
}
replace serious_problem = . if missing(v467b) & missing(v467c) & missing(v467d) & missing(v467f)
label define prob 0 "No" 1 "Yes"
label values serious_problem prob

* 11. Travel Time
gen travel_time = 0 if v483a < 30 & !missing(v483a)
replace travel_time = 1 if v483a >= 30 & v483a < 60 & !missing(v483a)
replace travel_time = 2 if v483a >= 60 & v483a <= 120 & !missing(v483a)
replace travel_time = 3 if v483a > 120 & !missing(v483a)
replace travel_time = . if v483a >= 998
label define travel 0 "<30 min" 1 "30 min–<1 hr" 2 "1-2 hr" 3 ">2 hr"
label values travel_time travel

* 12. Transport Mode
recode v483b (11/19=1 "Motorized") (21/29=0 "Non-motorized") (96=.), gen(transport_mode)
label var transport_mode "Transport to health facility"
