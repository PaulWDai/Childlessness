/*
Project: Childlessness Across Countries
Date: Aug 6
*/

********************************************************************************
// Directory and Settings
********************************************************************************
clear all 
set more off, perm

global workplace 	"/Users/weifengdai/Documents/Master/2021Summer/Childlessness_Development/Empirics"
global code 		"$workplace/code"
global data 		"$workplace/data"
global figure		"$workplace/figure"
global tex			"$workplace/tex"
	
global raw  		"/Users/weifengdai/Dropbox/IPUMS_I_Data"
global pwt			"/Users/weifengdai/Documents/Database/PWT"

set scheme s1color


********************************************************************************
// 							Childlessness Rate Across Countries
********************************************************************************

////////////////////////////////////////////////////////////////////////////////
// Aggregate level
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Baseline: 25-54 female 
////////////////////////////////////////////////////////////////////////////////

//// figure

use "$data/nochild_baseline_merge_1554.dta",clear

keep if year>=1990
// drop if countrycode == "IRL"

bysort country: egen mean_gdppc = mean(gdppc)
bysort country: egen mean_nochild = mean(nochild)
gen ln_mean_gdppc = ln(mean_gdppc)

sort country year
bysort country: egen min_year = min(year)
gen label = (min_year==year)
 
tw (scatter mean_nochild ln_mean_gdppc, msymbol(D) msize(small)  mlabel(countrycode) mlabsize(vsmall)) ///
(scatter nochild lngdp , mc(green%40) msize(small) msymbol(o))  ///
(qfit mean_nochild ln_mean_gdppc, lc(navy) lwidth(thick )range()) ///
(qfit nochild lngdp, lc(navy%40) lp(_##_) lwidth(thick) range() ) ///
(qfit nochild lngdp if nochild>20, lc(orange) lwidth(thick) range()) ///
(qfit mean_nochild ln_mean_gdppc if mean_nochild>20, lc(orange) lp(_##_) lwidth(thick) range()), ///
xtitle("Logged GDP per Capita") ytitle("Childlessness Rate") title("") ///
xlabel(6(1)12,grid) ylabel(0(10)50,grid) ///
legend(order(1 "Country Average" 2 "Country Year Obs" 3 "Country Avg. Fitted" 4 "Country Year Fitted") rows(1) size(*.6)) 

graph export "$figure/nochild_baseline_1554.pdf",as(pdf) replace

////////////////////////////////////////////////////////////////////////////////
// Robustness: Auxiliary IPUMS-DHS data
////////////////////////////////////////////////////////////////////////////////

use "$data/nochild_baseline_merge_1554.dta",clear
gen data = "IPUMS-I"
drop sample

preserve
tempfile ipums_dhs
use "$data/nochild_dhs_baseline_merge_1554.dta",clear
duplicates drop country year,force
gen data = "IPUMS-DHS"
drop sample
save `ipums_dhs'
restore

append using `ipums_dhs'
keep if year>=1990

duplicates drop country year,force

bysort country: egen mean_gdppc = mean(gdppc)
bysort country: egen mean_nochild = mean(nochild)
gen ln_mean_gdppc = ln(mean_gdppc)

sort country year
bysort country: egen min_year = min(year)
gen label = (min_year==year)

tw (scatter mean_nochild ln_mean_gdppc, msymbol(D) msize(small)  mlabel(countrycode) mlabsize(vsmall)) ///
(scatter nochild lngdp , mc(green%40) msize(small) msymbol(o))  ///
(qfit mean_nochild ln_mean_gdppc, lwidth(thick )range()) ///
(qfit nochild lngdp, lc(navy%40)lp(_##_)lwidth(thick) range() ) ///
(qfit mean_nochild ln_mean_gdppc if mean_nochild >15, lwidth(thick )range()) ///
(qfit nochild lngdp if nochild>15, lc(navy%40)lp(_##_)lwidth(thick) range() ) , ///
xtitle("Logged GDP per Capita") ytitle("Childlessness Rate") title("") ///
xlabel(6(1)12,grid) ylabel(0(10)50,grid) ///
legend(order(1 "Country Average" 2 "Country Year Obs" 3 "Country Avg. Fitted" 4 "Country Year Fitted") rows(1) size(*.6)) 

graph export "$figure/nochild_all_baseline_1554.pdf",as(pdf) replace

tw (scatter nochild lngdp if data == "IPUMS-I", mc(%40) msize(medium) msymbol(o))  ///
(scatter nochild lngdp if data == "IPUMS-DHS", mc(%40) msize(medium) msymbol(s)),  ///
xtitle("Logged GDP per Capita") ytitle("Childlessness Rate") title("") ///
xlabel(6(1)12,grid) ylabel(0(10)50,grid) ///
legend(order(1 "IPUMS-I" 2 "IPUMS-DHS") rows(1) size(*.6)) 

graph export "$figure/nochild_ipums_i_dhs_baseline_1554.pdf",as(pdf) replace

////////////////////////////////////////////////////////////////////////////////
// Robustness: 45-54 female
////////////////////////////////////////////////////////////////////////////////


//// figure

/*
use "$data/nochild_baseline_merge_4554.dta",clear


bysort country: egen mean_gdppc = mean(gdppc)
bysort country: egen mean_nochild = mean(nochild)
gen ln_mean_gdppc = ln(mean_gdppc)

sort country year
bysort country: egen min_year = min(year)
gen label = (min_year==year)
 
tw (scatter mean_nochild ln_mean_gdppc, msymbol(D) msize(small)  mlabel(countrycode) mlabsize(vsmall)) ///
(scatter nochild lngdp , mc(green%40) msize(small) msymbol(o))  ///
(qfit mean_nochild ln_mean_gdppc, lwidth(thick )range()) ///
(qfit nochild lngdp, lc(navy%40)lp(_##_)lwidth(thick) range() ), ///
xtitle("Logged GDP per Capita") ytitle("Percentage") title("Childlessness Rate: Aged 45-54") ///
xlabel(6(1)11,grid) ylabel(0(10)50,grid) ///
legend(order(1 "Country Average" 2 "Country Year Obs" 3 "Country Avg. Fitted" 4 "Country Year Fitted") rows(1) size(*.6)) 

graph export "$figure/nochild_baseline_4554.pdf",as(pdf) replace

gen lngdp2 = lngdp^2
//// regression
reg nochild lngdp lngdp2
reg mean_nochild ln_mean_gdppc
*/


////////////////////////////////////////////////////////////////////////////////
// Demographical subgroups
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Baseline: 15-54 female
////////////////////////////////////////////////////////////////////////////////


global reg_file "$tex/reg_year_order2_subgroups.tex"

//// urban/rural
use "$data/nochild_urban_merge_1554.dta",clear

drop if count < 500
keep if year >= 1990

bysort country: egen mean_gdppc = mean(gdppc)
bysort country: egen mean_nochild = mean(nochild)
gen ln_mean_gdppc = ln(mean_gdppc)

gen lngdp2 = lngdp^2
gen ln_mean_gdppc2 = ln_mean_gdppc^2



foreach urb of numlist 1 2{

reg nochild lngdp lngdp2 if urban ==`urb'
matrix list r(table)
matrix table = r(table)
scalar p1_urban_cy_`urb'= table[4,1]
scalar p2_urban_cy_`urb' = table[4,2]
scalar b1_urban_cy_`urb' = table[1,1]
scalar b2_urban_cy_`urb' = table[1,2]
scalar sym_urban_cy_`urb' = -b1_urban_cy_`urb'/(2*b2_urban_cy_`urb')


reg mean_nochild ln_mean_gdppc ln_mean_gdppc2 if urban == `urb'
matrix list r(table)
matrix table = r(table)
scalar p1_urban_av_`urb'= table[4,1]
scalar p2_urban_av_`urb' = table[4,2]
scalar b1_urban_av_`urb' = table[1,1]
scalar b2_urban_av_`urb' = table[1,2]
scalar sym_urban_av_`urb' = -b1_urban_av_`urb'/(2*b2_urban_av_`urb')

}



//// education
use "$data/nochild_education_merge_1554.dta",clear

drop if count < 500
keep if year >= 1990

bysort country: egen mean_gdppc = mean(gdppc)
bysort country: egen mean_nochild = mean(nochild)
gen ln_mean_gdppc = ln(mean_gdppc)

gen lngdp2 = lngdp^2
gen ln_mean_gdppc2 = ln_mean_gdppc^2


foreach edu of numlist 1 2 3 4{

reg nochild lngdp lngdp2 if edattain ==`edu'
matrix list r(table)
matrix table = r(table)
scalar p1_edattain_cy_`edu'= table[4,1]
scalar p2_edattain_cy_`edu' = table[4,2]
scalar b1_edattain_cy_`edu' = table[1,1]
scalar b2_edattain_cy_`edu' = table[1,2]
scalar sym_edattain_cy_`edu' = -b1_edattain_cy_`edu'/(2*b2_edattain_cy_`edu')


reg mean_nochild ln_mean_gdppc ln_mean_gdppc2 if edattain == `edu'
matrix list r(table)
matrix table = r(table)
scalar p1_edattain_av_`edu'= table[4,1]
scalar p2_edattain_av_`edu' = table[4,2]
scalar b1_edattain_av_`edu' = table[1,1]
scalar b2_edattain_av_`edu' = table[1,2]
scalar sym_edattain_av_`edu' = -b1_edattain_av_`edu'/(2*b2_edattain_av_`edu')


}


//// ever_married
use "$data/nochild_ever_married_merge_1554.dta",clear

drop if count < 500
keep if year >= 1990

bysort country: egen mean_gdppc = mean(gdppc)
bysort country: egen mean_nochild = mean(nochild)
gen ln_mean_gdppc = ln(mean_gdppc)

gen lngdp2 = lngdp^2
gen ln_mean_gdppc2 = ln_mean_gdppc^2

foreach ever of numlist 0 1{

reg nochild lngdp lngdp2 if ever ==`ever'
matrix list r(table)
matrix table = r(table)
scalar p1_ever_cy_`ever'= table[4,1]
scalar p2_ever_cy_`ever' = table[4,2]
scalar b1_ever_cy_`ever' = table[1,1]
scalar b2_ever_cy_`ever' = table[1,2]
scalar sym_ever_cy_`ever' = -b1_ever_cy_`ever'/(2*b2_ever_cy_`ever')


reg mean_nochild ln_mean_gdppc ln_mean_gdppc2 if ever == `ever'
matrix list r(table)
matrix table = r(table)
scalar p1_ever_av_`ever'= table[4,1]
scalar p2_ever_av_`ever' = table[4,2]
scalar b1_ever_av_`ever' = table[1,1]
scalar b2_ever_av_`ever' = table[1,2]
scalar sym_ever_av_`ever' = -b1_ever_av_`ever'/(2*b2_ever_av_`ever')


}


//// employed and unemployed




use "$data/nochild_employment_merge_1554.dta",clear


drop if count < 500
keep if year >= 1990

bysort country: egen mean_gdppc = mean(gdppc)
bysort country: egen mean_nochild = mean(nochild)
gen ln_mean_gdppc = ln(mean_gdppc)

gen lngdp2 = lngdp^2
gen ln_mean_gdppc2 = ln_mean_gdppc^2



foreach emp of numlist 1 2 3{


reg nochild lngdp lngdp2 if empstat ==`emp'
matrix list r(table)
matrix table = r(table)
scalar p1_emp_cy_`emp'= table[4,1]
scalar p2_emp_cy_`emp' = table[4,2]
scalar b1_emp_cy_`emp' = table[1,1]
scalar b2_emp_cy_`emp' = table[1,2]
scalar sym_emp_cy_`emp' = -b1_emp_cy_`emp'/(2*b2_emp_cy_`emp')


reg mean_nochild ln_mean_gdppc ln_mean_gdppc2 if empstat == `emp'
matrix list r(table)
matrix table = r(table)
scalar p1_emp_av_`emp'= table[4,1]
scalar p2_emp_av_`emp' = table[4,2]
scalar b1_emp_av_`emp' = table[1,1]
scalar b2_emp_av_`emp' = table[1,2]
scalar sym_emp_av_`emp' = -b1_emp_av_`emp'/(2*b2_emp_av_`emp')


}





// Output of tex file
global reg_file "$tex/reg_year_order2_subgroups.tex"


file open regfile using $reg_file , write replace
file write regfile ///
"\begin{table}[t]\centering" _n ///
"\small" _n ///
"\caption{Coefficients: of Childlessness Rates by Subgroups}" _n ///
"\label{table: Coefficients: of Childlessness Rates by Subgroups}" _n ///
"\begin{tabular}{lccccccccccc}" _n ///
"\toprule" _n ///
"	& \multicolumn{5}{c}{Country Year} & & \multicolumn{5}{c}{Country Average}  \\" _n ///
"\cmidrule(lr){2-6} \cmidrule(lr){8-12} "  _n ///
"	& $\beta_1$ &" "p val." "& $\beta_2$ & p val. & Ax. Sym. & & $\beta_1$ & p val. & $\beta_2$ & p val. & Ax. Sym. \\" _n ///
"\midrule" 

// urban: urban ==2, rural: urban ==1
file write regfile "& \multicolumn{11}{c}{\it Panel A: Urban/Rural Status}  \\" _n
file write regfile "\cmidrule(lr){2-12}" _n
file write regfile "Rural"  "&" %8.2f (b1_urban_cy_1) "&" %8.2f (p1_urban_cy_1) "&"  %8.2f (b2_urban_cy_1) "&" %8.2f (p2_urban_cy_1) "&" %8.2f (sym_urban_cy_1) "& &" %8.2f (b1_urban_av_1) "&" %8.2f (p1_urban_av_1) "&"  %8.2f (b2_urban_av_1) "&" %8.2f (p2_urban_av_1) "&" %8.2f (sym_urban_av_1)  "\\" _n
file write regfile "Urban"  "&" %8.2f (b1_urban_cy_2) "&" %8.2f (p1_urban_cy_2) "&"  %8.2f (b2_urban_cy_2) "&" %8.2f (p2_urban_cy_2) "&" %8.2f (sym_urban_cy_2) "& &" %8.2f (b1_urban_av_2) "&" %8.2f (p1_urban_av_2) "&"  %8.2f (b2_urban_av_2) "&" %8.2f (p2_urban_av_2) "&" %8.2f (sym_urban_av_2)  "\\" _n
// edattain:
file write regfile "& \multicolumn{11}{c}{\it Panel B: Education Attainment} \\" _n
file write regfile "\cmidrule(lr){2-12}" _n
file write regfile "Less Than Primary"  "&" %8.2f (b1_edattain_cy_1) "&" %8.2f (p1_edattain_cy_1) "&"  %8.2f (b2_edattain_cy_1) "&" %8.2f (p2_edattain_cy_1) "&" %8.2f (sym_edattain_cy_1) "& &" %8.2f (b1_edattain_av_1) "&" %8.2f (p1_edattain_av_1) "&"  %8.2f (b2_edattain_av_1) "&" %8.2f (p2_edattain_av_1) "&" %8.2f (sym_edattain_av_1)  "\\" _n
file write regfile "Primary Completed"  "&" %8.2f (b1_edattain_cy_2) "&" %8.2f (p1_edattain_cy_2) "&"  %8.2f (b2_edattain_cy_2) "&" %8.2f (p2_edattain_cy_2) "&" %8.2f (sym_edattain_cy_2) "& &" %8.2f (b1_edattain_av_2) "&" %8.2f (p1_edattain_av_2) "&"  %8.2f (b2_edattain_av_2) "&" %8.2f (p2_edattain_av_2) "&" %8.2f (sym_edattain_av_2)  "\\" _n
file write regfile "Secondary Completed"  "&" %8.2f (b1_edattain_cy_3) "&" %8.2f (p1_edattain_cy_3) "&"  %8.2f (b2_edattain_cy_3) "&" %8.2f (p2_edattain_cy_3) "&" %8.2f (sym_edattain_cy_3) "& &" %8.2f (b1_edattain_av_3) "&" %8.2f (p1_edattain_av_3) "&"  %8.2f (b2_edattain_av_3) "&" %8.2f (p2_edattain_av_3) "&" %8.2f (sym_edattain_av_3)  "\\" _n
file write regfile "University Completed"  "&" %8.2f (b1_edattain_cy_4) "&" %8.2f (p1_edattain_cy_4) "&"  %8.2f (b2_edattain_cy_4) "&" %8.2f (p2_edattain_cy_4) "&" %8.2f (sym_edattain_cy_4) "& &" %8.2f (b1_edattain_av_4) "&" %8.2f (p1_edattain_av_4) "&"  %8.2f (b2_edattain_av_4) "&" %8.2f (p2_edattain_av_4) "&" %8.2f (sym_edattain_av_4)  "\\" _n
// ever-marred:
file write regfile "& \multicolumn{11}{c}{\it Panel C: Marital Status} \\" _n
file write regfile "\cmidrule(lr){2-12}" _n
file write regfile "Never-Married"  "&" %8.2f (b1_ever_cy_0) "&" %8.2f (p1_ever_cy_0) "&"  %8.2f (b2_ever_cy_0) "&" %8.2f (p2_ever_cy_0) "&" %8.2f (sym_ever_cy_0) "& &" %8.2f (b1_ever_av_0) "&" %8.2f (p1_ever_av_0) "&"  %8.2f (b2_ever_av_0) "&" %8.2f (p2_ever_av_0) "&" %8.2f (sym_ever_av_0)  "\\" _n
file write regfile "Ever-Married"  "&" %8.2f (b1_ever_cy_1) "&" %8.2f (p1_ever_cy_1) "&"  %8.2f (b2_ever_cy_1) "&" %8.2f (p2_ever_cy_1) "&" %8.2f (sym_ever_cy_1) "& &" %8.2f (b1_ever_av_1) "&" %8.2f (p1_ever_av_1) "&"  %8.2f (b2_ever_av_1) "&" %8.2f (p2_ever_av_1) "&" %8.2f (sym_ever_av_1)  "\\" _n
// empstat

file write regfile "& \multicolumn{11}{c}{\it Panel D: Employment Status} \\" _n
file write regfile "\cmidrule(lr){2-12}" _n
file write regfile "Employed"  "&" %8.2f (b1_emp_cy_1) "&" %8.2f (p1_emp_cy_1) "&"  %8.2f (b2_emp_cy_1) "&" %8.2f (p2_emp_cy_1) "&" %8.2f (sym_emp_cy_1) "& &" %8.2f (b1_emp_av_1) "&" %8.2f (p1_emp_av_1) "&"  %8.2f (b2_emp_av_1) "&" %8.2f (p2_emp_av_1) "&" %8.2f (sym_emp_av_1)  "\\" _n
file write regfile "Unemployed"  "&" %8.2f (b1_emp_cy_2) "&" %8.2f (p1_emp_cy_2) "&"  %8.2f (b2_emp_cy_2) "&" %8.2f (p2_emp_cy_2) "&" %8.2f (sym_emp_cy_2) "& &" %8.2f (b1_emp_av_2) "&" %8.2f (p1_emp_av_2) "&"  %8.2f (b2_emp_av_2) "&" %8.2f (p2_emp_av_2) "&" %8.2f (sym_emp_av_2)  "\\" _n
file write regfile "Inactive"  "&" %8.2f (b1_emp_cy_3) "&" %8.2f (p1_emp_cy_3) "&"  %8.2f (b2_emp_cy_3) "&" %8.2f (p2_emp_cy_3) "&" %8.2f (sym_emp_cy_3) "& &" %8.2f (b1_emp_av_3) "&" %8.2f (p1_emp_av_3) "&"  %8.2f (b2_emp_av_3) "&" %8.2f (p2_emp_av_3) "&" %8.2f (sym_emp_av_3)  "\\" _n


file write regfile "\bottomrule" _n ///
"\end{tabular}" _n ///
"\end{table}" _n

file close regfile








********************************************************************************
// 							Life Cycle Childlessness Rate
********************************************************************************

////////////////////////////////////////////////////////////////////////////////
// Baseline
////////////////////////////////////////////////////////////////////////////////
use "$data/nochild_baseline_lifecycle_merge.dta",clear
keep if year >=1990
drop if age > = 90
keep if count > = 100
gen incgroup = .
replace incgroup = 1 if gdppc <=5500
replace incgroup = 2 if gdppc > 5500 & gdppc <15200
replace incgroup = 3 if gdppc >=15200

collapse (mean) nochild, by(age incgroup)
sort incgroup age

keep if age <=55

tw (conn nochild age if incgroup ==1, ///
m(O) msize(medium) lp(-.-) lw(medthick)) ///
(conn nochild age if incgroup ==2, ///
m(D) msize(medium) lp(_##) lw(medthick)) ///
(conn nochild age if incgroup ==3, ///
m(S) msize(medium) lp() lw(medthick)), ///
xlabel(15(5)55,grid) ///
ylabel(0(10)90,grid) ///
legend(order(1 "Low-income" 2 "Middle-income" 3 "High-income") rows(1) size(*.8)) ///
ytitle("") xtitle("Age") ///
title("")

graph export "$figure/nochild_baseline_lifecycle.pdf",as(pdf) replace


////////////////////////////////////////////////////////////////////////////////
// Education Subgroups
////////////////////////////////////////////////////////////////////////////////

// Without income group
use "$data/nochild_education_lifecycle_merge.dta",clear
keep if year >= 1990
drop if age > = 90
keep if count > = 100
gen incgroup = .
replace incgroup = 1 if gdppc <=5500
replace incgroup = 2 if gdppc > 5500 & gdppc <15200
replace incgroup = 3 if gdppc >=15200


preserve
keep if age<=55

collapse (mean) nochild, by(age edattain)

tw (conn nochild age if edattain ==1, ///
m(O) msize(medium) lp(-.-) lw(medthick)) ///
(conn nochild age if edattain ==2, ///
m(D) msize(medium) lp(_##) lw(medthick)) ///
(conn nochild age if edattain ==3, ///
m(S) msize(medium) lp(_-_) lw(medthick)) ///
(conn nochild age if edattain ==4, ///
m(T) msize(medium) lp() lw(medthick)), ///
xlabel(15(5)55,grid) ///
ylabel(0(20)100,grid) ///
legend(order(1 "<Primary" 2 "Primary" 3 "Secondary" 4 "University") rows(1) size(*.8)) ///
ytitle("") xtitle("Age") ///
title("Education")

graph export "$figure/nochild_education_lifecycle.pdf", as(pdf) replace

restore

// With income group
preserve
collapse (mean) nochild, by(age incgroup edattain)

/*
tw (conn nochild age if incgroup ==1 & edattain ==1, ///
m(O) msize(medium) lp(-.-) lw(medthick)) ///
(conn nochild age if incgroup ==2 & edattain ==1, ///
m(D) msize(medium) lp(_##) lw(medthick)) ///
(conn nochild age if incgroup ==3 & edattain ==1, ///
m(S) msize(medium) lp() lw(medthick)), ///
xlabel(15(5)55,grid) ///
ylabel(0(10)90,grid) ///
legend(order(1 "Low-income" 2 "Middle-income" 3 "High-income") rows(1) size(*.8)) ///
ytitle("") xtitle("Age") ///
title("")

*/


keep if age<=55

foreach inc of numlist 1 2 3{
if `inc' ==1{
local inc_graph_title "Low-income"
}
if `inc' ==2{
local inc_graph_title "Middle-income"
}
if `inc' ==3{
local inc_graph_title "High-income"
}

tw (conn nochild age if incgroup ==`inc' & edattain ==1, ///
m(O) msize(medium) lp(-.-) lw(medthick)) ///
(conn nochild age if incgroup ==`inc' & edattain ==2, ///
m(D) msize(medium) lp(_##) lw(medthick)) ///
(conn nochild age if incgroup ==`inc' & edattain ==3, ///
m(S) msize(medium) lp(_-_) lw(medthick)) ///
(conn nochild age if incgroup ==`inc' & edattain ==4, ///
m(T) msize(medium) lp() lw(medthick)), ///
xlabel(15(5)55,grid) ///
ylabel(0(20)100,grid) ///
legend(order(1 "<Primary" 2 "Primary" 3 "Secondary" 4 "University") rows(1) size(*.8)) ///
ytitle("") xtitle("Age") ///
title("`inc_graph_title'")

graph export "$figure/nochild_education_lifecycle_`inc'.pdf", as(pdf) replace

}
restore

////////////////////////////////////////////////////////////////////////////////
// Urban/ Rural Status Subgroups
////////////////////////////////////////////////////////////////////////////////
use "$data/nochild_urban_lifecycle_merge.dta",clear

keep if year >= 1990
drop if age > = 90
keep if count > = 100
gen incgroup = .
replace incgroup = 1 if gdppc <=5500
replace incgroup = 2 if gdppc > 5500 & gdppc <15200
replace incgroup = 3 if gdppc >=15200

preserve
keep if age<=55
collapse (mean) nochild, by(age urban)

tw (conn nochild age if urban ==1, ///
m(O) msize(medium) lp(-.-) lw(medthick)) ///
(conn nochild age if urban ==2, ///
m(D) msize(medium) lp(_##) lw(medthick)), ///
xlabel(15(5)55,grid) ///
ylabel(0(20)100,grid) ///
legend(order(1 "Rural" 2 "Urban" ) rows(1) size(*.8)) ///
ytitle("") xtitle("Age") ///
title("Urban/Rural Residence")

graph export "$figure/nochild_urban_lifecycle.pdf", as(pdf) replace
restore

// With income group
preserve
collapse (mean) nochild, by(age incgroup urban)


keep if age<=55

sort incgroup urban age
foreach inc of numlist 1 2 3{
if `inc' ==1{
local inc_graph_title "Low-income"
}
if `inc' ==2{
local inc_graph_title "Middle-income"
}
if `inc' ==3{
local inc_graph_title "High-income"
}

tw (conn nochild age if incgroup ==`inc' & urban ==1, ///
m(O) msize(medium) lp(-.-) lw(medthick)) ///
(conn nochild age if incgroup ==`inc' & urban ==2, ///
m(D) msize(medium) lp(_##) lw(medthick)), ///
xlabel(15(5)55,grid) ///
ylabel(0(20)100,grid) ///
legend(order(1 "Rural" 2 "Urban") rows(1) size(*.8)) ///
ytitle("") xtitle("Age") ///
title("`inc_graph_title'")
graph export "$figure/nochild_urban_lifecycle_`inc'.pdf", as(pdf) replace
}
restore


////////////////////////////////////////////////////////////////////////////////
// Marital Status
////////////////////////////////////////////////////////////////////////////////
use "$data/nochild_ever_married_lifecycle_merge.dta",clear

keep if year >= 1990
drop if age > = 90
keep if count > = 100
gen incgroup = .
replace incgroup = 1 if gdppc <=5500
replace incgroup = 2 if gdppc > 5500 & gdppc <15200
replace incgroup = 3 if gdppc >=15200

preserve
keep if age<=55
collapse (mean) nochild, by(age ever_married)

tw (conn nochild age if ever_married ==1, ///
m(O) msize(medium) lp(-.-) lw(medthick)) ///
(conn nochild age if ever_married ==0, ///
m(D) msize(medium) lp(_##) lw(medthick)), ///
xlabel(15(5)55,grid) ///
ylabel(0(20)100,grid) ///
legend(order(1 "Ever-married" 2 "Never-married" ) rows(1) size(*.8)) ///
ytitle("") xtitle("Age") ///
title("Marital Status")

graph export "$figure/nochild_ever_married_lifecycle.pdf", as(pdf) replace
restore

// With income group
preserve
collapse (mean) nochild, by(age incgroup ever_married)


keep if age<=55

sort incgroup ever_married age
foreach inc of numlist 1 2 3{
if `inc' ==1{
local inc_graph_title "Low-income"
}
if `inc' ==2{
local inc_graph_title "Middle-income"
}
if `inc' ==3{
local inc_graph_title "High-income"
}

tw (conn nochild age if incgroup ==`inc' & ever_married ==1, ///
m(O) msize(medium) lp(-.-) lw(medthick)) ///
(conn nochild age if incgroup ==`inc' & ever_married ==0, ///
m(D) msize(medium) lp(_##) lw(medthick)), ///
xlabel(15(5)55,grid) ///
ylabel(0(20)100,grid) ///
legend(order(1 "Ever-married" 2 "Never-married") rows(1) size(*.8)) ///
ytitle("") xtitle("Age") ///
title("`inc_graph_title'")
graph export "$figure/nochild_ever_married_lifecycle_`inc'.pdf", as(pdf) replace
}
restore

////////////////////////////////////////////////////////////////////////////////
// Employment Status
////////////////////////////////////////////////////////////////////////////////

use "$data/nochild_employment_lifecycle_merge.dta",clear
drop if empstat ==3

keep if year >= 1990
drop if age > = 90
keep if count > = 100
gen incgroup = .
replace incgroup = 1 if gdppc <=5500
replace incgroup = 2 if gdppc > 5500 & gdppc <15200
replace incgroup = 3 if gdppc >=15200

preserve
keep if age<=55
collapse (mean) nochild, by(age empstat)

tw (conn nochild age if empstat ==1, ///
m(O) msize(medium) lp(-.-) lw(medthick)) ///
(conn nochild age if empstat ==2, ///
m(D) msize(medium) lp(_##) lw(medthick)), ///
xlabel(15(5)55,grid) ///
ylabel(0(20)100,grid) ///
legend(order(1 "Employed" 2 "Unemployed" ) rows(1) size(*.8)) ///
ytitle("") xtitle("Age") ///
title("Employment")

graph export "$figure/nochild_employment_lifecycle.pdf", as(pdf) replace
restore



// With income group
preserve
collapse (mean) nochild, by(age incgroup empstat)

keep if age<=55

sort incgroup empstat age
foreach inc of numlist 1 2 3{
if `inc' ==1{
local inc_graph_title "Low-income"
}
if `inc' ==2{
local inc_graph_title "Middle-income"
}
if `inc' ==3{
local inc_graph_title "High-income"
}

tw (conn nochild age if incgroup ==`inc' & empstat==1, ///
m(O) msize(medium) lp(-.-) lw(medthick)) ///
(conn nochild age if incgroup ==`inc' & empstat==2, ///
m(D) msize(medium) lp(_##) lw(medthick)), ///
xlabel(15(5)55,grid) ///
ylabel(0(20)100,grid) ///
legend(order(1 "Employed" 2 "Unemployed") rows(1) size(*.8)) ///
ytitle("") xtitle("Age") ///
title("`inc_graph_title'")
graph export "$figure/nochild_employment_lifecycle_`inc'.pdf", as(pdf) replace
}
restore

********************************************************************************
// 					Life Cycle Childlessness, Married by Gender
********************************************************************************
use "$data/nochild_married_lifecycle_gender_merge.dta",clear

keep if year >= 1990
drop if age > = 90
//keep if count > = 100
gen incgroup = .
replace incgroup = 1 if gdppc <=5500
replace incgroup = 2 if gdppc > 5500 & gdppc <15200
replace incgroup = 3 if gdppc >=15200

preserve
collapse (mean) nochild, by(sex age)
keep if age<=55

tw (conn nochild age if sex ==1 , ///
m(O) msize(medium) lp(-.-) lw(medthick)) ///
(conn nochild age if sex==2, ///
m(D) msize(medium) lp(_##) lw(medthick)), ///
xlabel(15(5)55,grid) ///
ylabel(0(10)50,grid) ///
legend(order(1 "Male" 2 "Female") rows(1) size(*.8)) ///
ytitle("") xtitle("Age") ///
title("")
graph export "$figure/nochild_married_lifecycle_gender.pdf", as(pdf) replace

restore

// income group

preserve
collapse (mean) nochild, by(sex age incgroup)
keep if age<=55

sort incgroup sex age

foreach inc of numlist 1 2 3{
if `inc' ==1{
local inc_graph_title "Low-income"
}
if `inc' ==2{
local inc_graph_title "Middle-income"
}
if `inc' ==3{
local inc_graph_title "High-income"
}

tw (conn nochild age if sex ==1 & incgroup == `inc' , ///
m(O) msize(medium) lp(-.-) lw(medthick)) ///
(conn nochild age if sex==2 & incgroup == `inc', ///
m(D) msize(medium) lp(_##) lw(medthick)), ///
xlabel(15(5)55,grid) ///
ylabel(0(10)60,grid) ///
legend(order(1 "Male" 2 "Female") rows(1) size(*.8)) ///
ytitle("") xtitle("Age") ///
title("`inc_graph_title'")
graph export "$figure/nochild_married_lifecycle_gender_`inc'.pdf", as(pdf) replace
}

restore


********************************************************************************
// 					Fertility and Childless Corr.
********************************************************************************
use "$data/nochild_fertility_merge_1554.dta",clear

keep if year >= 1990
// motherhood rate and childlessness rate sum to 1
gen mother = 1 - nochild
gen kid = chborn/mother

egen mean_mother = mean(mother)
egen mean_kid = mean(kid)
egen mean_fert = mean(chborn)

gen exts = (mother-mean_mother)/mean_mother
gen ints = (kid-mean_kid)/mean_kid
gen interact = exts *ints

gen sum  =exts+ints+interact
gen fert = (chborn-mean_fert)/mean_fert

replace exts = exts/sum 
replace ints = ints/sum 
replace interact = interact/sum 

drop mean_* sum



sum exts
return list
scalar mean_exts = r(mean)
sum ints
scalar mean_ints = r(mean)
sum interact
scalar mean_interact = r(mean)

scalar total = mean_exts + mean_ints + mean_interact

// decomposition
global dcmpst_file "$tex/extensive_intensive_interaction.tex"

file open dcmpst_file using $dcmpst_file , write replace
file write dcmpst_file ///
"\begin{table}[t]\centering" _n ///
"\caption{Decomposition of Aggregate Fertility}" _n ///
"\label{table: Decomposition of Aggregate Fertility}" _n ///
"\begin{tabular}{cccc}" _n ///
"\toprule" _n ///
" Extensive  & Intensive & Interaction  & Total \\" _n 
file write dcmpst_file "\midrule" _n 
file write dcmpst_file %8.2f (mean_exts) "&" %8.2f (mean_ints) "&" %8.2f (mean_interact) "&" %8.2f (total) "\\" _n
file write dcmpst_file "\bottomrule" _n ///
"\end{tabular}" _n ///
"\end{table}" _n

file close dcmpst_file



use "$data/nochild_fertility_merge_1554_more.dta",clear

keep if year >= 1990
drop if gdppc ==.
replace nochild = nochild*100
// plot chborn and development relationship

bysort country: egen mean_gdppc = mean(gdppc)
bysort country: egen mean_chborn = mean(chborn)
bysort country: egen mean_nochild = mean(nochild)
gen ln_mean_gdppc = ln(mean_gdppc)

sort country year
bysort country: egen min_year = min(year)
gen label = (min_year==year)
 
// chborn
tw (scatter mean_chborn ln_mean_gdppc, msymbol(D) msize(small)  mlabel(countrycode) mlabsize(vsmall)) ///
(scatter chborn lngdp , mc(green%40) msize(small) msymbol(o))  ///
(lfit mean_chborn ln_mean_gdppc, lwidth(thick )range()) ///
(lfit chborn lngdp, lc(navy%40)lp(_##_)lwidth(thick) range() ), ///
xtitle("Logged GDP per Capita") ytitle("Average No. Children Ever Born") title("") ///
xlabel(6(1)12,grid) ylabel(0(1)5,grid) ///
legend(order(1 "Country Average" 2 "Country Year Obs" 3 "Country Avg. Fitted" 4 "Country Year Fitted") rows(1) size(*.6)) 

graph export "$figure/chborn_baseline_1554_more.pdf",as(pdf) replace

// nochild
tw (scatter mean_nochild ln_mean_gdppc, msymbol(D) msize(small)  mlabel(countrycode) mlabsize(vsmall)) ///
(scatter nochild lngdp , mc(green%40) msize(small) msymbol(o))  ///
(qfit mean_nochild ln_mean_gdppc, lc(navy) lwidth(thick )range()) ///
(qfit nochild lngdp, lc(navy%40) lp(_##_) lwidth(thick) range() ) , ///
xtitle("Logged GDP per Capita") ytitle("Childlessness Rate") title("") ///
xlabel(6(1)12,grid) ylabel(0(10)50,grid) ///
legend(order(1 "Country Average" 2 "Country Year Obs" 3 "Country Avg. Fitted" 4 "Country Year Fitted") rows(1) size(*.6)) 
graph export "$figure/_baseline_1554_more.pdf",as(pdf) replace
/*
********************************************************************************
// 				Counterfactual Childlessness Rates and Development
********************************************************************************

use "$data/nochild_baseline_merge_1554.dta",clear

keep if year>= 1990
// keep if count >= 500
drop if lngdp ==.
xtile lngdp_group = lngdp,   nquantiles(10)  
collapse (mean) nochild, by(lngdp_group)

tw conn nochild lngdp_group


use "$data/nochild_education_merge_1554.dta",clear

use "$data/nochild_baseline_merge_1554.dta",clear

keep if year>= 1990
// keep if count >= 500

drop if lngdp ==.
bysort edattain: egen mean_weight = mean(weight)
gen c_nochild = mean_weight* nochild
collapse (sum) c_nochild, by(country year countrycode sample gdppc lngdp)

xtile lngdp_group = lngdp,   nquantiles(10)  
collapse (mean) c_nochild, by(lngdp_group)

*/


