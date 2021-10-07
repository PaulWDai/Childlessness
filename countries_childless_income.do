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
global pwt			"/Users/weifengdai/Documents/Database/PWT"
************************************************************************************


/*
Brazil: 1970, 1980, 1991, 2000, 2010
Canada: 1971, 1981, 1991, 2001, 2011
Colombia: 1973
Dominican Republic: 1981, 2002
Mauritius: 2000
Mexico: 1970, 1995, 2000
Panama: 1980, 1990, 2010
Puerto Rico: 1970, 1980, 1990, 2000, 2005, 2010
South Africa: 1996, 2001, 2007, 2011
Trinidad and Tobago: 1970, 2000
United States: 1960, 1970, 1980, 1990, 2000, 2005, 2010, 2015
Venezuela: 2001
*/

use "/Users/weifengdai/Documents/Master/2021Summer/Childlessness_Development/Empirics/auxiliary/ipumsi.dta",clear
\

************************************************************************************
// LOOP: read each sample, generate macro level nochild rate
************************************************************************************

cd $raw
local files : dir "$raw" files "*.dta"

/*
"$raw/brazil_1970.dta" "$raw/brazil_1980.dta" "$raw/brazil_1991.dta" "$raw/brazil_2010.dta"  
"canada_1971.dta" "canada_1981.dta" "canada_1991.dta" "canada_2001.dta" "canada_2011.dta" ///
"Colombia_1973.dta" ///
"dominican_republic_1981.dta" "dominican_republic_2002.dta" ///
"mauritius_2000.dta" ///
"mexico_1970.dta" "mexico_1995.dta" "mexico_2000.dta" ///
"panama_1980.dta" "panama_1990.dta" "panama_2010.dta" ///
"puerto_rico_1970.dta" "puerto_rico_1980.dta" "puerto_rico_1990.dta" "puerto_rico_2000.dta" "puerto_rico_2005.dta" "puerto_rico_2010.dta" ///
"south_africa_1996.dta" "south_africa_2001.dta" "south_africa_2007.dta" "south_africa_2011.dta" ///
"trinidad_and_tobago_1970.dta" "trinidad_and_tobago_1970.dta" "trinidad_and_tobago_2000.dta" ///
"united_states_1960.dta" "united_states_1970.dta" "united_states_1980.dta" "united_states_1990.dta" "united_states_2000.dta" "united_states_2005.dta" "united_states_2010.dta" "united_states_2015.dta" ///
"venezuela_2001.dta"
*/



////////////////////////////////////////////////////////////////////////////////
* sample selection criteria
////////////////////////////////////////////////////////////////////////////////

// only keep country year with income information
// qui capture drop if inctot ==. 

qui drop if marst==0 | marst==9 | marst==. // NIU or missing
qui capture keep if gq==10

////////////////////////////////////////////////////////////////////////////////
* criteria for doing counterfactual: droping the niu in each variables
////////////////////////////////////////////////////////////////////////////////

// sex
qui capture keep if sex==2

// child ever born
qui capture drop if inlist(chborn,98,99,.) // NIU or missing

// employment
qui capture drop if empstat==0 | empstat==9 | empstat==. // NIU or missing
// age
qui capture keep if age>=15 & age<=54 // prime aged
// education
qui capture drop if edattain==0 | edattain==9| edattain==. // NIU or missing
// urban
qui capture keep if urban==1 |urban==2 

////////////////////////////////////////////////////////////////////////////////
* specific criteria for this exercise
////////////////////////////////////////////////////////////////////////////////
// create the age bin
qui capture replace age = floor(age/5)*5
qui capture gen nochild = (chborn==0)
qui capture gen married = (marst==2)
qui capture gen ever_married = inlist(marst,2,3,4)
// qui capture collapse (mean) nochild [aw=perwt], by(country year sample)
qui append using "$data/nochild_countries.dta",nolabel
qui drop if inctot ==.
qui save "$data/nochild_countries.dta",replace

}

use "$data/nochild_countries.dta",clear
\


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

gen gdppc = rgdpo/pop
gen lngdp = ln(gdppc)
drop rgdpo pop
replace nochild = 100*nochild

keep country year countrycode sample nochild gdppc lngdp

save "$data/nochild_baseline_merge_1554.dta",replace
