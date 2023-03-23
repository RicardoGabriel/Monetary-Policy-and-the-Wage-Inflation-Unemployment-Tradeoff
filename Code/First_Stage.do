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
use "$hp\Data\Data_MScThesis_Analysis.dta", clear


* Controls
local rhs    l(1/2).unemp1 l(1/2).dlwage1 ///
			 l(1/2).unemp2 l(1/2).dlwage2 dlsumgdp

* first stage of the various IVs used for PEGS
eststo clear
reg dstir   JSTtrilemmaIV_R   if war==0,   cluster(id) 
eststo
estadd scalar Tstat = _b[JSTtrilemmaIV_R]/_se[JSTtrilemmaIV_R]
reg dstir   JSTtrilemmaIV_R   if war==0 & year<=1945,   cluster(id) 
eststo
estadd scalar Tstat = _b[JSTtrilemmaIV_R]/_se[JSTtrilemmaIV_R]
reg dstir   JSTtrilemmaIV_R   if war==0 & year>1945,   cluster(id) 
eststo
estadd scalar Tstat = _b[JSTtrilemmaIV_R]/_se[JSTtrilemmaIV_R]
xtreg dstir   JSTtrilemmaIV_R   `rhs' if war==0, fe cluster(id) 
eststo
estadd scalar Tstat = _b[JSTtrilemmaIV_R]/_se[JSTtrilemmaIV_R]
xtreg dstir   JSTtrilemmaIV_R   `rhs' if war==0 & year<=1945, fe cluster(id) 
eststo
estadd scalar Tstat = _b[JSTtrilemmaIV_R]/_se[JSTtrilemmaIV_R]
xtreg dstir   JSTtrilemmaIV_R   `rhs' if war==0 & year>1945, fe cluster(id) 
eststo
estadd scalar Tstat = _b[JSTtrilemmaIV_R]/_se[JSTtrilemmaIV_R]
}
esttab using "$Tab\First_Stage.tex",  title("Regressions of dstir on JSTtrilemmaIV_R with and without controls") ///
	mtitles("All years" "PreWW2" "PostWW2" "All years" "PreWW2" "PostWW2")  ///
	keep(JSTtrilemmaIV_R _cons) stats(Tstat N, layout("[@]" @) fmt(2 0) labels("$ t $-statistic"))  ///
	f replace se  b(2) se(2) sfmt(2) label  ///
	star(* 0.1 ** 0.05 *** 0.01)	
