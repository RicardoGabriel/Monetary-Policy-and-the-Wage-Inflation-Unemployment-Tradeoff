clear all

*Upload data
use "$hp\Data\Data_MScThesis_Analysis.dta", clear

********************************************************************************
* Setup - locals
********************************************************************************

* horizon
local horizon1 5
local horizon2 = $hf
	
* number of lags
local Lags = $lags

* (jj=1) full sample; (jj=2) only post-Bretton Woods
local jj = 1

* (kk=1) only full control set; (kk=2) use specific subset of controls close to Barnichon and Mesters (2020)
local kk = 2

* Sample period years
local c1 year >= 1870                                                                                                                                                                                                                                         
local c2 year  > 1945 
	
* Sample period names
local p1 full
local p2 post

********************************************************************************
* Setup - defining main variables (y, x, z) and controls (W)
********************************************************************************

	* y 
	* if changing this don't forget to adjust controls below (also possible lrgdp lrcon lriy ltrate loansgdp lhpreal)
	local response lunemp lwage
	
	*use level unemployment
	replace lunemp	= unemp
	
	*use wage inflation rate
	replace lwage 	= dlwage
	
	
	*generate variables as its change from t+h relative to t-1
foreach y of local response {
	forvalues i=0/`horizon2' {
		*cap drop `y'`i'
		gen `y'`i' = (f`i'.`y' - l.`y') 
	}
}
	
	/*
	*generate variables as its change from t+h relative to t+h-1 (non-cumulative IRF)
foreach y of local response {
	forvalues i=0/0 {
		*cap drop `y'`i'
		gen `y'`i' = (f`i'.`y' - l.`y') 
	}
	
		forvalues i=1/`horizon2' {
		*cap drop `y'`i'
		local j = `i' - 1
		gen `y'`i' = (f`i'.`y' - f`j'.`y') 
	}
}
	*/
	
	
	* x
	local impulse JSTtrilemmaIV_R

	* z
	local inst JSTtrilemmaIV_R

	*create storage variables
foreach x of local impulse {
	foreach y of local response {
		forvalues k=1/2 {
			forvalues j=1/2 {
		
	cap drop b`k'_`y'`x'_`p`j'' se`k'_`y'`x'_`p`j''
	* setup
	gen b`k'_`y'`x'_`p`j''=.
	gen se`k'_`y'`x'_`p`j''=.
	
			}
		}
	}
}
	



* W - control variables

