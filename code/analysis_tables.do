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
misstable summarize upf_binary nt_wm_mdd anc_counsel age_cat educ_grouped wealth urban_rural marital_status vita_binary travel_time transport_mode serious_problem rc_media_anythree rc_intr_use12mo parity_cat working 

* Diagnostics: Multicollinearity
regress upf_binary i.nt_wm_mdd i.anc_counsel i.age_cat i.educ_grouped i.wealth i.urban_rural i.marital_status i.vita_binary i.travel_time i.transport_mode i.serious_problem i.rc_media_anythree i. rc_intr_use12mo i.parity_cat i.working 
vif

* Table 1: Weighted Distribution of Study Variables
svy: tab anc_counsel, count percent
svy: tab upf_binary, count percent
svy: tab nt_wm_mdd, count percent
svy: tab age_cat, count percent
svy: tab educ_grouped, count percent
svy: tab wealth, count percent
svy: tab urban_rural, count percent
svy: tab marital_status, count percent
svy: tab anc_visits, count percent
svy: tab vita_binary, count percent
svy: tab serious_problem, count percent
svy: tab travel_time, count percent
svy: tab transport_mode, count percent
svy: tab rc_media_anythree, count percent
svy: tab rc_intr_use12mo, count percent
svy: tab parity_cat, count percent
svy: tab working, count percent

* Export Table 1
table1, by(upf_binary) vars(anc_counsel cat \ nt_wm_mdd cat \ age_cat cat \ educ_grouped cat \ wealth cat \ urban_rural cat \ marital_status cat \ anc_visits cat \ vita_binary cat \ serious_problem cat \ travel_time cat \ transport_mode cat \ rc_media_anythree cat \ rc_intr_use12mo cat \ parity_cat cat \ working cat) saving("output/tables/Table1.xlsx")

* Table 2: UPF Consumption by Characteristics
svy: tab anc_counsel upf_binary, percent
svy: tab nt_wm_mdd upf_binary, percent
svy: tab age_cat upf_binary, percent
svy: tab educ_grouped upf_binary, percent
svy: tab wealth upf_binary, percent
svy: tab urban_rural upf_binary, percent
svy: tab marital_status upf_binary, percent
svy: tab anc_visits upf_binary, percent
svy: tab vita_binary upf_binary, percent
svy: tab serious_problem upf_binary, percent
svy: tab travel_time upf_binary, percent
svy: tab transport_mode upf_binary, percent
svy: tab rc_media_anythree upf_binary, percent
svy: tab rc_intr_use12mo upf_binary, percent
svy: tab parity_cat upf_binary, percent
svy: tab working upf_binary, percent

* Table 3: Adjusted Odds Ratios for UPF Consumption
svy: logit upf_binary i.anc_counsel i.nt_wm_mdd i.age_cat i.educ_grouped i.wealth i.urban_rural i.marital_status i.vita_binary i.serious_problem i.travel_time i.transport_mode i.rc_media_anythree i. rc_intr_use12mo i.parity_cat i.working, or

* Table 4: Mediation Analysis (Binary UPF)
svy: gsem (nt_wm_mdd <- i.anc_counsel i.age_cat i.educ_grouped i.wealth i.urban_rural i.marital_status i.anc_visits i.vita_binary i.serious_problem i.travel_time i.transport_mode i.rc_media_anythree i.rc_intr_use12mo i.parity_cat i.working, family(bernoulli) link(logit)) (upf_binary <- i.nt_wm_mdd i.anc_counsel i.age_cat i.educ_grouped i.wealth i.urban_rural i.marital_status i.anc_visits i.vita_binary i.serious_problem i.travel_time i.transport_mode i.rc_media_anythree i.rc_intr_use12mo i.parity_cat i.working, family(bernoulli) link(logit))
*Path a
lincom [nt_wm_mdd]1.anc_counsel, or 
*Path b
lincom [upf_binary]1.nt_wm_mdd, or
*Path c'
lincom [upf_binary]1.anc_counsel, or
*Indirect effect
nlcom (_indirect: [nt_wm_mdd]1.anc_counsel * [upf_binary]1.nt_wm_mdd)

