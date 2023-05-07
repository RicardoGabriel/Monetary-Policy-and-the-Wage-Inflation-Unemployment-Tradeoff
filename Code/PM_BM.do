/*
Phillips Multiplier - Monetary Policy and the Wage-Inflation Unemployment Trade-off

Phillips Multiplier close to Barnichon and Mesters (2020) JME
Adding two lags of unemployment and wage inflation but also country fixed effects and global gdp growth

Author: Ricardo Duque Gabriel
First Date: 08/11/2020
Last Update: 04/05/2022

Produce Figures 3 a) and 3 b)
*/


clear all

*Upload data
use "$hp\Data\Data_MScThesis_Analysis.dta", clear


********************************************************************************
* Setup - locals
********************************************************************************

* locals
local gridd = $gridd
local levell = $levell

* horizon
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

	** y
	local response lwage
	
	** x
	local impulse lunemp
	
	** z - instrument
	local inst JSTtrilemmaIV_R 
	
	
	*use level unemployment
	replace lunemp	= unemp
	
	*use wage inflation rate
	replace lwage 	= dlwage


	*create cumulative variables
gen hw=0
gen hu=0	
forvalues i=0/`horizon2' {
	gen F`i'lwage = (F`i'.dlwage + hw)
	replace hw = F`i'lwage
	
	gen F`i'lunemp = (F`i'.unemp + hu)
	replace hu = F`i'lunemp
}


	*create storage variables
foreach x of local impulse {
	foreach y of local response {
		forvalues k=1/`kk' {
			forvalues j=1/`jj' {
		
	cap drop b`k'_`y'`x'_`p`j'' se`k'_`y'`x'_`p`j'' F`k'_`y'`x'_`p`j''
	* setup
	gen b`k'_`y'`x'_`p`j''=.
	gen se`k'_`y'`x'_`p`j''=.
	gen F`k'_`y'`x'_`p`j''=.
	
			}
		}
	}
}


* W - control variables

* Full set of controls
local rhslwage	l(1/`Lags').unemp1 l(1/`Lags').dlwage1 l(0/`Lags').dlrcon1 l(0/`Lags').dlrgdp1 l(0/`Lags').dlcpi1 l(1/`Lags').dstir1 l(0/`Lags').dltrate1 ///
				l(1/`Lags').unemp2 l(1/`Lags').dlwage2 l(0/`Lags').dlrcon2 l(0/`Lags').dlrgdp2 l(0/`Lags').dlcpi2 l(1/`Lags').dstir2 l(0/`Lags').dltrate2 
				
				
* Second set of controls only lagged values of unemp and wage inflation as in BM 2020
local rhslwage2	l(1/`Lags').unemp1 l(1/`Lags').dlwage1  ///
				l(1/`Lags').unemp2 l(1/`Lags').dlwage2 
					
*** add extra variable to the control set - dlsumgdp to capture world business cycles
local fe dlsumgdp
				
foreach y  in `response' {

	* controls: (kk=1) full set of controls; (kk=2) only relevant variables [BM]
	local cont1`y' `rhs`y'' `fe' i.id
	local cont2`y' `rhs`y'2' `fe' i.id
}


********************************************************************************
* Estimation - Phillips Multiplier
********************************************************************************
 
gen sample=1


forvalues j=1/`jj' {

	* matched sample (using same observations for all horizons)
	if ($match) == 1 {
		xi: ivreg2 F`horizon2'lwage (F`horizon2'lunemp=`inst') `cont2lwage' ///
			if `c`j'' & F`horizon2'lunemp !=. & F`horizon2'lwage !=. , cluster(id)
		replace sample = e(sample)
	}

foreach y of local response {
	foreach x of local impulse {
		forvalues k=1/`kk' { 				
			forvalues i=0/`horizon2' {	
	
		xi: ivreg2 F`i'`y' (F`i'`x' = `inst') `cont`k'`y'' /// 
		if `c`j'' & sample==1, cluster(id)
	
			eststo iv`k'`j'`i'_`y'
			estadd scalar KleibergenPaapWeakID = e(widstat)
			replace b`k'_`y'`x'_`p`j'' 	= (_b[F`i'`x']) if _n == `i'+1
			replace se`k'_`y'`x'_`p`j'' = _se[F`i'`x'] 	if _n == `i'+1
		
		weakivtest
			estadd scalar OleaPfluegerFStat = r(F_eff)
			replace F`k'_`y'`x'_`p`j''	= r(F_eff)	 	if _n == `i'+1
		
	
	* following Ramey and Zubairy (2018) JPE [file: JORDAGK_AR.DO] estimate the
	* Anderson-Rubin confidence set computed over a grid
		weakiv ivreg2 F`i'`y' (F`i'`x' = `inst') `cont`k'`y'' /// 
		if `c`j'' & F`i'lunemp!=. & F`i'lwage!=. & sample==1, cluster(id) gridpoints(`gridd') level(`levell')
			matrix matci= e(citable) 
				gen arcibh`k'`i' =matci[1,1]
				gen arcith`k'`i' =matci[`gridd',1]
			}
		}
	}
}

}