* Full set of controls
local rhslunemp	l(1/`Lags').dunemp1 l(0/`Lags').dlwage1 l(0/`Lags').dlrcon1 l(0/`Lags').dlrgdp1 l(0/`Lags').dlcpi1 l(1/`Lags').dstir1 l(0/`Lags').dltrate1 ///
				l(1/`Lags').dunemp2 l(0/`Lags').dlwage2 l(0/`Lags').dlrcon2 l(0/`Lags').dlrgdp2 l(0/`Lags').dlcpi2 l(1/`Lags').dstir2 l(0/`Lags').dltrate2  

local rhslwage	l(0/`Lags').dunemp1 l(1/`Lags').dlwage1 l(0/`Lags').dlrcon1 l(0/`Lags').dlrgdp1 l(0/`Lags').dlcpi1 l(1/`Lags').dstir1 l(0/`Lags').dltrate1 ///
				l(0/`Lags').dunemp2 l(1/`Lags').dlwage2 l(0/`Lags').dlrcon2 l(0/`Lags').dlrgdp2 l(0/`Lags').dlcpi2 l(1/`Lags').dstir2 l(0/`Lags').dltrate2 

* Second set of controls only lagged values of unemp, inflation and stir
local rhslunemp2	l(1/`Lags').dunemp1 l(1/`Lags').dlwage1  ///
					l(1/`Lags').dunemp2 l(1/`Lags').dlwage2  

local rhslwage2		l(1/`Lags').dunemp1 l(1/`Lags').dlwage1  ///
					l(1/`Lags').dunemp2 l(1/`Lags').dlwage2 
									
*** add extra variable to the control set - dlsumgdp to capture world business cycles
local fe dlsumgdp	
				
foreach y of local response {

	* controls: (kk=1) full set of controls; (kk=2) only relevant variables [BM]
	local cont1`y' `rhs`y'' `fe' i.id
	local cont2`y' `rhs`y'2' `fe' i.id
}
				
				
********************************************************************************
* Estimation - Impulse Response Functions
********************************************************************************
gen sample=1

forvalues j=1/`jj' {

if ($match) == 1 {
	xi: ivreg2 lwage$hf `instr' `cont2lwage' ///
		if `c`j'' & lunemp$hf !=. & lwage$hf !=. , cluster(id)
	replace sample = e(sample)
}

foreach y of local response {
	foreach x of local impulse {
		forvalues k=1/`kk' { 
			forvalues i=0/`horizon2' {	

		ivreg2 `y'`i' `inst' `cont`k'`y'' if sample==1, cluster(id)
		
		replace b`k'_`y'`x'_`p`j'' = (_b[`inst']) if _n == `i'+1
		replace se`k'_`y'`x'_`p`j'' = _se[`inst'] if _n == `i'+1 
		
			}
		}
	}
}
}


********************************************************************************
* Produce Figures - Impulse Response Functions
********************************************************************************

* Setup - locals
local t1 (a) Full sample
local t2 (b) Post-WW2

local title full set

local tlunemp 	"Unemployment rate"
local tlwage	"Wage inflation"

local ylab_lunemp	"Percentage points"
local ylab_lwage	"Percentage points"

* Setup - auxiliar variables needed for plotting
cap drop zero
local hh = `horizon2' + 1
gen zero = 0 if _n <= `hh'


cap drop up* dn1* dn2*
forvalues j=1/`jj'{
foreach x of local impulse {
	foreach y of local response {
		forvalues k=1/`kk' {

gen up`k'_`y'`x'_`p`j'' = b`k'_`y'`x'_`p`j'' + 1.645*se`k'_`y'`x'_`p`j'' if _n <= `hh'
gen dn`k'_`y'`x'_`p`j'' = b`k'_`y'`x'_`p`j'' - 1.645*se`k'_`y'`x'_`p`j'' if _n <= `hh'

gen up2`k'_`y'`x'_`p`j'' = b`k'_`y'`x'_`p`j'' + 1*se`k'_`y'`x'_`p`j'' if _n <= `hh'
gen dn2`k'_`y'`x'_`p`j'' = b`k'_`y'`x'_`p`j'' - 1*se`k'_`y'`x'_`p`j'' if _n <= `hh'

			
		}
	}
}
}

cap drop Years
gen Years = _n-1 if _n<=`hh'

local ylablwage 	"ylab(-1(0.5)1)"
local ylablunemp  	"ylab(-1(0.5)1)"

* Produce Figures

forvalues j=1/`jj'{
foreach x of local impulse {
	foreach y of local response {
		forvalues k=1/`kk' {
			
		twoway (rarea up`k'_`y'`x'_`p`j'' dn`k'_`y'`x'_`p`j''  Years,  ///
		fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
		(line b`k'_`y'`x'_`p`j'' Years, lcolor(olive) ///
		lpattern(solid) lwidth(thick)) /// 
		(line zero Years, lcolor(black)), ///
		/*ylabel(`l`y''(`c`y'')`h`y'', nogrid) */ ///
		title("`t`y''", color(black) size()) ///
		ytitle("`ylab_`y''", size()) xtitle("Year", size()) ///
		graphregion(fcolor(white)) plotregion(color(white)) ///
		name(`y'`k'`j'`horizon2', replace) nodraw legend(off) `ylab`y''

		*68% CB: fcolor(gs15) lcolor(gs15) lw(none) lpattern(solid)) (rarea up2`k'_`y'`x'_`p`j'' dn2`k'_`y'`x'_`p`j''  Years,  ///
		
		}
	}
}

forvalues k=1/`kk'{
graph combine lunemp`k'`j'`horizon2' lwage`k'`j'`horizon2', ///
	rows(1) cols(2) ysize(1.5) xsize(3) imargin(tiny) scale(1.5)

graph display, ysize(1.5) xsize(3)

graph export "$Fig\Figure_A5.pdf", replace
*graph export "$Fig\fig_`p`j''_LPIV`horizon2'_`k'.pdf", replace
}
}