*Table 5: Moderation Analysis
*by education
svy: logit upf_binary i.anc_counsel##i.educ_grouped i.nt_wm_mdd i.age_cat i.wealth i.urban_rural i.marital_status i.vita_binary i.serious_problem i.travel_time i.transport_mode i.rc_media_anythree i. rc_intr_use12mo i.parity_cat i.working, or

*by age
svy: logit upf_binary i.anc_counsel##i.age_cat i.nt_wm_mdd i.educ_grouped i.wealth i.urban_rural i.marital_status i.vita_binary i.serious_problem i.travel_time i.transport_mode i.rc_media_anythree i. rc_intr_use12mo i.parity_cat i.working, or

*by wealth
svy: logit upf_binary i.anc_counsel##i.wealth i.nt_wm_mdd i.age_cat i.educ_grouped i.urban_rural i.marital_status i.vita_binary i.serious_problem i.travel_time i.transport_mode i.rc_media_anythree i. rc_intr_use12mo i.parity_cat i.working, or

*by health care access
svy: logit upf_binary i.anc_counsel##i.serious_problem i.nt_wm_mdd i.age_cat i.educ_grouped i.wealth i.urban_rural i.marital_status i.vita_binary i.travel_time i.transport_mode i.rc_media_anythree i. rc_intr_use12mo i.parity_cat i.working, or

* Supplementary Table 1: Mediation with UPF Frequency
svy: gsem (nt_wm_mdd <- i.anc_counsel i.age_cat i.educ_grouped i.wealth i.urban_rural i.marital_status i.anc_visits i.vita_binary i.serious_problem i.travel_time i.transport_mode i.rc_media_anythree i.rc_intr_use12mo i.parity_cat i.working, family(bernoulli) link(logit)) (upf_freq <- i.nt_wm_mdd i.anc_counsel i.age_cat i.educ_grouped i.wealth i.urban_rural i.marital_status i.anc_visits i.vita_binary i.serious_problem i.travel_time i.transport_mode i.rc_media_anythree i.rc_intr_use12mo i.parity_cat i.working, family(ordinal) link(logit))
lincom [nt_wm_mdd]1.anc_counsel, or
lincom [upf_freq]1.nt_wm_mdd, or
lincom [upf_freq]1.anc_counsel, or
nlcom (_indirect: [nt_wm_mdd]1.anc_counsel * [upf_freq]1.nt_wm_mdd)

* Supplementary Table 2: Mediation with UPF Tertiles
svy: gsem (nt_wm_mdd <- i.anc_counsel i.age_cat i.educ_grouped i.wealth i.urban_rural i.marital_status i.anc_visits i.caesarean i.postnatal_check i.vita_binary i.serious_problem i.travel_time i.transport_mode i.rc_media_anythree i.rc_intr_use12mo i.parity_cat i.working, family(bernoulli) link(logit)) (upf_tertile <- i.nt_wm_mdd i.anc_counsel i.age_cat i.educ_grouped i.wealth i.urban_rural i.marital_status i.anc_visits i.caesarean i.postnatal_check i.vita_binary i.serious_problem i.travel_time i.transport_mode i.rc_media_anythree i.rc_intr_use12mo i.parity_cat i.working, family(ordinal) link(logit))
lincom [nt_wm_mdd]1.anc_counsel, or
lincom [upf_tertile]1.nt_wm_mdd, or
lincom [upf_tertile]1.anc_counsel, or
nlcom (_indirect: [nt_wm_mdd]1.anc_counsel * [upf_tertile]1.nt_wm_mdd)

* Supplementary Table 3: *PROPENSITY SCORE ANALYSIS USING IPTW

* Set survey design
svyset v021 [pweight=wt], strata(v022)

