* analysis_tables.do
* Purpose: Generate tables and run mediation/IPTW analyses for UPF study
* Author: Nebyu Daniel Amaha
* Date: May 2025

clear all
set more off

* Load cleaned data
use "data/cleaned_tanzania.dta", clear

* Set survey design
svyset [pw=wt], psu(v021) strata(v022) singleunit(scaled)

* Diagnostics: Missing Values
misstable summarize upf_binary nt_wm_mdd anc_counsel age_cat educ_grouped wealth urban_rural caesarean postnatal_check marital_status vita_binary travel_time transport_mode serious_problem

* Diagnostics: Multicollinearity
regress upf_binary i.nt_wm_mdd i.anc_counsel i.age_cat i.educ_grouped i.wealth i.urban_rural i.caesarean i.postnatal_check i.marital_status i.vita_binary i.travel_time i.transport_mode i.serious_problem
vif

* Table 1: Weighted Distribution of Study Variables
svy: tab anc_counsel, count percent
svy: tab upf_binary, count percent
svy: tab nt_wm_mdd, count percent
svy: tab age_cat, count percent
svy: tab education, count percent
svy: tab wealth, count percent
svy: tab urban_rural, count percent
svy: tab marital_status, count percent
svy: tab anc_visits, count percent
svy: tab caesarean, count percent
svy: tab postnatal_check, count percent
svy: tab vita_binary, count percent
svy: tab serious_problem, count percent
svy: tab travel_time, count percent
svy: tab transport_mode, count percent

* Export Table 1
table1, by(upf_binary) vars(anc_counsel cat \ nt_wm_mdd cat \ age_cat cat \ educ_grouped cat \ wealth cat \ urban_rural cat \ marital_status cat \ anc_visits cat \ caesarean cat \ postnatal_check cat \ vita_binary cat \ serious_problem cat \ travel_time cat \ transport_mode cat) saving("output/tables/Table1.xlsx")

* Table 2: UPF Consumption by Characteristics
svy: tab anc_counsel upf_binary, percent
svy: tab nt_wm_mdd upf_binary, percent
svy: tab age_cat upf_binary, percent
svy: tab educ_grouped upf_binary, percent
svy: tab wealth upf_binary, percent
svy: tab urban_rural upf_binary, percent
svy: tab marital_status upf_binary, percent
svy: tab anc_visits upf_binary, percent
svy: tab caesarean upf_binary, percent
svy: tab postnatal_check upf_binary, percent
svy: tab vita_binary upf_binary, percent
svy: tab serious_problem upf_binary, percent
svy: tab travel_time upf_binary, percent
svy: tab transport_mode upf_binary, percent

* Table 3: Adjusted Odds Ratios for UPF Consumption
svy: logit upf_binary i.anc_counsel i.nt_wm_mdd i.age_cat i.educ_grouped i.wealth i.urban_rural i.caesarean i.postnatal_check i.marital_status i.vita_binary i.serious_problem i.travel_time i.transport_mode, or
est store table3
esttab table3 using "output/tables/Table3.rtf", eform ci(2) star(* 0.05 ** 0.01 *** 0.001) replace

* Table 4: Mediation Analysis (Binary UPF)
svy: gsem (nt_wm_mdd <- i.anc_counsel i.age_cat i.educ_grouped i.wealth i.urban_rural i.marital_status i.anc_visits i.caesarean i.postnatal_check i.vita_binary i.serious_problem i.travel_time i.transport_mode, family(bernoulli) link(logit)) ///
          (upf_binary <- i.nt_wm_mdd i.anc_counsel i.age_cat i.educ_grouped i.wealth i.urban_rural i.marital_status i.anc_visits i.caesarean i.postnatal_check i.vita_binary i.serious_problem i.travel_time i.transport_mode, family(bernoulli) link(logit))
estat teffects
lincom [nt_wm_mdd]1.anc_counsel, or  // Path a
lincom [upf_binary]1.nt_wm_mdd, or   // Path b
lincom [upf_binary]1.anc_counsel, or // Path c'
nlcom (_indirect: [nt_wm_mdd]1.anc_counsel * [upf_binary]1.nt_wm_mdd) // Indirect effect
est store table4
esttab table4 using "output/tables/Table4.rtf", ci(2) star(* 0.05 ** 0.01 *** 0.001) replace

* Supplementary Table 1: Mediation with UPF Frequency
svy: gsem (nt_wm_mdd <- i.anc_counsel i.age_cat i.educ_grouped i.wealth i.urban_rural i.marital_status i.anc_visits i.caesarean i.postnatal_check i.vita_binary i.serious_problem i.travel_time i.transport_mode, family(bernoulli) link(logit)) ///
          (upf_freq <- i.nt_wm_mdd i.anc_counsel i.age_cat i.educ_grouped i.wealth i.urban_rural i.marital_status i.anc_visits i.caesarean i.postnatal_check i.vita_binary i.serious_problem i.travel_time i.transport_mode, family(ordinal) link(logit))
