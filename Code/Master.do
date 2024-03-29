********************************************************************************
* 								Master File
*
* Project: Monetary Policy and the Wage-Inflation Unemployment Trade-off
* Author: Ricardo Duque Gabriel
* First Date: 06/30/2019
* Last Update: 08/06/2023
* Predicted running time: 20 minutes
* Software used: Stata 15
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
* ssc install avar
* ssc install heatplot
********************************************************************************

timer clear
timer on 1

* Paths (store your folder directory in a global)
do paths

capture log close
log using "$Log\HWPC", text replace
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

* Choose number of horizons for the quarterly IRFs
global hfq 		= 40

* Master - choose number of lags for the IRFs
global lags 	= 2
global lagsq	= 4

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
	
global state 	= "lowflat"
********************************************************************************


* Prepare Data with all observations
global wage_out = 0
do Data_Management

* Produce descriptive statistics
** Table 1 + Table A.2 + Table A.3 + Table A.4
do Descriptives

** Figure 1 and Figure A.1
do Figure_1


*** Main Analysis

* Prepare Data without wage variable for outliers and war periods 
global wage_out = 1
do Data_Management

*Produce heat plots 
*do explore_history

*Produce Rolling Window graphs
* Figures 2; A2; A3; A4
do Figure_2

* First Stage Results of Monetary Policy Shocks (Trilemma Instrumental Variable)
** Table A5
do First_Stage			

* Phillips Multiplier
** Figures 3.a, 3.b, and A6
do PM_BM

** Figure 3.c
do MP_IRFs_BM

** Figure A5
* Effects of Monetary Policy (as in JST 2020)
do MP_IRFs

* State Dependent Phillips Multipliers
* Figures 4 and A7 and Tables A.7 (matched 10 year sample)
do SD_BM

* State Dependent Phillips Multipliers with Monetary Policy Dummies
* Table A.9 (matched 10 year sample)
do SD_BM_Rob



*** Other Figures in Appendix 
* Figure A8 and Table A.8 (unmatched 15 years)
global hf = 15
global match = 0
global state 	= "lowflat"
do SD_BM


*******************************************************************************
* Quarterly analysis
global match = 1
global wage_out = 1
do Data_Management_Quarter

* First Stage Results of Monetary Policy Shocks (Trilemma Instrumental Variable)
** Table A.6
do First_Stage_Quarter

* Phillips Multiplier Quarterly Data
** Figures A.9 a) and A.9 b)
do PM_BM_Quarter

** Figure A.9 c)
do MP_IRFs_BM_Quarter


* State Dependent Phillips Multipliers
* Figures 5 and A.10 and Table A.10
global state 	= "lowflat"
do SD_BM_Quarter
