/*
Produce Figure 2
*/


* import data
use "$hp\Data\Data_MScThesis_Analysis.dta", clear

********************************************************************************
* Figure 1 estimation - OLS Rolling Window for Phllips Curve slope
********************************************************************************
graph drop _all

*choose size of rolling window (number of years - 1)
local window = 19

*Data Management - prepare to also have the 10-year CPI mean
xtset id year
gen ldlcpi = l.dlcpi
gen avgdp = 0
gen avgtrade = 0
gen avgquinn = 0
forvalues y = 1900(1)2021{
	local ywindow = `y'-`window'
	sum dlcpi if year<=`y'& year>=`ywindow' & dlcpi < 300
	replace avgdp = r(mean)/10 if year==`y'
	
	sum trade if year<=`y'& year>=`ywindow'
	replace avgtrade = r(mean) if year==`y'
	
	sum openquinn if year<=`y'& year>=`ywindow'
	replace avgquinn = r(mean) if year==`y'
}


preserve 
********************************************************************************
* Estimates OLS rolling window
********************************************************************************
bysort year (id): gen pick = _n == 1
gen high = cond(pick, year, -99)

program drop _all
program mypanel
    xtset id year
    gen year1 = r(tmin)
    cap noi reghdfe dlwage unemp ldlcpi, vce(cluster id) absorb(id) nocons
    if _rc exit
    gen obs = e(N)
    foreach v in unemp ldlcpi{
        gen b_`v' = _b[`v']
		gen up_`v' = _b[`v'] + invnormal(1-0.10)*_se[`v']
		gen low_`v' = _b[`v'] - invnormal(1-0.10)*_se[`v']
    }
	cap noi reghdfe dlwage unemp ldlcpi expectation, vce(cluster id) absorb(id) nocons
    if _rc exit
    *gen obs = e(N)
    foreach v in unemp ldlcpi{
        gen b_`v'_exp = _b[`v']
		gen up_`v'_exp = _b[`v'] + invnormal(1-0.10)*_se[`v']
		gen low_`v'_exp = _b[`v'] - invnormal(1-0.10)*_se[`v']
    }
end

local nwindow = -`window'
rangerun mypanel, interval (year `nwindow' high) verbose

********************************************************************************
* Figure 1 - produce graphism
********************************************************************************

* create variables to highlight different historical periods (max and min of slope estimate)
gen t=1
gen tt=-2
gen zero=0


else if ($slides == 0) {
* Figure for paper
twoway (rarea t tt year if (year>=1900 & year<=1913), color(gs15*0.95)) (rarea t tt year if (year>=1946 & year<=1971), color(gs15*0.95)) ///
	(rarea t tt year if (year>=1995), color(gs15*0.95)) (rarea up_unemp low_unemp year if year>=1900 & year <=2020, color(gs12)) ///
	(line avgdp year if year>=1900 & year <=2020 & id==1, color(gs1) lpattern("-") lwidth(thick) yaxis(2) ytitle("CPI Inflation", axis(2)) ylabel(-2 " " 0 " 0%" 0.5 " 5%" 1 "10%", notick axis(2) angle(0))) ///
	(line zero year if year>=1900 & year <=2020, xlabel(1900(20)2020) lcolor(gs1)) (line b_unemp year if year>=1900 & year <=2020, lpattern(solid) lwidth(thick) /*name(TR1)*/ yaxis(1) xsize(6) ysize(3) /// 
	legend( order(7 "CPI inflation" 6 "Slope") ring(0) position(4) ) scale(1.5) ylabel(, angle(0)) ytitle("Slope") xtitle("") lcolor(olive))
graph export `"$Fig\RW_dwn_OLS.pdf"', replace

replace t=1
replace tt=-1

* Figure for paper
twoway (rarea t tt year if (year>=1900 & year<=1913), color(gs15*0.95)) (rarea t tt year if (year>=1946 & year<=1971), color(gs15*0.95)) ///
	(rarea t tt year if (year>=1995), color(gs15*0.95)) (rarea up_ldlcpi_exp low_ldlcpi_exp year if year>=1990 & year <=2020, color(eltblue)) (rarea up_ldlcpi low_ldlcpi year if year>=1900 & year <=2020, color(gs12)) ///
	(line avgdp year if year>=1900 & year <=2020 & id==1, color(gs1) lpattern("-") lwidth(thick) yaxis(2) ytitle("CPI Inflation", axis(2)) ylabel(-1 " " 0 " 0%" 0.5 " 5%" 1 "10%", notick axis(2) angle(0))) ///
	(line b_ldlcpi_exp year if year>=1990 & year <=2020, lpattern(solid) lcolor(blue) yaxis(1)) ///
	(line zero year if year>=1900 & year <=2020, xlabel(1900(20)2020) lcolor(gs1)) (line b_ldlcpi year if year>=1900 & year <=2020, lpattern(solid) lwidth(thick) /*name(TR1)*/ yaxis(1) xsize(6) ysize(3) /// 
	legend( order(9 "CPI inflation" 8 "Persistence {&gamma}" 6 "Persistence (EXP)") ring(0) position(4) ) scale(1.5) ylabel(, angle(0)) ytitle("Slope") xtitle("") lcolor(olive))
graph export `"$Fig\RW_cpi_OLS.pdf"', replace
}