********************************************************************************
* Produce Figures - Phillips Multiplier
********************************************************************************

* Setup - locals
local t1 (a) Full sample
local t2 (b) Post-WW2

local title full set

local tlunemp 	"Unemployment rate"
local tlwage	"Phillips Multiplier"

local ylab_lunemp	"Percentage pts"
local ylab_lwage	" "


* Setup - auxiliar variables needed for plotting
cap drop zero
local hh = `horizon2' + 1
gen zero = 0 if _n <= `hh'


cap drop Years
gen Years = _n-1 if _n<=`hh'

gen arcibh1=.
gen arcith1=.
gen arcibh2=.
gen arcith2=.
forvalues i = 0/`horizon2' {
	foreach var in arcibh arcith{
	forvalues k=1/`kk' {
		quietly replace `var'`k' = `var'`k'`i' if Years==`i'
		quietly replace `var'`k' = 1 if `var'`k'`i' >= 1	& _n == (`i'+1)	
		quietly replace `var'`k' = -2 if `var'`k'`i' <= -2	& _n == (`i'+1)	
	}
	}
}

* compute confidence bands
cap drop up* dn*
forvalues j=1/`jj'{
foreach x of local impulse {
	foreach y of local response {
		forvalues k=1/`kk' {

gen up`k'_`y'`x'_`p`j'' = b`k'_`y'`x'_`p`j'' + 1.645*se`k'_`y'`x'_`p`j'' if _n <= `hh'
	replace up`k'_`y'`x'_`p`j'' = 1 if _n <= `hh' & up`k'_`y'`x'_`p`j'' > 1

gen dn`k'_`y'`x'_`p`j'' = b`k'_`y'`x'_`p`j'' - 1.645*se`k'_`y'`x'_`p`j'' if _n <= `hh'
	replace dn`k'_`y'`x'_`p`j'' = -2 if _n <= `hh' & dn`k'_`y'`x'_`p`j'' < -2

gen up2`k'_`y'`x'_`p`j'' = b`k'_`y'`x'_`p`j'' + 1*se`k'_`y'`x'_`p`j'' if _n <= `hh'
	replace up2`k'_`y'`x'_`p`j'' = 1 if _n <= `hh' & up2`k'_`y'`x'_`p`j'' > 1

gen dn2`k'_`y'`x'_`p`j'' = b`k'_`y'`x'_`p`j'' - 1*se`k'_`y'`x'_`p`j'' if _n <= `hh'
	replace dn2`k'_`y'`x'_`p`j'' = -2 if _n <= `hh' & dn2`k'_`y'`x'_`p`j'' < -2

	replace b`k'_`y'`x'_`p`j'' = . if _n <= `hh' & (b`k'_`y'`x'_`p`j'' > 0.5 | b`k'_`y'`x'_`p`j'' < -2)

		}
	}
}
}

list Years b2_lwagelunemp_full se2_lwagelunemp_full up2_lwagelunemp_full dn2_lwagelunemp_full arcibh2 arcith2 if Years<=`hh'
outsheet Years b2_lwagelunemp_full se2_lwagelunemp_full up2_lwagelunemp_full dn2_lwagelunemp_full arcibh2 arcith2 using junk.csv if Years<=`hh', comma replace


* Produce Figures

forvalues j=1/`jj'{
foreach x of local impulse {
	foreach y of local response {
		forvalues k=1/`kk' {

		twoway (bar F`k'_`y'`x'_`p`j'' Years, bcolor(olive) barw(1)), ///
		ytitle("", size()) xtitle("Year", size()) ///
		graphregion(fcolor(white)) plotregion(color(white)) ylabel(0(5)15, nogrid) ///
		legend(off) ysize(1) xsize(2) scale(2.5)
		graph export "$Fig\fig_`p`j''_PMBM_F_LPIV`horizon2'_`k'.pdf", replace

		
		twoway (rarea up`k'_`y'`x'_`p`j'' dn`k'_`y'`x'_`p`j''  Years if Years>2,  ///
		fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
		(line b`k'_`y'`x'_`p`j'' Years if Years>2, lcolor(olive) ///
		lpattern(solid) lwidth(thick)) ///
		(line arcith`k' Years, lcolor(olive) lpattern(dash)) ///
		(line arcibh`k' Years, lcolor(olive) lpattern(dash)) ///
		(line zero Years, lcolor(black)), ///
		/*ylabel(`l`y''(`c`y'')`h`y'', nogrid) */ ///
		/*title("`t`y''", color(black) size(medsmall))*/ ///
		ytitle("`ylab_`y''", size()) xtitle("Year", size()) ///
		graphregion(fcolor(white)) plotregion(color(white)) ylabel(-2(1)1, nogrid) ///
		/*name(`y'`k'`j'`horizon2', replace)*/ legend(off) scale(2.5) ysize(1.5) xsize(3)
		graph export "$Fig\fig_`p`j''_PMBM_LPIV`horizon2'_`k'.pdf", replace

		
		* add 68% confidence bands: (rarea up2`k'_`y'`x'_`p`j'' dn2`k'_`y'`x'_`p`j''  Years if Years>2,  fcolor(gs15) lcolor(gs15) lw(none) lpattern(solid))  ///

		}
	}
}
}


