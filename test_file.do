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
//global raw		"$workplace/experiment_raw"
global pwt			"/Users/weifengdai/Documents/Database/PWT"
************************************************************************************

/*
clear
gen year = .
save "$data/nochild_married_lifecycle_gender.dta",replace


************************************************************************************
// LOOP: read each sample, generate macro level nochild rate
************************************************************************************

global data_no = 0

cd $raw
local files : dir "$raw" files "*.dta"
foreach file in `files'{

//use "$raw/brazil_1970.dta",clear
disp "`file'"

local name = subinstr("`file'",".dta","",.)

disp "`name'"

use "$raw/`name'.dta",clear
// global data_no = $data_no + 1

////////////////////////////////////////////////////////////////////////////////
* sample selection criteria
////////////////////////////////////////////////////////////////////////////////

qui capture drop if marst==0 | marst==9 | marst==. // NIU or missing
qui capture keep if gq==10

////////////////////////////////////////////////////////////////////////////////
* criteria for doing counterfactual: droping the niu in each variables
////////////////////////////////////////////////////////////////////////////////


// child ever born
// qui  drop if inlist(chborn,98,99,.) // NIU or missing

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

save "$tempdata/`name'.dta",replace


////////////////////////////////////////////////////////////////////////////////
use "$tempdata/`name'.dta",clear
qui capture{
// tempdata male_$data_no
keep if sex == 1 // keep the male
drop sploc
foreach var_m of var *{
rename `var_m' `var_m'_m // rename as male variable
}
rename pernum_m sploc
rename serial_m serial
}
save "$tempdata/`name'_male.dta",replace

////////////////////////////////////////////////////////////////////////////////
use "$tempdata/`name'.dta",clear

qui capture{
keep if sex ==2
foreach var_f of var *{
rename `var_f' `var_f'_f // rename as female variable
}
rename serial_f serial
rename sploc_f sploc
}
save "$tempdata/`name'_female.dta",replace

use "$tempdata/`name'_female.dta",clear
//merge 1:1 sploc serial using `male_$data_no',nolabel

// sploc is from the prespective of FEMALE
capture merge 1:1 sploc serial using "$tempdata/`name'_male.dta"
capture{
 keep if _merge==3 // keep the records of matched cohorts
 rename chborn_f chborn
 drop if inlist(chborn,98,99,.)
 gen nochild = (chborn==0)
 rename sploc pernum_m
 }
 
save "$tempdata/`name'_merge.dta",replace



////////////////////////////////////////////////////////////////////////////////
// compute the female lifecycle
////////////////////////////////////////////////////////////////////////////////
use "$tempdata/`name'_merge.dta",clear
qui capture{
// tempdata female_lifecycle_$data_no
 replace age_f = floor(age_f/5)*5
 gen obs = 1 
 collapse (mean) nochild (rawsum) obs [aw=perwt_f], by(country_f year_f sample_f age_f sex_f)
 keep country_f year_f sample_f age_f sex_f nochild
 rename country_f country
 rename year_f year
 rename age_f age
 rename sex_f sex
 rename sample_f sample
//save `female_lifecycle_$data_no'
}

save "$tempdata/`name'_f_lc.dta",replace


////////////////////////////////////////////////////////////////////////////////
// compute the male lifecycle
////////////////////////////////////////////////////////////////////////////////

use "$tempdata/`name'_merge.dta",clear
//tempdata male_lifecycle_$data_no
qui capture{
 replace age_m = floor(age_m/5)*5
 gen obs = 1 
 collapse (mean) nochild (rawsum) obs [aw=perwt_m], by(country_m year_m sample_m age_m sex_m)
 keep country_m year_m sample_m age_m sex_m nochild
 rename country_m country
 rename year_m year
 rename age_m age
 rename sex_m sex
 rename sample_m sample
}

save "$tempdata/`name'_m_lc.dta",replace

qui use "$data/nochild_married_lifecycle_gender.dta",clear
qui capture append using "$tempdata/`name'_f_lc.dta"
qui capture append using "$tempdata/`name'_m_lc.dta"
keep country year sample age sex nochild
drop if country ==.
qui capture save "$data/nochild_married_lifecycle_gender.dta",replace
////////////////////////////////////////////////////////////////////////////////
// erase the redundant files
////////////////////////////////////////////////////////////////////////////////

erase "$tempdata/`name'.dta"
erase "$tempdata/`name'_male.dta"
erase "$tempdata/`name'_female.dta"
erase "$tempdata/`name'_merge.dta"
erase "$tempdata/`name'_f_lc.dta"
erase "$tempdata/`name'_m_lc.dta"

}
*/


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

keep country year sample nochild age sex gdppc lngdp


save "$data/nochild_married_lifecycle_gender_merge.dta",replace
