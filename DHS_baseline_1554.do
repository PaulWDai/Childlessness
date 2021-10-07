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
	
global raw  		"/Users/weifengdai/Dropbox/IPUMS_I_Data"
global raw_dhs		"/Users/weifengdai/Documents/Database/IPUMS-DHS/data/Mother"
global pwt			"/Users/weifengdai/Documents/Database/PWT"
************************************************************************************

clear
gen country = .
save "$data/nochild_dhs_baseline_1554.dta",replace

************************************************************************************
// LOOP: read each sample, generate macro level nochild rate
************************************************************************************


cd $raw_dhs
local files : dir "$raw_dhs" files "*.dta"
foreach file in `files'{
use `file',clear
disp "`file'"


qui capture drop if currmarr == . | currmarr == 8
// qui capture keep if gq==10

////////////////////////////////////////////////////////////////////////////////
* criteria for doing counterfactual: droping the niu in each variables
////////////////////////////////////////////////////////////////////////////////

// sex: keep all mother info
// qui capture keep if sex==2

qui capture drop if perweight ==.
// child ever born
qui capture drop if inlist(cheb,98,99,.) // NIU or missing

// employment
// qui capture drop if empstat==0 | empstat==9 | empstat==. // NIU or missing
// age
qui capture keep if age>=15 & age<=54 // prime aged
// education
qui capture drop if inlist(educlvl,8,.) // NIU or missing
// urban
qui capture keep if urban==1 |urban==2 

////////////////////////////////////////////////////////////////////////////////
* specific criteria for this exercise
////////////////////////////////////////////////////////////////////////////////
// create the age bin
qui capture replace age = floor(age/5)*5
qui capture gen nochild = (cheb==0)
qui capture gen married = (currmarr==1)
qui capture gen ever_married = inlist(currmarr,1,2)

qui capture collapse (mean) nochild [aw=perweight], by(country year sample)
qui append using "$data/nochild_dhs_baseline_1554.dta",nolabel
qui save "$data/nochild_dhs_baseline_1554.dta",replace
}


use "$data/nochild_dhs_baseline_1554.dta",clear

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

merge m:1 year country using "$pwt/pwt100.dta",keepusing (rgdpo pop countrycode)
drop if _merge==2
drop _merge

drop if countrycode == ""
gen gdppc = rgdpo/pop
gen lngdp = ln(gdppc)
drop rgdpo pop
replace nochild = 100*nochild

keep country year countrycode sample nochild gdppc lngdp

save "$data/nochild_dhs_baseline_merge_1554.dta",replace
