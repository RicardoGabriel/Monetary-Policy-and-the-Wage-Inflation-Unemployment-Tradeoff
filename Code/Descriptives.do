/*
Table Descriptives 

Produce Tables 1, A.2, and A.3
*/

quietly{

use "$hp\Data\Data_MScThesis_Analysis.dta", clear
set more off

* Graphs management
graph drop _all
set scheme s1mono
graph set window fontface default
capture graph set window fontface Helvetica

 							*** Descriptives *** 

*Adjust here if you want to construct the dataset according to explicit or implicit inflation targeting
global EXPLICIT=1
do HistoricalPeriods
							
							
*Generating windows for descriptives analysis
gen window=""
replace window="1870-1913" if year<=1913 & year>=1870
replace window="1920-1938" if year<=1938 & year>=1920
replace window="1946-1971" if year<=1971 & year>=1946
replace window="1972-1999" if year<=1999 & year>=1972
replace window="2000-2020" if year<=2020 & year>=2000

********************************************************************************
* Table 2 - Descriptive statistics table (main sample)
********************************************************************************
*To exclude the observations for which one of the trio variables is missing
*include the variable noval in the tabstat command (now also with price inflation)
replace noval=1 if unemp==. | dwn==. | dp==.

estpost tabstat unemp dwn dp if noval==0 & outlier==0, by(window) stat(n p50 mean sd min max) col(stat)
esttab using "$Tab\Table_Descriptives.tex", cells("count(fmt(0)) p50(fmt(2)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") noobs nonumber label replace ///
	title("Descriptive statistics \label{T:Descriptives}")

	
********************************************************************************
* Table A.2 - Descriptive statistics table (main sample & weighted)
********************************************************************************
*To exclude the observations for which one of the trio variables is missing
*include the variable noval in the tabstat command (now also with price inflation)
replace noval=1 if unemp==. | dwn==. | dp==.

estpost tabstat unemp dwn dp [aw = pop] if noval==0 & outlier==0, by(window) stat(n p50 mean sd min max) col(stat)
esttab using "$Tab\Table_Descriptives_W.tex", cells("count(fmt(0)) p50(fmt(2)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") noobs nonumber label replace ///
	title("Descriptive statistics \label{T:DescriptivesW}")	
	
********************************************************************************
*Table A.1 - Descriptive statistics table (full sample)
********************************************************************************
replace window=""
replace window="1870-1913" if year<=1913 & year>=1870
replace window="World Wars" if war == 1
replace window="1920-1938" if year<=1938 & year>=1920
replace window="1946-1971" if year<=1971 & year>=1946
replace window="1972-1999" if year<=1999 & year>=1972
replace window="2000-2020" if year<=2020 & year>=2000

estpost tabstat unemp dwn dp if hyper==0, by(window) stat(n p50 mean sd min max) col(stat)
esttab using "$Tab\Table_Descriptives_Full.tex", cells("count(fmt(0)) p50(fmt(2)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") noobs nonumber label replace ///
	title("Descriptive statistics - full sample \label{T:Descriptives-Full}")
	
	
********************************************************************************
*Table A.3 - Correlations table (Wage Inflation)
********************************************************************************
matrix C = J(18,3,0)
matrix rownames C = "Australia" "Belgium" "Canada" "Denmark" "Finland" "France" "Germany" "Italy" "Japan" "Netherlands" "Norway" "Portugal" "Spain" "Sweden" "Switzerland" "UK" "USA" "Ireland"
matrix colnames C = "$\pi_t^p$" "$\pi_{t-1}^p$" "$\u_t$"

xtset id year
forvalues x = 1(1)18{
	eststo: estpost corr dwn dp if id==`x' & outlier==0	
	matrix C[`x',1] = e(b)
	eststo: estpost corr dwn ldp if id==`x' & outlier==0	
	matrix C[`x',2] = e(b)
	eststo: estpost corr dwn unemp if id==`x' & outlier==0	
	matrix C[`x',3] = e(b)
}
outtable using `"$Tab\Correlation_Wage"', mat(C) replace nobox asis center f(%9.3f) caption("Wage Inflation Correlations Table")
eststo clear

}					
