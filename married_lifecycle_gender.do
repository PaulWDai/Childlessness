************************************************************************************
* Project: Childlessness Across Countries
* Author: Paul W Dai
* Update: Aug 21, 2021
* Purpose: Childlessness Rate and Logged GDP per capita
********************************************************************************

clear all 
set more off, perm


global workplace 	"/Users/weifengdai/Documents/Master/2021Summer/Childlessness_Development/Empirics"
global code 		"$workplace/code"
global data 		"$workplace/data"
global figure		"$workplace/figure"
global tex			"$worplace/tex"
global tempdata		"$workplace/tempdata"
	
global raw  		"/Users/weifengdai/Dropbox/IPUMS_I_Data"
global pwt			"/Users/weifengdai/Documents/Database/PWT"
************************************************************************************

clear
gen country = .
save "$data/nochild_married_lifecycle_gender.dta",replace


************************************************************************************
// LOOP: read each sample, generate macro level nochild rate
************************************************************************************

global data_no = 0

cd $raw
local files : dir "$raw" files "*.dta"

foreach file in `files'{


//foreach file in "$raw/hungary_1990.dta"{
use `file',clear
disp "`file'"

capture local name = subinstr("`file'",".dta","",.)
disp "`name'"

global data_no = $data_no + 1

////////////////////////////////////////////////////////////////////////////////
* sample selection criteria
////////////////////////////////////////////////////////////////////////////////

qui drop if marst==0 | marst==9 | marst==. // NIU or missing
qui capture keep if gq==10

////////////////////////////////////////////////////////////////////////////////
* criteria for doing counterfactual: droping the niu in each variables
////////////////////////////////////////////////////////////////////////////////

// sex
// qui capture keep if sex==2

// child ever born
qui capture drop if inlist(chborn,98,99,.) // NIU or missing

// employment
qui capture drop if empstat==0 | empstat==9 | empstat==. // NIU or missing
// age
qui capture keep if age>=15 
// education
qui capture drop if edattain==0 | edattain==9| edattain==. // NIU or missing
// urban
qui capture keep if urban==1 |urban==2 


////////////////////////////////////////////////////////////////////////////////
* Life cycle childlessness by gender (married cohorts)
////////////////////////////////////////////////////////////////////////////////
qui capture keep if marst == 2 // married or in union
qui capture keep if sploc != 0

capture preserve// tempfile male_$data_no

capture keep if sex == 1 // keep the male
capture drop sploc
foreach var_m of var *{
capture rename `var_m' `var_m'_m // rename as male variable
}
capture rename pernum_m sploc
capture rename serial_m serial
// save `male_$data_no'
capture save "$tempdata/`name'_male.dta",replace
capture restore
}

capture keep if sex ==2
foreach var_f of var *{
capture rename `var_f' `var_f'_f // rename as female variable
}
capture rename serial_f serial
capture rename sploc_f sploc


//merge 1:1 sploc serial using `male_$data_no',nolabel
capture merge 1:1 sploc serial using "$tempdata/`name'_male.dta",nolabel

capture keep if _merge==3
capture rename chborn_f chborn
capture gen nochild = (chborn==0)
capture rename sploc pernum_m






capture preserve
// tempfile female_lifecycle_$data_no
capture replace age_f = floor(age_f/5)*5
capture gen obs = 1 
capture collapse (mean) nochild (rawsum) obs [aw=perwt_f], by(country_f year_f sample_f age_f sex_f)
capture keep country_f year_f sample_f age_f sex_f nochild
capture rename country_f country
capture rename year_f year
capture rename age_f age
capture rename sex_f sex
capture rename sample_f sample
//save `female_lifecycle_$data_no'
capture save "$tempfile/`name'_female_lifecycle.dta",replace
capture restore



capture preserve
//tempfile male_lifecycle_$data_no

capture replace age_m = floor(age_m/5)*5
capture gen obs = 1 
capture collapse (mean) nochild (rawsum) obs [aw=perwt_m], by(country_m year_m sample_m age_m sex_m)
capture keep country_m year_m sample_m age_m sex_m nochild
capture rename country_m country
capture rename year_m year
capture rename age_m age
capture rename sex_m sex

capture rename sample_m sample
//save `male_lifecycle_$data_no'
capture save "$tempfile/`name'_male_lifecycle.dta",replace
capture restore


qui capture use "$data/nochild_married_lifecycle_gender.dta",clear
qui capture append using "$tempfile/`name'_female_lifecycle.dta"
qui capture append using "$tempfile/`name'_male_lifecycle.dta"
qui capture save "$data/nochild_married_lifecycle_gender.dta",replace

capture erase "$tempfile/`name'_female_lifecycle.dta"
capture erase "$tempfile/`name'_male_lifecycle.dta"
capture erase "$tempdata/`name'_male.dta"
}





\
use "$data/nochild_married_lifecycle_gender.dta",clear

decode country, gen (cty)
drop country
gen country = strproper(cty)
drop cty

********************************************************************************
*                      Merge with PWT            				               *
********************************************************************************

replace country="Bolivia (Plurinational State of)" 		if country=="Bolivia"
replace country="Iran (Islamic Republic of)" 			if country=="Iran"
replace country="Kyrgyzstan" 							if country=="Kyrgyz Republic"
replace country="U.R. of Tanzania: Mainland" 			if country=="Tanzania"
replace country="Venezuela (Bolivarian Republic of)" 	if country=="Venezuela"
replace country="Viet Nam" 								if country=="Vietnam"
replace country="Russian Federation" 					if country=="Russia"
replace country="State of Palestine" 					if country=="Palestine"
replace country="Lao People's DR"						if country=="Laos"
replace country="Trinidad and Tobago"					if country=="Trinidad And Tobago"

merge m:1 year country using "$pwt/pwt100.dta",keepusing (rgdpo pop)
drop if _merge==2
drop _merge

gen gdppc = rgdpo/pop
gen lngdp = ln(gdppc)
drop rgdpo pop
replace nochild = 100*nochild

keep country year sample nochild age obs gdppc lngdp


save "$data/nochild_baseline_lifecycle_merge.dta",replace