* Estimate propensity scores using logistic regression
logit anc_counsel i.age_cat i.education i.wealth i.urban_rural i.marital_status i.anc_visits i.vita_binary i.serious_problem i.travel_time i.transport_mode i.rc_media_anythree i.rc_intr_use12mo i.parity_cat i.working [pweight=wt]
predict ps, pr

* Check propensity score distribution
summarize ps, detail

* Calculate marginal probability of treatment
tabulate anc_counsel [aweight=wt], matcell(freq)
scalar p_treat = freq[2,1] / (freq[1,1] + freq[2,1])

* Alternative: Use mean
mean anc_counsel [pweight=wt]
scalar p_treat = _b[anc_counsel]

* Generate stabilized IPTW weights
gen iptw = .
replace iptw = p_treat / ps if anc_counsel == 1
replace iptw = (1 - p_treat) / (1 - ps) if anc_counsel == 0

* Check for extreme weights
summarize iptw, detail

*Trimming
replace iptw = min(iptw, 10) if iptw != .

*Combine with Survey weights
gen final_wt = wt * iptw
summarize final_wt, detail

*assess co-variate balance
foreach var in age_cat education wealth urban_rural marital_status anc_visits caesarean postnatal_check vita_binary serious_problem travel_time transport_mode {
    qui sum `var' [aweight=final_wt] if anc_counsel == 1
    local mean_t = r(mean)
    local sd_t = r(sd)
    qui sum `var' [aweight=final_wt] if anc_counsel == 0
    local mean_c = r(mean)
    local sd_c = r(sd)
    local std_diff = abs(`mean_t' - `mean_c') / sqrt((`sd_t'^2 + `sd_c'^2)/2)
    di "Standardized difference for `var': `std_diff'"
}

*Rerun with IPTW weights
* Set survey design with IPTW weights
svyset v021 [pweight=final_wt], strata(v022)

svy: gsem (nt_wm_mdd <- i.anc_counsel i.age_cat i.education i.wealth i.urban_rural i.marital_status i.anc_visits i.vita_binary i.serious_problem i.travel_time i.transport_mode i.rc_media_anythree i.rc_intr_use12mo i.parity_cat i.working, family(bernoulli) link(logit)) (upf_binary <- i.nt_wm_mdd i.anc_counsel i.age_cat i.education i.wealth i.urban_rural i.marital_status i.anc_visits i.caesarean i.postnatal_check i.vita_binary i.serious_problem i.travel_time i.transport_mode, family(bernoulli) link(logit))
estimates store mod_iptw_binary
lincom [nt_wm_mdd]1.anc_counsel, or
lincom [upf_binary]1.nt_wm_mdd, or
lincom [upf_binary]1.anc_counsel, or
nlcom (_indirect: [nt_wm_mdd]1.anc_counsel * [upf_binary]1.nt_wm_mdd), post
estimates store indirect_iptw_binary

* Continuous Dietary Diversity (Sensitivity Analysis)
svyset v021 [pweight=wt], strata(v022)
svy: gsem (foodsum <- i.anc_counsel i.age_cat i.educ_grouped i.wealth i.urban_rural i.marital_status i.anc_visits i.vita_binary i.serious_problem i.travel_time i.transport_mode i.rc_media_anythree i.rc_intr_use12mo i.parity_cat i.working, family(gaussian) link(identity)) (upf_binary <- foodsum i.anc_counsel i.age_cat i.educ_grouped i.wealth i.urban_rural i.marital_status i.anc_visits i.vita_binary i.serious_problem i.travel_time i.transport_mode i.rc_media_anythree i.rc_intr_use12mo i.parity_cat i.working, family(bernoulli) link(logit))
lincom [foodsum]1.anc_counsel
lincom [upf_binary]foodsum, or
lincom [upf_binary]1.anc_counsel, or
nlcom (_indirect: [foodsum]1.anc_counsel * [upf_binary]foodsum)