restore

preserve
********************************************************************************
* Estimates OLS rolling window - with year fixed effects or inflation expectations
********************************************************************************
bysort year (id): gen pick = _n == 1
gen high = cond(pick, year, -99)

program drop _all
program mypanel
    xtset id year
    gen year1 = r(tmin)
    cap noi reghdfe dlwage unemp ldlcpi, vce(cluster id) absorb(id year) nocons
    if _rc exit
    gen obs = e(N)
    foreach v in unemp ldlcpi{
        gen b_`v' = _b[`v']
		gen up_`v' = _b[`v'] + invnormal(1-0.10)*_se[`v']
		gen low_`v' = _b[`v'] - invnormal(1-0.10)*_se[`v']
    }
	cap noi reghdfe dlwage unemp ldlcpi expectation, vce(cluster id) absorb(id) nocons
    if _rc exit
    *gen obs = e(N)
    foreach v in unemp ldlcpi{
        gen b_`v'_exp = _b[`v']
		gen up_`v'_exp = _b[`v'] + invnormal(1-0.10)*_se[`v']
		gen low_`v'_exp = _b[`v'] - invnormal(1-0.10)*_se[`v']
    }
end

local nwindow = -`window'
rangerun mypanel, interval (year `nwindow' high) verbose

********************************************************************************
* Figure A.? - produce graphism
********************************************************************************

* create variables to highlight different historical periods (max and min of slope estimate)
gen t=1
gen tt=-2
gen zero=0

* trick to fit axis 2
*replace avgdp = avgdp*2

