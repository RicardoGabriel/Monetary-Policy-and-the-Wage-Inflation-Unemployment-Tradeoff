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
reg dstir   JSTtrilemmaIV_R   if war==0,   cluster(id) 
global b_1: di %6.2fc _b[JSTtrilemmaIV_R]
global se_1: di %6.2fc _se[JSTtrilemmaIV_R]
test JSTtrilemmaIV_R=0
global p_1 = r(p)
glo star_1=cond(${p_1}<.01,"***",cond(${p_1}<.05,"**",cond(${p_1}<.1,"*","")))
local N=e(N)
global N_1: di %12.0fc `N'
global Tstat_1 = round(_b[JSTtrilemmaIV_R]/_se[JSTtrilemmaIV_R],.01)

reg dstir   JSTtrilemmaIV_R   if war==0 & year<=1945,   cluster(id) 
global b_2: di %6.2fc _b[JSTtrilemmaIV_R]
global se_2: di %6.2fc _se[JSTtrilemmaIV_R]
test JSTtrilemmaIV_R=0
global p_2 = r(p)
glo star_2=cond(${p_2}<.01,"***",cond(${p_2}<.05,"**",cond(${p_2}<.1,"*","")))
local N=e(N)
global N_2: di %12.0fc `N'
global Tstat_2 = round(_b[JSTtrilemmaIV_R]/_se[JSTtrilemmaIV_R],.01)

reg dstir   JSTtrilemmaIV_R   if war==0 & year>1945,   cluster(id) 
global b_3: di %6.2fc _b[JSTtrilemmaIV_R]
global se_3: di %6.2fc _se[JSTtrilemmaIV_R]
test JSTtrilemmaIV_R=0
global p_3 = r(p)
glo star_3=cond(${p_3}<.01,"***",cond(${p_3}<.05,"**",cond(${p_3}<.1,"*","")))
local N=e(N)
global N_3: di %12.0fc `N'
global Tstat_3 = round(_b[JSTtrilemmaIV_R]/_se[JSTtrilemmaIV_R],.01)

xtreg dstir   JSTtrilemmaIV_R   `rhs' if war==0, fe cluster(id) 
global b_4: di %6.2fc _b[JSTtrilemmaIV_R]
global se_4: di %6.2fc _se[JSTtrilemmaIV_R]
test JSTtrilemmaIV_R=0
global p_4 = r(p)
glo star_4=cond(${p_4}<.01,"***",cond(${p_4}<.05,"**",cond(${p_4}<.1,"*","")))
local N=e(N)
global N_4: di %12.0fc `N'
global Tstat_4 = round(_b[JSTtrilemmaIV_R]/_se[JSTtrilemmaIV_R],.01)

xtreg dstir   JSTtrilemmaIV_R   `rhs' if war==0 & year<=1945, fe cluster(id) 
global b_5: di %6.2fc _b[JSTtrilemmaIV_R]
global se_5: di %6.2fc _se[JSTtrilemmaIV_R]
test JSTtrilemmaIV_R=0
global p_5 = r(p)
glo star_5=cond(${p_5}<.01,"***",cond(${p_5}<.05,"**",cond(${p_5}<.1,"*","")))
local N=e(N)
global N_5: di %12.0fc `N'
global Tstat_5 = round(_b[JSTtrilemmaIV_R]/_se[JSTtrilemmaIV_R],.01)

xtreg dstir   JSTtrilemmaIV_R   `rhs' if war==0 & year>1945, fe cluster(id) 
global b_6: di %6.2fc _b[JSTtrilemmaIV_R]
global se_6: di %6.2fc _se[JSTtrilemmaIV_R]
test JSTtrilemmaIV_R=0
global p_6 = r(p)
glo star_6=cond(${p_6}<.01,"***",cond(${p_6}<.05,"**",cond(${p_6}<.1,"*","")))
local N=e(N)
global N_6: di %12.0fc `N'
global Tstat_6 = round(_b[JSTtrilemmaIV_R]/_se[JSTtrilemmaIV_R],.01)
}


* save values
texdoc init "$Tab\First_Stage.tex", replace force
tex \begin{tabular}{lccccccc}
tex \toprule
tex Dependent & \multicolumn{3}{c}{No controls} && \multicolumn{3}{c}{With controls} \\  \cline{2-4} \cline{6-8}
tex variable: \$\Delta r_{it}\$                    &\multicolumn{1}{c}{All years}&\multicolumn{1}{c}{Pre-WW2}&\multicolumn{1}{c}{Post-WW2}& &\multicolumn{1}{c}{All years}&\multicolumn{1}{c}{Pre-WW2}&\multicolumn{1}{c}{Post-WW2}\\
tex \midrule
tex trilemma \$ z_{i,t}\$ & ${b_1}\sym{${star_1}} & ${b_2}\sym{${star_2}} & ${b_3}\sym{${star_3}} && ${b_4}\sym{${star_4}} & ${b_5}\sym{${star_5}} & ${b_6}\sym{${star_6}} \\ 
tex  & (${se_1} ) & (${se_2} ) & (${se_3} ) && (${se_4} ) & (${se_5} ) & (${se_6} )   \\
tex t-statistic & [${Tstat_1}] & [${Tstat_2}] & [${Tstat_3}] && [${Tstat_4}] & [${Tstat_5}] & [${Tstat_6}] \\
tex  \# Obs & ${N_1} & ${N_2} & ${N_3} & & ${N_4} & ${N_5} & ${N_6} \\
tex \bottomrule
tex \end{tabular} 
texdoc close
