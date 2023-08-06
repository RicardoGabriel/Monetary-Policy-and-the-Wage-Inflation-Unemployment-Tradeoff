********************************************************************************
* Setup - locals
********************************************************************************

* horizon
local horizon1 5
local horizon2 = $hf
local hh = `horizon2' + 1

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

* generate instrument coomponents for asymmetry
local a1 $a1
local a2 $a2

*grid and confidence level
local gridd = $gridd
local levell = $levell

* force sort tsset again
sort id year
tsset id year, yearly
estimates clear	



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

	*generate cumulative variables as suggested in [BM 2020]
foreach y of local response {
	cap drop h`y'
	gen h`y'=0
	forvalues i=0/`horizon2' {
		cap gen `y'`i' = (f`i'.`y' + h`y')
		replace h`y' = `y'`i'
		replace `y'`i' = `y'`i' / (`i'+1)
	}
	drop h`y'
}


	* x
	local impulse stir
	
	* z
	local inst JSTtrilemmaIV_R


* W - control variables (now with state interaction)
* Full set of controls
local rhslunemp	l(1/`Lags').unemp1_s1 l(1/`Lags').dlwage1_s1 l(0/`Lags').dlrcon1_s1 l(0/`Lags').dlrgdp1_s1 l(0/`Lags').dlcpi1_s1 l(1/`Lags').dstir1_s1 l(0/`Lags').dltrate1_s1 ///
				l(1/`Lags').unemp1_s2 l(1/`Lags').dlwage1_s2 l(0/`Lags').dlrcon1_s2 l(0/`Lags').dlrgdp1_s2 l(0/`Lags').dlcpi1_s2 l(1/`Lags').dstir1_s2 l(0/`Lags').dltrate1_s2 ///
				l(1/`Lags').unemp2_s1 l(1/`Lags').dlwage2_s1 l(0/`Lags').dlrcon2_s1 l(0/`Lags').dlrgdp2_s1 l(0/`Lags').dlcpi2_s1 l(1/`Lags').dstir2_s1 l(0/`Lags').dltrate2_s1 ///
				l(1/`Lags').unemp2_s2 l(1/`Lags').dlwage2_s2 l(0/`Lags').dlrcon2_s2 l(0/`Lags').dlrgdp2_s2 l(0/`Lags').dlcpi2_s2 l(1/`Lags').dstir2_s2 l(0/`Lags').dltrate2_s2

local rhslwage	l(1/`Lags').unemp1 l(1/`Lags').dlwage1 l(0/`Lags').dlrcon1 l(0/`Lags').dlrgdp1 l(0/`Lags').dlcpi1 l(1/`Lags').dstir1 l(0/`Lags').dltrate1 ///
				l(1/`Lags').unemp2 l(1/`Lags').dlwage2 l(0/`Lags').dlrcon2 l(0/`Lags').dlrgdp2 l(0/`Lags').dlcpi2 l(1/`Lags').dstir2 l(0/`Lags').dltrate2 

* Second set of controls only lagged values of unemp, inflation like BM (2020)
local rhslunemp2	l(1/`Lags').unemp1_s1 l(1/`Lags').dlwage1_s1 l(1/`Lags').unemp1_s2 l(1/`Lags').dlwage1_s2 ///
					l(1/`Lags').unemp2_s1 l(1/`Lags').dlwage2_s1 l(1/`Lags').unemp2_s2 l(1/`Lags').dlwage2_s2
					
local rhslwage2		l(1/`Lags').unemp1_s1 l(1/`Lags').dlwage1_s1 l(1/`Lags').unemp1_s2 l(1/`Lags').dlwage1_s2 ///
					l(1/`Lags').unemp2_s1 l(1/`Lags').dlwage2_s1 l(1/`Lags').unemp2_s2 l(1/`Lags').dlwage2_s2
					
* for robustness check adding monetary policy regimes dummies (leaving out interwar and bretton woods periods
local fe dlsumgdp_s1 dlsumgdp_s2 p1 p4 p5


* add extra variable to control for state * country FE
local cfe id1_s1 id2_s1 id3_s1 id4_s1 id5_s1 id6_s1 id7_s1 id8_s1 id9_s1 id10_s1 id11_s1 id12_s1 id13_s1 id14_s1 id15_s1 id16_s1 id17_s1 id18_s1 ///
		  id1_s2 id2_s2 id3_s2 id4_s2 id5_s2 id6_s2 id7_s2 id8_s2 id9_s2 id10_s2 id11_s2 id12_s2 id13_s2 id14_s2 id15_s2 id16_s2 id17_s2 id18_s2

foreach y of local response {
	* controls: (kk=1) full set of controls; (kk=2) only relevant variables.
	local cont1`y' `rhs`y'' `fe' `cfe'
	local cont2`y' `rhs`y'2' `fe' `cfe'
}


	*create storage variables
foreach y of local response {
	forvalues k=`kk'/`kk' {
		forvalues n=1/2 {
			forvalues j=1/`jj'{
			cap drop b`k'_`y'_`a`n''`j' se`k'_`y'_`a`n''`j'
			gen b`k'_`y'_`a`n''`j'=.
			gen se`k'_`y'_`a`n''`j'=.
			}
		}
	}
}

********************************************************************************
* Estimation - IRFs - State Dependency
********************************************************************************

gen sample=1

forvalues j=1/`jj' {

forvalues n=1/2{

if ($match) == 1 {
	xi: ivreg2 lwage`horizon2' (d.`impulse' = `inst') `cont2lwage' ///
		if `c`j'' & lunemp$hf !=. & lwage$hf !=. & `a`n''==1, cluster(id)
	replace sample = e(sample)
}

foreach y of local response {
		forvalues k=`kk'/`kk' { 				
			forvalues i=0/`horizon2' {	
		
		xi: ivreg2 `y'`i' (d.`impulse' =  `inst') `cont`k'`y'' ///
			if `c`j'' & `a`n''==1 & sample==1, cluster(id)
		
		replace b`k'_`y'_`a`n''`j'  = (_b[D.`impulse']) if _n == `i'+1
		replace se`k'_`y'_`a`n''`j' = _se[D.`impulse'] if _n == `i'+1 
			}
		}
} 
} 
}


* compute confidence bands
cap drop up* dn*
forvalues j=1/`jj'{
forvalues n=1/2{
	foreach y of local response {
		forvalues k=2/`kk' {

gen up`k'_`y'_`a`n''`j' = b`k'_`y'_`a`n''`j' + 1.645*se`k'_`y'_`a`n''`j' if _n <= `hh'
gen dn`k'_`y'_`a`n''`j' = b`k'_`y'_`a`n''`j' - 1.645*se`k'_`y'_`a`n''`j' if _n <= `hh'

gen up2`k'_`y'_`a`n''`j' = b`k'_`y'_`a`n''`j' + 1*se`k'_`y'_`a`n''`j' if _n <= `hh'
gen dn2`k'_`y'_`a`n''`j' = b`k'_`y'_`a`n''`j' - 1*se`k'_`y'_`a`n''`j' if _n <= `hh'
			
		}
	}
}
}


********************************************************************************
* Estimation - IRFs - Baseline
********************************************************************************

* create storage variables
foreach x of local impulse {
	foreach y of local response {
		forvalues k=`kk'/`kk' {
			forvalues j=1/`jj' {
		
	cap drop b`k'_`y'`x'_`p`j'' se`k'_`y'`x'_`p`j''
	* setup
	gen b`k'_`y'`x'_`p`j''=.
	gen se`k'_`y'`x'_`p`j''=.
	
			}
		}
	}
}
	
				
* Estimation: 
replace sample=1

forvalues j=1/`jj' {

if ($match) == 1 {
	xi: ivreg2 lwage`horizon2' (d.`impulse' = `inst') `cont2lwage' ///
		if `c`j'' & lunemp$hf !=. & lwage$hf !=.  & (`a1' == 1 | `a2' == 1) , cluster(id)
	replace sample = e(sample)
}

foreach y of local response {
	foreach x of local impulse {
		forvalues k=`kk'/`kk' { 				
			forvalues i=0/`horizon2' {	

	xi: ivreg2 `y'`i' (d.`x' =  `inst') `cont`k'`y'' ///
		if `c`j'' & lunemp`i' !=. & lwage`i'!= . & sample==1  & (`a1'==1 | `a2' == 1) , cluster(id)
		
	replace b`k'_`y'`x'_`p`j'' = (_b[D.`x']) if _n == `i'+1
	replace se`k'_`y'`x'_`p`j'' = _se[D.`x'] if _n == `i'+1 
			}
		}
	}
}
}


* compute confidence bands
forvalues j=1/`jj'{
foreach x of local impulse {
	foreach y of local response {
		forvalues k=2/`kk' {

gen up`k'_`y'`x'_`p`j'' = b`k'_`y'`x'_`p`j'' + 1.645*se`k'_`y'`x'_`p`j'' if _n <= `hh'
gen dn`k'_`y'`x'_`p`j'' = b`k'_`y'`x'_`p`j'' - 1.645*se`k'_`y'`x'_`p`j'' if _n <= `hh'

gen up2`k'_`y'`x'_`p`j'' = b`k'_`y'`x'_`p`j'' + 1*se`k'_`y'`x'_`p`j'' if _n <= `hh'
gen dn2`k'_`y'`x'_`p`j'' = b`k'_`y'`x'_`p`j'' - 1*se`k'_`y'`x'_`p`j'' if _n <= `hh'
			
		}
	}
}
}


********************************************************************************
* Estimation - Phillips Multiplier - Baseline
********************************************************************************


* Setup - defining main variables (y, x, z) and controls (W)

* y, x
local response lwage
local impulse lunemp

* create cumulative variables
cap drop hw hu 
gen hw=0
gen hu=0	
forvalues i=0/`horizon2' {
	cap drop F`i'lwage
	gen F`i'lwage 	= (F`i'.dlwage + hw)
	replace hw 		= F`i'lwage
	
	cap drop F`i'lunemp
	gen F`i'lunemp 		= (F`i'.unemp + hu)
	* here, do not forget to interact cumulative variable with state variable as in equation (5)
	gen F`i'lunemp_s1 	= F`i'lunemp * state
	gen F`i'lunemp_s2 	= F`i'lunemp * (1-state)
	replace hu 		 	= F`i'lunemp
}
drop hw hu

* create storage variables
foreach x of local impulse {
	foreach y of local response {
		forvalues k=2/`kk' {
			forvalues j=1/`jj' {
		
	cap drop b`k'_`y'`x'_`p`j'' se`k'_`y'`x'_`p`j'' F`k'_`y'`x'_`p`j''

	gen b`k'_`y'`x'_`p`j''=.
	gen se`k'_`y'`x'_`p`j''=.
	gen F`k'_`y'`x'_`p`j''=.
			}
		}
	}
}

* z
local inst JSTtrilemmaIV_R

	
* Estimation: 
forvalues j=1/`jj' {

if ($match) == 1 {
	xi: ivreg2 F`horizon2'lwage (F`horizon2'lunemp=`inst') `cont2lwage' ///
		if `c`j'' & F`horizon2'lunemp !=. & F`horizon2'lwage !=. & (`a1'==1 | `a2' == 1) , cluster(id)
	replace sample = e(sample)
}

foreach y of local response {
	foreach x of local impulse {
		forvalues k=2/`kk' { 				
			forvalues i=0/`horizon2' {	

			xi: ivreg2 F`i'`y' (F`i'`x' = `inst') `cont`k'`y'' if sample==1 , cluster(id)
			
				replace b`k'_`y'`x'_`p`j'' 	= (_b[F`i'`x']) if _n == `i'+1
				replace se`k'_`y'`x'_`p`j'' = _se[F`i'`x'] 	if _n == `i'+1
				eststo iv`k'`j'`i'_`y'
				estadd scalar KleibergenPaapWeakID = e(widstat)
	
			weakivtest
				estadd scalar OleaPfluegerFStat = r(F_eff)
				replace F`k'_`y'`x'_`p`j''	= r(F_eff)	 	if _n == `i'+1
			}
		}
	}
}
}

* compute confidence bands (limit them to a minimum and a maximum value for nicer graphs)
local minn = -3
local maxx = 1
forvalues j=1/`jj'{
foreach x of local impulse {
	foreach y of local response {
		forvalues k=2/`kk' {

gen up`k'_`y'`x'_`p`j'' = b`k'_`y'`x'_`p`j'' + 1.645*se`k'_`y'`x'_`p`j'' if _n <= `hh'
	replace up`k'_`y'`x'_`p`j'' = `maxx' if _n <= `hh' & up`k'_`y'`x'_`p`j'' > `maxx'

gen dn`k'_`y'`x'_`p`j'' = b`k'_`y'`x'_`p`j'' - 1.645*se`k'_`y'`x'_`p`j'' if _n <= `hh'
	replace dn`k'_`y'`x'_`p`j'' = `minn' if _n <= `hh' & dn`k'_`y'`x'_`p`j'' < `minn'

gen up2`k'_`y'`x'_`p`j'' = b`k'_`y'`x'_`p`j'' + 1*se`k'_`y'`x'_`p`j'' if _n <= `hh'
	replace up2`k'_`y'`x'_`p`j'' = `maxx' if _n <= `hh' & up2`k'_`y'`x'_`p`j'' > `maxx'

gen dn2`k'_`y'`x'_`p`j'' = b`k'_`y'`x'_`p`j'' - 1*se`k'_`y'`x'_`p`j'' if _n <= `hh'
	replace dn2`k'_`y'`x'_`p`j'' = `minn' if _n <= `hh' & dn2`k'_`y'`x'_`p`j'' < `minn'

	replace b`k'_`y'`x'_`p`j'' = . if _n <= `hh' & (b`k'_`y'`x'_`p`j'' > `maxx' | b`k'_`y'`x'_`p`j'' < `minn')	
	
		}
	}
}
}


********************************************************************************
* Estimation - Phillips Multiplier - State Dependency
********************************************************************************

* create storage variables
foreach x of local impulse {
	foreach y of local response {
	forvalues k=`kk'/`kk' {
		forvalues n=1/2 {
			forvalues j=1/`jj'{
		
cap drop b`k'_`y'`x'_`a`n''`j' se`k'_`y'`x'_`a`n''`j' F`k'_`y'`x'_`a`n''`j'

gen b`k'_`y'`x'_`a`n''`j'	=.
gen se`k'_`y'`x'_`a`n''`j'	=.
gen F`k'_`y'`x'_`a`n''`j'	=.
			}
		}
	}
	}
}

