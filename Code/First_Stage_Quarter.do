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

reg dstir   JSTtrilemmaIV_R,   cluster(id) 
global b_1: di %6.2fc _b[JSTtrilemmaIV_R]
global se_1: di %6.2fc _se[JSTtrilemmaIV_R]
test JSTtrilemmaIV_R=0
global p_1 = r(p)
glo star_1=cond(${p_1}<.01,"***",cond(${p_1}<.05,"**",cond(${p_1}<.1,"*","")))
local N=e(N)
global N_1: di %12.0fc `N'
global Tstat_1 = round(_b[JSTtrilemmaIV_R]/_se[JSTtrilemmaIV_R],.01)


xtreg dstir   JSTtrilemmaIV_R   `rhs', fe cluster(id) 
global b_2: di %6.2fc _b[JSTtrilemmaIV_R]
global se_2: di %6.2fc _se[JSTtrilemmaIV_R]
test JSTtrilemmaIV_R=0
global p_2 = r(p)
glo star_2=cond(${p_1}<.01,"***",cond(${p_1}<.05,"**",cond(${p_1}<.1,"*","")))
local N=e(N)
global N_2: di %12.0fc `N'
global Tstat_2 = round(_b[JSTtrilemmaIV_R]/_se[JSTtrilemmaIV_R],.01)
}


* save values
texdoc init "$Tab\First_Stage_Quarter.tex", replace force
tex \begin{tabular}{lccc}
tex \toprule
tex Dependent & \multicolumn{1}{c}{No controls} && \multicolumn{1}{c}{With controls} \\
tex variable: \$\Delta r_{it}\$       \\
tex \midrule
tex trilemma \$ z_{i,t}\$ & ${b_1}\sym{${star_1}} && ${b_2}\sym{${star_2}}  \\ 
tex  & (${se_1} ) && (${se_2} )   \\
tex t-statistic & [${Tstat_1}] && [${Tstat_2}] \\
tex  \# Obs & ${N_1} && ${N_2} \\
tex \bottomrule
tex \end{tabular} 
texdoc close




/*
esttab using "$Tab\First_Stage_Quarter.tex",  title("Regressions of dstir on JSTtrilemmaIV_R with and without controls") ///
	keep(JSTtrilemmaIV_R _cons) stats(Tstat N, layout("[@]" @) fmt(2 0) labels("$ t $-statistic"))  ///
	f replace se  b(2) se(2) sfmt(2) label  ///
	star(* 0.1 ** 0.05 *** 0.01)	
