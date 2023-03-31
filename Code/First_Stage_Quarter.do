/*
First Stage Results - Monetary Policy and the Wage-Inflation Unemployment Trade-off

Part of this code comes from Jordà, Schularick, and Taylor (2020) JME

Author: Ricardo Duque Gabriel
First Date: 07/11/2020
Last Update: 04/05/2022

Produces Table 3
*/
quietly{
* upload data
use "$hp\Data\Data_Analysis_Quarter.dta", clear


* Controls
local rhs    l(1/2).unemp l(1/2).dlwage dlsumgdp

* first stage of the various IVs used for PEGS
eststo clear

reg dstir   JSTtrilemmaIV_R,   cluster(id) 
eststo
estadd scalar Tstat = _b[JSTtrilemmaIV_R]/_se[JSTtrilemmaIV_R]

xtreg dstir   JSTtrilemmaIV_R   `rhs', fe cluster(id) 
eststo
estadd scalar Tstat = _b[JSTtrilemmaIV_R]/_se[JSTtrilemmaIV_R]
}
esttab using "$Tab\First_Stage_Quarter.tex",  title("Regressions of dstir on JSTtrilemmaIV_R with and without controls") ///
	keep(JSTtrilemmaIV_R _cons) stats(Tstat N, layout("[@]" @) fmt(2 0) labels("$ t $-statistic"))  ///
	f replace se  b(2) se(2) sfmt(2) label  ///
	star(* 0.1 ** 0.05 *** 0.01)	