********************************************************************************
* Heat map sample
********************************************************************************

replace sample = . if sample == 0

	** CONFIGURE Heat map for sample used in trilemma:
	
	local metric sample // metric variable
	local cuts ///		
		0.5
		
		*deciles /// use decile code below instead of explicit cuts
		///-0.2 -0.1 0 0.1 0.2 0.3 0.4 0.5 /// cbassets_log
		///-0.20 -0.15 -0.10 -0.05 0 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.5 /// cbassets_gdp
		///-5 -4 -3 -2 -1 0 1 2 3  /// policyrate
		///-0.5 -0.4 -0.3 -0.2 -0.1 0.0 0.1 0.2 0.3  /// real returns
		///0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0  /// public debt/GDP
		///0.1 0.2 0.3 0.4 0.5 /// CBassets/GDP
		///-0.2 -0.1 0 0.1 0.2 0.3 0.4 0.5 /// D.cbassets_log
		///0 0.1 0.2 0.3 0.5 ///
		///-0.5 -0.4 -0.3 -0.2 -0.1 0 0.1 0.2 0.3 0.4 0.5 /// bank equity return
		//
		
	local title ///
		"`: var lab `metric''"
		///"Inflation" 
		///"Public debt/GDP"
		///"Central Bank Balance Sheet, relative to GDP"
		///"Central Bank Balance Sheet growth" 
		///"Real government financing rates cross time and space"
		///"Monetary policy activism: Policy rate change during recession years"
		///"Bank equity valuation"
		
	local note ""
	
	** SELECT SUBSAMPLE:
	local subsample ///
		_n > 0 /// full sample
		///(crisisJST == 1 | crisis_bvx == 1) ///
		///(cycle_peak == 1) ///		

	
	** ADDITIONAL PACKAGES:
	*ssc install heatplot

	** EDIT:
	cap drop metric
	g metric = `metric'
	
** PLOT:
if "`cuts'" == "deciles" {
	qui _pctile metric if `subsample', nq(10)
	local cuts ///
		`r(r1)' `r(r2)' `r(r3)' `r(r4)' `r(r5)' `r(r6)' `r(r7)' `r(r8)' `r(r9)'
	local decileopts title("Deciles",size(medium))  
}

heatplot metric country year if `subsample'  ///
	, xdiscrete ydiscrete scatter(pipe, msize(*2)) ///
	cuts(`cuts') /// 
	keylabels(, `decileopts' interval format(%3.2f)) ///
	colors(hcl red, reverse) ///
	graphregion(color(white)) ///
	title("`title'", size(small)) ///
	xtitle("") ytitle("") ///a
	yscale(reverse) ///
	ylab(,labsize(1.5)) ///
	xlab(1870(10)2020, angle(45) grid labsize(1.5)) ///
	legend(off) ///
	xsize(10) ysize(6) scale(2) ///
	note(`note') ///
	name(histor_`=subinstr("`metric'",".","",.)',replace)
graph export "$Fig\history_Sample.pdf", replace