if ($slides == 1) {
* Figure for slides
twoway (rarea t tt year if (year>=1900 & year<=1913), color(gs15*0.95)) (rarea t tt year if (year>=1946 & year<=1971), color(gs15*0.95)) ///
	(rarea t tt year if (year>=1995), color(gs15*0.95)) (rarea up_unemp low_unemp year if year>=1900 & year <=2020, color(gs12)) ///
	(line avgdp year if year>=1900 & year <=2020 & id==1, color(gs1) lwidth(thick) yaxis(2) ytitle("CPI Inflation", axis(2)) ylabel(-2 " " 0 " 0%" 0.5 "5%" 1 "10%", notick axis(2) angle(0))) ///
	(line zero year if year>=1900 & year <=2020, xlabel(1900(20)2020) lcolor(gs1)) (line b_unemp year if year>=1900 & year <=2020, lpattern(solid) lwidth(thick) /*name(TR1)*/ yaxis(1) xsize(6) ysize(3) /// 
	legend( order(7 "CPI inflation" 6 "Slope") ring(0) position(4) ) scale(1.5) ylabel(, angle(0)) ytitle("Slope") xtitle("") lcolor(olive) graphregion(fcolor(gs15*0.3333)) )
graph export `"$Fig\RW_dwn_OLSS_year.pdf"', replace
}

else if ($slides == 0) {
* Figure for paper
twoway (rarea t tt year if (year>=1900 & year<=1913), color(gs15*0.95)) (rarea t tt year if (year>=1946 & year<=1971), color(gs15*0.95)) ///
	(rarea t tt year if (year>=1995), color(gs15*0.95)) (rarea up_unemp_exp low_unemp_exp year if year>=1990 & year <=2020, color(eltblue)) (rarea up_unemp low_unemp year if year>=1900 & year <=2020, color(gs12)) ///
	(line avgdp year if year>=1900 & year <=2020 & id==1, color(gs1) lpattern("-") lwidth(thick) yaxis(2) ytitle("CPI Inflation", axis(2)) ylabel(-2 " " 0 " 0%" 0.5 " 5%" 1 "10%", notick axis(2) angle(0))) ///
	(line b_unemp_exp year if year>=1990 & year <=2020, lpattern(solid) lcolor(blue) yaxis(1)) ///
	(line zero year if year>=1900 & year <=2020, xlabel(1900(20)2020) lcolor(gs1)) (line b_unemp year if year>=1900 & year <=2020, lpattern(solid) lwidth(thick) /*name(TR1)*/ yaxis(1) xsize(6) ysize(3) /// 
	legend( order(9 "CPI inflation" 8 "Slope (FE)" 6 "Slope (EXP)") ring(0) position(4) ) scale(1.5) ylabel(, angle(0)) ytitle("Slope") xtitle("") lcolor(olive))
graph export `"$Fig\RW_dwn_OLS_year.pdf"', replace

replace t=1
replace tt=-1

* Figure for paper
twoway (rarea t tt year if (year>=1900 & year<=1913), color(gs15*0.95)) (rarea t tt year if (year>=1946 & year<=1971), color(gs15*0.95)) ///
	(rarea t tt year if (year>=1995), color(gs15*0.95)) (rarea up_ldlcpi_exp low_ldlcpi_exp year if year>=1990 & year <=2020, color(eltblue)) (rarea up_ldlcpi low_ldlcpi year if year>=1900 & year <=2020, color(gs12)) ///
	(line avgdp year if year>=1900 & year <=2020 & id==1, color(gs1) lpattern("-") lwidth(thick) yaxis(2) ytitle("CPI Inflation", axis(2)) ylabel(-1 " " 0 " 0%" 0.5 " 5%" 1 "10%", notick axis(2) angle(0))) ///
	(line b_ldlcpi_exp year if year>=1990 & year <=2020, lpattern(solid) lcolor(blue) yaxis(1)) ///
	(line zero year if year>=1900 & year <=2020, xlabel(1900(20)2020) lcolor(gs1)) (line b_ldlcpi year if year>=1900 & year <=2020, lpattern(solid) lwidth(thick) /*name(TR1)*/ yaxis(1) xsize(6) ysize(3) /// 
	legend( order(9 "CPI inflation" 8 "Persistence {&gamma} (FE)" 6 "Persistence {&gamma} (EXP)") ring(0) position(4) ) scale(1.5) ylabel(, angle(0)) ytitle("Slope") xtitle("") lcolor(olive))
graph export `"$Fig\RW_cpi_OLS_year.pdf"', replace
}

restore

preserve 
********************************************************************************
* Estimates OLS rolling window - with population weights
********************************************************************************

*Data Management - prepare to also have the 10-year CPI mean weighted
xtset id year
forvalues y = 1900(1)2021{
	local ywindow = `y'-`window'
	sum dlcpi [aw=pop] if year<=`y'& year>=`ywindow' & dlcpi < 300
	replace avgdp = r(mean)/10 if year==`y'
	
	sum trade [aw=pop] if year<=`y'& year>=`ywindow'
	replace avgtrade = r(mean) if year==`y'
	
	sum openquinn [aw=pop] if year<=`y'& year>=`ywindow'
	replace avgquinn = r(mean) if year==`y'
}




bysort year (id): gen pick = _n == 1
gen high = cond(pick, year, -99)

program drop _all
program mypanel
    xtset id year
    gen year1 = r(tmin)
    cap noi reghdfe dlwage unemp ldlcpi [aw = pop], vce(cluster id) absorb(id) nocons
    if _rc exit
    gen obs = e(N)
    foreach v in unemp ldlcpi{
        gen b_`v' = _b[`v']
		gen up_`v' = _b[`v'] + invnormal(1-0.10)*_se[`v']
		gen low_`v' = _b[`v'] - invnormal(1-0.10)*_se[`v']
    }
	cap noi reghdfe dlwage unemp ldlcpi expectation [aw = pop], vce(cluster id) absorb(id) nocons
    if _rc exit
    *gen obs = e(N)
    foreach v in unemp ldlcpi{
        gen b_`v'_exp = _b[`v']
		gen up_`v'_exp = _b[`v'] + invnormal(1-0.10)*_se[`v']
		gen low_`v'_exp = _b[`v'] - invnormal(1-0.10)*_se[`v']
    }