estat teffects
lincom [nt_wm_mdd]1.anc_counsel, or
lincom [upf_freq]1.nt_wm_mdd, or
lincom [upf_freq]1.anc_counsel, or
nlcom (_indirect: [nt_wm_mdd]1.anc_counsel * [upf_freq]1.nt_wm_mdd)
est store sup_table1
esttab sup_table1 using "output/tables/SupTable1.rtf", ci(2) star(* 0.05 ** 0.01 *** 0.001) replace

* Supplementary Table 2: Mediation with UPF Tertiles
svy: gsem (nt_wm_mdd <- i.anc_counsel i.age_cat i.educ_grouped i.wealth i.urban_rural i.marital_status i.anc_visits i.caesarean i.postnatal_check i.vita_binary i.serious_problem i.travel_time i.transport_mode, family(bernoulli) link(logit)) ///
          (upf_tertile <- i.nt_wm_mdd i.anc_counsel i.age_cat i.educ_grouped i.wealth i.urban_rural i.marital_status i.anc_visits i.caesarean i.postnatal_check i.vita_binary i.serious_problem i.travel_time i.transport_mode, family(ordinal) link(logit))
estat teffects
lincom [nt_wm_mdd]1.anc_counsel, or
lincom [upf_tertile]1.nt_wm_mdd, or
lincom [upf_tertile]1.anc_counsel, or
nlcom (_indirect: [nt_wm_mdd]1.anc_counsel * [upf_tertile]1.nt_wm_mdd)
est store sup_table2
esttab sup_table2 using "output/tables/SupTable2.rtf", ci(2) star(* 0.05 ** 0.01 *** 0.001) replace

* Supplementary Table 3: IPTW-Weighted Analysis
* Generate IPTW weights
teffects ipw (anc_counsel) (i.age_cat i.educ_grouped i.wealth i.urban_rural i.marital_status i.anc_visits i.caesarean i.postnatal_check i.vita_binary i.serious_problem i.travel_time i.transport_mode i.educ_grouped#i.wealth) [pweight=wt], osample(bal)
gen iptw = 1 / _ps if anc_counsel == 1
replace iptw = 1 / (1 - _ps) if anc_counsel == 0
replace iptw = min(iptw, 10) // Trim extreme weights
gen final_wt = wt * iptw
summarize final_wt, detail

* IPTW-weighted GSEM
svyset [pw=final_wt], psu(v021) strata(v022) singleunit(scaled)
svy: gsem (nt_wm_mdd <- i.anc_counsel i.age_cat i.educ_grouped i.wealth i.urban_rural i.marital_status i.anc_visits i.caesarean i.postnatal_check i.vita_binary i.serious_problem i.travel_time i.transport_mode, family(bernoulli) link(logit)) ///
          (upf_binary <- i.nt_wm_mdd i.anc_counsel i.age_cat i.educ_grouped i.wealth i.urban_rural i.marital_status i.anc_visits i.caesarean i.postnatal_check i.vita_binary i.serious_problem i.travel_time i.transport_mode, family(bernoulli) link(logit))
estat teffects
nlcom (_indirect: [nt_wm_mdd]1.anc_counsel * [upf_binary]1.nt_wm_mdd)
est store sup_table3
esttab sup_table3 using "output/tables/SupTable3.rtf", ci(2) star(* 0.05 ** 0.01 *** 0.001) replace

* Continuous Dietary Diversity (Sensitivity Analysis)
svy: gsem (foodsum <- i.anc_counsel i.age_cat i.educ_grouped i.wealth i.urban_rural i.marital_status i.anc_visits i.caesarean i.postnatal_check i.vita_binary i.serious_problem i.travel_time i.transport_mode, family(gaussian) link(identity)) ///
          (upf_binary <- foodsum i.anc_counsel i.age_cat i.educ_grouped i.wealth i.urban_rural i.marital_status i.anc_visits i.caesarean i.postnatal_check i.vita_binary i.serious_problem i.travel_time i.transport_mode, family(bernoulli) link(logit))
lincom [foodsum]1.anc_counsel
lincom [upf_binary]foodsum, or
lincom [upf_binary]1.anc_counsel, or
nlcom (_indirect: [foodsum]1.anc_counsel * [upf_binary]foodsum)
est store sup_table_foodsum
esttab sup_table_foodsum using "output/tables/SupTableFoodsum.rtf", ci(2) star(* 0.05 ** 0.01 *** 0.001) replace
