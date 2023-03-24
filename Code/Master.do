********************************************************************************
* 								Master File
*
* Project: Monetary Policy and the Wage-Inflation Unemployment Trade-off
* Author: Ricardo Duque Gabriel
* First Date: 30/06/2019
* Last Update: 03/23/2023
* Predicted running time: 10 minutes
* to run a faster specification change global grid to 50
*
* Some commands necessary to run/install before running this code:
* ssc install hprescott
* ssc install weakivtest
* ssc install estout
* ssc install rangerun
* ssc install rangestat
* ssc install ivreghdfe
* ssc install reghdfe
* ssc install ftools
* ssc install graph3d
********************************************************************************

* Paths (store your folder directory in a global)
do paths

capture log close
log using HWPC, text replace
clear all
set more off
set scheme s1color
graph set window fontface "Linux Biolinum O"        // set default font (window)
graph set window fontfacesans "Linux Biolinum O"    // set default sans font (window)
graph set window fontfaceserif "Linux Libertine O"  // set default serif font (window)
graph set window fontfacemono "DejaVu Sans Mono"    // set default mono font (window)


********************************************************************************
* Control Panel
********************************************************************************

* Master - choose number of horizons for the IRFs
global hf 		= 10

* Master - choose number of lags for the IRFs
global lags 	= 2

* Master - use matched sample (that is, all horizons with same # obs)
global match 	= 1

* Master - estimation of AR conf bands: set number of gridpoints and conf level
global gridd 	= 100
global levell 	= 90

* Master - choose whether outlier is identified when wage inflation is above 50% in absolute value (fifty=1)
* 		   or when it is either in top or bottom 1% of the sample (fifty=0) - robustness check
global fifty 	= 1

* Master - produce figure for slides (slides==1) or for paper (slides==0)
global slides	= 0

* Master - asymmetry specifications, choose one at a time from the following list
	* lowflat 	-	low vs high cpi inflation
	* boombust	-	bust vs boom in the economy (negative or positive unemployment gap using an hp filter)
	* negpos 	-	negative vs positive change in short run interest rate 
	* tradeoc 	-	degree of trade openess (more vs less) measured by having more than 40% of (imports+exports) / gdp (40% is close to mean and median)
	* capitaloc	-	degree of capital openess (open vs close) measured as in Quinn et al. (2011)
	* postwar   -   d
global state 	= "lowflat"
********************************************************************************


* Prepare Data with all observations
global wage_out = 0
do Data_Management

* Produce descriptive statistics
** Table 1 + Table A.2 + Table A.3
do Descriptives

** Figure 1
do Figure_1

*** Main Analysis

* Prepare Data without wage variable for outliers and war periods 
global wage_out = 1
do Data_Management

*Produce Rolling Window graphs
** Figure 2
do Figure_2

* First Stage Results of Monetary Policy Shocks (Trilemma Instrumental Variable)
** Table 3
do First_Stage			


* Phillips Multiplier
** Figures 3 a) and 3 b)
do PM_BM


** Figure 3 c)
do MP_IRFs_BM

** Figure A.1
* Effects of Monetary Policy (as in JST 2020)
do MP_IRFs

* State Dependent Phillips Multipliers
* Figure 5 and Table A.7
do SD_BM

* Figure 4
global state 	= "postwar"
do SD_BM


*** Other Figures in Appendix 
* Figure A.2 and Table A.6 (unmatched 15 years)
global hf = 15
global match = 0
global state 	= "lowflat"
do SD_BM


*******************************************************************************
* Quarterly analysis
do Data_Management_Quarter

* Phillips Multiplier Quarterly Data
** Figures 3 a) and 3 b)
do PM_BM_Quarter

** Figure 3 c)
do MP_IRFs_BM_Quarter
