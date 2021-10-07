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
global tex			"$worplace/tex"
	
global raw  		"/Users/weifengdai/Dropbox/IPUMS_I_Data"
global pwt			"/Users/weifengdai/Documents/Database/PWT"

set scheme s1color

run "$code/baseline_1554"

run "$code/baseline_4554"

run "$code/education_1554"

run "$code/education_4554"

run "$code/urban_1554"

run "$code/urban_4554"

run "$code/baseline_lifecycle"

run "$code/educaiton_lifecycle"

run "$code/urban_lifecycle"

