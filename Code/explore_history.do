*-------------------------------------------------------------------------------

* Visualise metric variables across countries and years.
* Original code from Martin Kornejew

*-------------------------------------------------------------------------------


** CONFIGURE LOCAL SETUP:

	
	** SET PATHS:
	local path_in "$hp\Data\Data_MScThesis_Analysis.dta"
	local path_out "$Fig\"
*	local suffix "_`=subinstr("`metric'",".","",.)'" // string or empty; file name suffix 

	
	label var dlwage "Wage Inflation"
	
	** CONFIGURE PLOT:
	local metric unemp // metric variable
	local cuts ///
		deciles /// use decile code below instead of explicit cuts
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

	
** LOAD DATA:
use `path_in', clear

	** EDIT:
	g metric = `metric'
	

** PLOT:
if "`cuts'" == "deciles" {
	qui _pctile metric if `subsample', nq(10)
	local cuts ///
		`r(r1)' `r(r2)' `r(r3)' `r(r4)' `r(r5)' `r(r6)' `r(r7)' `r(r8)' `r(r9)'
	local decileopts title("Deciles",size(medium))  
}

local metric dlwage
heatplot metric country year if `subsample' ///
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
graph export "`path_out'/history_unemp.pdf", replace