* create auxiliary variables for Table A.5.
gen dep1=.
la var dep1 "$ta1"
gen dep2=.
la var dep2 "$ta2"


* Estimation: 

forvalues j=1/`jj' {



foreach y of local response {
	foreach x of local impulse {
		forvalues k=2/2 { 				
			forvalues i=0/`horizon2' {	
				forvalues n=1/2{
				
		* here do match inside the loop so that it is a different matched sample for each n
		if ($match) == 1 {
			quietly: ivreg2 F`horizon2'lwage (F`horizon2'lunemp=`inst') `cont2lwage' ///
				if `c`j'' & F`horizon2'lunemp !=. & F`horizon2'lwage !=. & (`a`n''==1) , cluster(id)
			replace sample = e(sample)
		}
		
		* run this regression to obtain coefficients of interest:
		xi: ivreg2 F`i'`y' (F`i'`x'_s`n' = `inst'_s`n') `cont`k'`y'' if `c`j'' & `a`n''==1 & sample==1 , cluster(id)
			eststo iv`k'`j'`i'_`y'`n'
			estadd scalar KleibergenPaapWeakID = e(widstat)
			
			replace b`k'_`y'`x'_`a`n''`j' 	= (_b[F`i'`x'_s`n']) if _n == `i'+1
			replace se`k'_`y'`x'_`a`n''`j'	= _se[F`i'`x'_s`n']  if _n == `i'+1 /* HAC robust standard error*/
			
			* again, trim coefficient values
			replace b`k'_`y'`x'_`a`n''`j' = . if _n == `i'+1 & ( b`k'_`y'`x'_`a`n''`j' > `maxx' |  b`k'_`y'`x'_`a`n''`j' < `minn')
	
			
		* run this to obtain Olea and Pflueger F-statistic with weakivtest command:
		weakivtest
			estadd scalar OleaPfluegerFStat = r(F_eff)
			replace F`k'_`y'`x'_`a`n''`j'	= r(F_eff)	 	if _n == `i'+1
					
			
				} // end of loop in n	
 


	* matched sample across all horizons
	if ($match) == 1 {
		quietly: ivreg2 F`horizon2'lwage (F`horizon2'`x'_s1 F`horizon2'`x'_s2 = `inst'_s1 `inst'_s2) `cont2lwage' ///
			if `c`j'' & F`horizon2'lunemp!=. & F`horizon2'lwage!=.  & (`a1'==1 | `a2' == 1), cluster(id)
		replace sample = e(sample)
	}
	
	* trick for labels in table A.5
	replace dep1 = F`i'`x'
	replace dep2 = F`i'`x'_s2
	
	* run HAC test
	ivreg2 F`i'`y' (dep1 dep2 = `inst' `inst'_s2) `cont`k'`y'' /// 
		if `c`j'' & (`a1'==1 | `a2' == 1) & sample==1, cluster(id)
	*test dep1 = dep2
	test dep2 = 0
	replace arph_`y'_2 = r(p)  if _n == `i'+1
	
	* run AR test as in Ramey and Zubairy (2018) JPE
	weakiv ivreg2 F`i'`y' (F`i'`x' F`i'`x'_s2 = `inst' `inst'_s2) `cont`k'`y'' /// 
		if `c`j'' & (`a1'==1 | `a2' == 1) & sample==1, cluster(id) level(`levell') gridpoints(`gridd') strong(F`i'`x')
	replace arph_`y' = e(ar_p)  if _n == `i'+1
	
			} // end of loop in horizon `i'
		}
	}
}
}

