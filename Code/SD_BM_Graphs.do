*******************************************************************************
* Setup - locals
********************************************************************************

local jj=1
local horizon2=$hf
local hh = `horizon2' + 1

* file extension 
local what $what
local match $match

* the corresponding parts of the instrument
local instr $instr

*** Sample period names
local p1 full
local p2 post

*** Sample period titles
local t1 $t1
local t2 $t2
local t3 $t3

* the asymmetry halves
local a1 $a1
local a2 $a2

local s1 $state

* asymmetry half titles
local ta1 $ta1
local ta2 $ta2

*** titles
local title $title
local asym $asym
local what $what

********************************************************************************
* Produce Figures 3 a) and 3 c) - State Dependent Phillips Multiplier
********************************************************************************

* y-axis title
local tlunemp "Average Unemployment Rate"
local tlwage "Average Wage Inflation"
local tlwage2 "Phillips Multiplier"

cap drop zero
gen zero = 0 if _n <= `hh'

cap drop Years
gen Years = _n-1 if _n<=`hh'


forvalues j=1/`jj'{

	local a1 $a1
	local a2 $a2

local ylablwage 	"ylab(-1(0.5)1)"
local ylablunemp  	"ylab(-1(0.5)1)"
local ylablwage2	"ylab(-2(1)1)"


if "`a1'" == "positive" {
	local ylablwage 	"ylab(-2(0.5)1)"
	local ylablunemp  	"ylab(-1(0.5)1.5)" 
}

forvalues k=2/2{
local impulse stir
foreach x of local impulse {
	
	local response lunemp 
	foreach y of local response {
		preserve
		keep if Years>=0 & Years<=`hh'
		twoway (rarea up`k'_`y'`x'_`p`j'' dn`k'_`y'`x'_`p`j''  Years, ///
		fcolor(gs12) lcolor(gs12) lw(none)  lpattern(solid)) ///
		(line b`k'_`y'`x'_`p`j'' Years, lcolor(olive) ///
		lpattern(solid) lwidth(thick)) /// 
		(line b`k'_`y'_`a1'`j' Years, lcolor(dkgreen) ///
		lpattern(longdash) lwidth(thick)) /// 
		(line b`k'_`y'_`a2'`j' Years, lcolor(dkorange) ///
		lpattern(dash) lwidth(thick)) /// 
		(line zero Years, lcolor(black)), ///
		/// ylabel(`l`y''(`c`y'')`h`y'', nogrid) ///
		title("`t`y''", color(black) size(medsmall)) ///
		ytitle("Percentage Points", size(medsmall)) xtitle("Year", size(medsmall)) ///
		graphregion(fcolor(white)) plotregion(color(white)) ///
		legend(off) ///	
		name(`y'`k'`j', replace) nodraw xsize(2) ysize(3) ///
		`ylab`y''
		* (rarea up`k'_`y'_`a1'`j' dn`k'_`y'_`a1'`j'  Years, fcolor(gs12) lcolor(gs12) lw(none)  lpattern(solid)) (rarea up`k'_`y'_`a2'`j' dn`k'_`y'_`a2'`j'  Years, fcolor(gs12) lcolor(gs12) lw(none)  lpattern(solid)) (line b`k'_`y'`x'_`p`j'' Years, lcolor(olive)
		
		restore		
	}

	
	local response lwage
	foreach y of local response {
		preserve
		keep if Years>=0 & Years<=`hh'
		twoway (rarea up`k'_`y'`x'_`p`j'' dn`k'_`y'`x'_`p`j''  Years, ///
		fcolor(gs12) lcolor(gs12) lw(none)  lpattern(solid)) ///
		(line b`k'_`y'`x'_`p`j'' Years, lcolor(olive) ///
		lpattern(solid) lwidth(thick)) /// 
		(line b`k'_`y'_`a1'`j' Years, lcolor(dkgreen) ///
		lpattern(longdash) lwidth(thick)) /// 
		(line b`k'_`y'_`a2'`j' Years, lcolor(dkorange) ///
		lpattern(dash) lwidth(thick)) /// 
		(line zero Years, lcolor(black)), ///
		/// ylabel(`l`y''(`c`y'')`h`y'', nogrid) ///
		title("`t`y''", color(black) size(medsmall)) ///
		ytitle("", size(medsmall)) xtitle("Year", size(medsmall)) ///
		graphregion(fcolor(white)) plotregion(color(white)) ///
		/*legend(off)*/ legend( c(1) region(ls(none)) size(vsmall) col(2) order(3 4) label(3 "`ta1'") label(4 "`ta2'") ring(0) position(2)) ///	
		name(`y'`k'`j', replace) nodraw xsize(2) ysize(3) ///
		`ylab`y''
		restore		
	}
}
}