end

local nwindow = -`window'
rangerun mypanel, interval (year `nwindow' high) verbose

********************************************************************************
* Figure A.4 - produce graphism
********************************************************************************

* create variables to highlight different historical periods (max and min of slope estimate)
gen t=1
gen tt=-2
gen zero=0



* Figure for paper
twoway (rarea t tt year if (year>=1900 & year<=1913), color(gs15*0.95)) (rarea t tt year if (year>=1946 & year<=1971), color(gs15*0.95)) ///
	(rarea t tt year if (year>=1995), color(gs15*0.95)) (rarea up_unemp low_unemp year if year>=1900 & year <=2020, color(gs12)) ///
	(line avgdp year if year>=1900 & year <=2020 & id==1, color(gs1) lpattern("-") lwidth(thick) yaxis(2) ytitle("CPI Inflation", axis(2)) ylabel(-2 " " 0 " 0%" 0.5 " 5%" 1 "10%", notick axis(2) angle(0))) ///
	(line zero year if year>=1900 & year <=2020, xlabel(1900(20)2020) lcolor(gs1)) (line b_unemp year if year>=1900 & year <=2020, lpattern(solid) lwidth(thick) /*name(TR1)*/ yaxis(1) xsize(6) ysize(3) /// 
	legend( order(7 "CPI inflation" 6 "Slope") ring(0) position(4) ) scale(1.5) ylabel(, angle(0)) ytitle("Slope") xtitle("") lcolor(olive))
graph export `"$Fig\RW_dwn_OLS_w.pdf"', replace

replace t=1
replace tt=-1

* Figure for paper
twoway (rarea t tt year if (year>=1900 & year<=1913), color(gs15*0.95)) (rarea t tt year if (year>=1946 & year<=1971), color(gs15*0.95)) ///
	(rarea t tt year if (year>=1995), color(gs15*0.95)) (rarea up_ldlcpi_exp low_ldlcpi_exp year if year>=1990 & year <=2020, color(eltblue)) (rarea up_ldlcpi low_ldlcpi year if year>=1900 & year <=2020, color(gs12)) ///
	(line avgdp year if year>=1900 & year <=2020 & id==1, color(gs1) lpattern("-") lwidth(thick) yaxis(2) ytitle("CPI Inflation", axis(2)) ylabel(-1 " " 0 " 0%" 0.5 " 5%" 1 "10%", notick axis(2) angle(0))) ///
	(line b_ldlcpi_exp year if year>=1990 & year <=2020, lpattern(solid) lcolor(blue) yaxis(1)) ///
	(line zero year if year>=1900 & year <=2020, xlabel(1900(20)2020) lcolor(gs1)) (line b_ldlcpi year if year>=1900 & year <=2020, lpattern(solid) lwidth(thick) /*name(TR1)*/ yaxis(1) xsize(6) ysize(3) /// 
	legend( order(9 "CPI inflation" 8 "Persistence {&gamma}" 6 "Persistence (EXP)") ring(0) position(4) ) scale(1.5) ylabel(, angle(0)) ytitle("Slope") xtitle("") lcolor(olive))
graph export `"$Fig\RW_cpi_OLS_w.pdf"', replace