* compute confidence bands
forvalues j=1/`jj'{
foreach x of local impulse {
	foreach y of local response {
		forvalues k=2/`kk' {

gen up`k'_`y'`x'_`a1'`j' = b`k'_`y'`x'_`a1'`j' + 1*se`k'_`y'`x'_`a1'`j' if _n <= `hh'
gen dn`k'_`y'`x'_`a1'`j' = b`k'_`y'`x'_`a1'`j' - 1*se`k'_`y'`x'_`a1'`j' if _n <= `hh'

gen up`k'_`y'`x'_`a2'`j' = b`k'_`y'`x'_`a2'`j' + 1*se`k'_`y'`x'_`a2'`j' if _n <= `hh'
gen dn`k'_`y'`x'_`a2'`j' = b`k'_`y'`x'_`a2'`j' - 1*se`k'_`y'`x'_`a2'`j' if _n <= `hh'
			
		}
	}
}
}

********************************************************************************
* Produce Tables - State Dependent Phillips Multiplier
********************************************************************************

* time variable	
cap gen periods = _n - 1 if _n <= `hh'
list periods b2_lwagelunemp_full b2_lwagelunemp_`a1'1 b2_lwagelunemp_`a2'1 arph_lwage if periods<=`hh' & periods>2
		
quietly{		
* open log file
cap log cl
log using "$Tab\Table_A9.tex", t replace


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