foreach x in lunemp {	
	foreach y in lwage {
		forvalues k=2/2 {
		
		preserve
		twoway (rarea up`k'_`y'`x'_`a1'`j' dn`k'_`y'`x'_`a1'`j'  Years if Years>2,  ///
		fcolor(gs12) lcolor(gs12) lw(none) lpattern(solid))  ///
		(rarea up`k'_`y'`x'_`a2'`j' dn`k'_`y'`x'_`a2'`j'  Years if Years>2,  ///
		fcolor(gs12) lcolor(gs12) lw(none) lpattern(solid))  ///
		(line b`k'_`y'`x'_`p`j'' Years if Years>2, lcolor(olive) ///
		lpattern(solid) lwidth(thick)) ///
		(line b`k'_`y'`x'_`a1'`j' Years if Years>2, lcolor(dkgreen) ///
		lpattern(longdash) lwidth(thick)) /// 
		(line b`k'_`y'`x'_`a2'`j' Years if Years>2, lcolor(dkorange) ///
		lpattern(dash) lwidth(thick)) ///  
		(line zero Years, lcolor(black)), ///
		ytitle("", size()) xtitle("", size()) ///
		graphregion(fcolor(white)) plotregion(color(white)) ///
		legend(off) /*legend( region(ls(none)) size(vsmall) col(1) order(3 4 5) label(3 "Baseline") label(4 "`ta1'") label(5 "`ta2'") )*/ ///
		scale(2) ysize(1.5) xsize(3) `ylab`y'2' 	
		
		if ($hf)==10 {
		graph export "$Fig\Figure_4a.pdf", replace
		}
		else if ($hf)==15 {
		graph export "$Fig\Figure_A8a.pdf", replace
		}
		else {
		graph export "$Fig\fig_`p`j''_SDPMBM_LPIV`horizon2'_`k'_asym`what'.pdf", replace
		}
		

		restore
		
		
		}
	}
}
}

* combine to produce figure 3 c)
forvalues j=1/`jj'{
foreach x of local impulse {
forvalues k=2/2{
graph combine lunemp21 lwage21, /// 
	graphregion(fcolor(white)) ///
	rows(1) cols(2) ysize(1) xsize(3) imargin(tiny) iscale(0.9) scale(2)

graph display, ysize(1) xsize(3)
		if ($hf)==10 {
		graph export "$Fig\Figure_4c.pdf", replace
		}
		else if ($hf)==15 {
		graph export "$Fig\Figure_A8c.pdf", replace
		}
		else {
		graph export "$Fig\fig_`p`j''_SDLPIVBM`horizon2'_`k'_asym`what'.pdf", replace
		}
}
}
}


********************************************************************************
* Produce AR p-value graphs
********************************************************************************

gen pvalue = 0.1

twoway  (bar arph_lwage Years if Years>2 & arph_lwage > 0.1, color(gray)) ///
		(line pvalue Years) ///
		(bar arph_lwage Years if Years>2 & arph_lwage <= 0.1, color(dkgreen)) , ///
		ytitle("p-value", size()) xtitle("Year", size()) ///
		graphregion(fcolor(white)) plotregion(color(white)) ///
		legend(off) /*legend( region(ls(none)) size(vsmall) col(1) order(3 4 5) label(3 "Baseline") label(4 "`ta1'") label(5 "`ta2'") )*/ ///
		scale(2) ysize(1.5) xsize(3) ylab(0(0.2)1) 	
		*graph export "$Fig\fig_`p1'_SDPMBM_LPIV`horizon2'_2_asym`what'_arph.pdf", replace

drop pvalue



********************************************************************************
* Produce Tables - State Dependent Phillips Multiplier
********************************************************************************

* time variable	
cap gen periods = _n - 1 if _n <= `hh'
list periods b2_lwagelunemp_full b2_lwagelunemp_`a1'1 b2_lwagelunemp_`a2'1 arph_lwage if periods<=`hh' & periods>2
		
quietly{		
* open log file
cap log cl
if ($hf)==10 {
	log using "$Tab\Table_A7.tex", t replace
}
else if ($hf)==15 {
	log using "$Tab\Table_A8.tex", t replace
}
else {
	log using "$Tab\Table_asym`what'_`horizon2'_`match'.tex", t replace
}

set linesize 255

* start writing the Table in LaTeX
n di "\begin{tabular}{l*{1}{cccc}}"
n di "\hline\hline"
if ("`s1'" == "lowflat") {
n di " Horizon  & Linear & High 		& Low 		& AR 		\\"
n di " 			& Model 	& Inflation & Inflation	& p-value 	\\"
}

else if ("`s1'" == "boombust") {
n di " Horizon  & Linear & Boom 	& Bust 	& AR 		\\"
n di " 			& Model 	&  		& 		& p-value 	\\"
}	

else if ("`s1'" == "negpos") {	
n di " Horizon  & Linear & Positive 	& Negative 	& AR 		\\"
n di " 			& Model 	&  Change	& 	Change	& p-value 	\\"
}

else if ("`s1'" == "tradeoc") {	
n di " Horizon  & Linear & Open 	& Close 	& AR 		\\"
n di " 			& Model 	&  		& 			& p-value 	\\"
}

else if ("`s1'" == "capitaloc") {	
n di " Horizon  & Linear & Open 	& Close 	& AR 		\\"
n di " 			& Model 	&  		& 			& p-value 	\\"
}
n di "\hline"

local varlist b2_lwagelunemp_full b2_lwagelunemp_`a1'1 b2_lwagelunemp_`a2'1 arph_lwage se2_lwagelunemp_full se2_lwagelunemp_`a1'1 se2_lwagelunemp_`a2'1

forvalues i=3/`horizon2' {
	foreach x of local varlist{
		local `x'`i' = `x'[`i'+1]
	}
	* Add new lines to Table
n di	%13s "`i' 	& " /// 
		%5.3f `b2_lwagelunemp_full`i'' 	" & " %5.3f `b2_lwagelunemp_`a1'1`i'' 	" & "  ///
		%5.3f `b2_lwagelunemp_`a2'1`i'' 	" & " %5.3f `arph_lwage`i''   " \\"
n di	%13s "	& (" /// 
		%5.3f `se2_lwagelunemp_full`i'' 	") & (" %5.3f `se2_lwagelunemp_`a1'1`i'' 	") & ("  ///
		%5.3f `se2_lwagelunemp_`a2'1`i'' 	") & \\"
n di " & & & &\\"
}	
n di "\hline\hline" 
n di "\end{tabular}"

log cl
}