restore



preserve 
********************************************************************************
* Estimates OLS rolling window - with population weights and 10 year rolling window - referee report
********************************************************************************

*choose size of rolling window (number of years - 1)
local window = 9

*Data Management - prepare to also have the 10-year CPI mean weighted
xtset id year
forvalues y = 1900(1)2021{
	local ywindow = `y'-`window'
	sum dlcpi [aw=pop] if year<=`y'& year>=`ywindow' & dlcpi < 300
	replace avgdp = r(mean)/10 if year==`y'
	
	sum trade [aw=pop] if year<=`y'& year>=`ywindow'
	replace avgtrade = r(mean) if year==`y'
	
	sum openquinn [aw=pop] if year<=`y'& year>=`ywindow'
	replace avgquinn = r(mean) if year==`y'
}




bysort year (id): gen pick = _n == 1
gen high = cond(pick, year, -99)

program drop _all
program mypanel
    xtset id year
    gen year1 = r(tmin)
    cap noi reghdfe dlwage unemp ldlcpi [aw = pop], vce(cluster id) absorb(id) nocons
    if _rc exit
    gen obs = e(N)
    foreach v in unemp ldlcpi{
        gen b_`v' = _b[`v']
		gen up_`v' = _b[`v'] + invnormal(1-0.10)*_se[`v']
		gen low_`v' = _b[`v'] - invnormal(1-0.10)*_se[`v']
    }
	cap noi reghdfe dlwage unemp ldlcpi expectation [aw = pop], vce(cluster id) absorb(id) nocons
    if _rc exit
    *gen obs = e(N)
    foreach v in unemp ldlcpi{
        gen b_`v'_exp = _b[`v']
		gen up_`v'_exp = _b[`v'] + invnormal(1-0.10)*_se[`v']
		gen low_`v'_exp = _b[`v'] - invnormal(1-0.10)*_se[`v']
    }
end

local nwindow = -`window'
rangerun mypanel, interval (year `nwindow' high) verbose

********************************************************************************
* Figure A.? - produce graphism
********************************************************************************

* create variables to highlight different historical periods (max and min of slope estimate)
gen t=2
gen tt=-4
gen zero=0



* Figure for paper
twoway (rarea t tt year if (year>=1900 & year<=1913), color(gs15*0.95)) (rarea t tt year if (year>=1946 & year<=1971), color(gs15*0.95)) ///
	(rarea t tt year if (year>=1995), color(gs15*0.95)) (rarea up_unemp low_unemp year if year>=1900 & year <=2020, color(gs12)) ///
	(line avgdp year if year>=1900 & year <=2020 & id==1, color(gs1) lpattern("-") lwidth(thick) yaxis(2) ytitle("CPI Inflation", axis(2)) ylabel(-4 "" 0 " 0%" 0.5 " 5%" 1 "10%" 1.5 "15%", notick axis(2) angle(0))) ///
	(line zero year if year>=1900 & year <=2020, xlabel(1900(20)2020) lcolor(gs1)) (line b_unemp year if year>=1900 & year <=2020, lpattern(solid) lwidth(thick) /*name(TR1)*/ yaxis(1) xsize(6) ysize(3) /// 
	legend( order(7 "CPI inflation" 6 "Slope") ring(0) position(4) ) scale(1.5) ylabel(, angle(0)) ytitle("Slope") xtitle("") lcolor(olive))
graph export `"$Fig\RW_dwn_OLS_w_10.pdf"', replace


restore
