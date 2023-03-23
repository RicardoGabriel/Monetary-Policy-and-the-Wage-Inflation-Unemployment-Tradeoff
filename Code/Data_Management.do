quietly{
					*** Data Management ***
					
					
*import data
use "$hp\Data\JSTdataset_v100.dta", clear

merge 1:1 iso year using "$hp\Data\OECD_Expectations.dta"
drop _merge

* remove Covid-19 years from the sample (referee request)
drop if year > 2019
							

********************************************************************************
* Creation of country ids
********************************************************************************

*artificially getting Ireland with id==18 without changing other countries id
replace country = "ZIreland" if country == "Ireland"		
					
egen id = group(country)
xtset id year

replace country = "Ireland" if country == "ZIreland"						

********************************************************************************
* Creation of control variables
********************************************************************************
				
* price inflation (growth rate of cpi) in %
gen dp = cpi/l1.cpi-1
replace dp=dp*100
gen ldp = l.dp
label var dp "Price inflation (%)"

* wage inflation (growth rate of wage index) in %
gen dwn = wage/l1.wage-1
replace dwn=dwn*100
label var dwn "Wage inflation %(%)"

* unemployment					
label var unemp "Unemployment rate"

* world GDP growth (following JST (2020) JME)
sort year
cap gen gdp_ppp = rgdpmad*pop
by year: egen countgdpppp = count(gdp_ppp)  
by year: egen sumGDP = sum(gdp_ppp) 
label var sumGDP "World GDP"


********************************************************************************
* List unstable periods and outliers in the sample 
********************************************************************************

* Hyperinflation in Germany (1920 to 1925)
gen hyper=0
replace hyper=1 if iso=="DEU" & year>=1920 & year<=1925

* War periods
gen war = 0
replace war = 1 if year>=1914 & year<=1919
replace war = 1 if year>=1939 & year<=1945


* Identify extreme (outlier) values in the dependent variable (dwn)
gen outlier=0

if ($fifty ==1) {
* if absolute value of wage inflation is above 50%
replace outlier = 1 if abs(dwn)>50
}
else if ($fifty ==0) {
* alternatively, truncate top 1% and bottom 1% (rob check)
xtile pct = dwn, nq(100)
replace outlier = 1 if pct <= 1
replace outlier = 1 if pct >= 100
drop pct
}

* include hyperinflation in Germany
replace outlier = . if dwn == .
replace outlier = 1 if hyper == 1


* in order to properly remove the outlier values from the main analysis 
* replace wage variable by missing value
if ($wage_out ==1) {
	replace wage = . if war==1 | outlier==1
}


* Identify countries for which we have unemployment proxies during the Gold Standard (rob check)
gen CGS=(iso=="AUS" | iso=="DNK" | iso=="FRA" | iso=="DEU" | iso=="NLD" | iso=="NOR" | iso=="SWE" | iso=="CHE" | iso=="GBR" | iso=="USA")

* Create a matched sample dummy (i.e. for which there is data for both wages and unemployment)
gen noval=0
replace noval=1 if unemp==. | dwn==.


********************************************************************************
* Creation of control variables (must come after replace wage by missing values for outliers)
********************************************************************************


* Taking Logs (following JST (2020) JME)
gen lunemp	= 100*log(1+unemp)			// unemployment rate
gen lwage	= 100*log(1+wage)			// wage index
gen lsumgdp = 100*log(sumGDP)			// (sample) "world" GDP
gen lrgdp   = 100*log(rgdpbarro)		// real GDP index from Barro
gen lrcon   = 100*log(rconsbarro)		// real consumption index from Barro
gen lcpi    = 100*log(cpi)				// price index
gen lriy 	= 100*log(iy*rgdpbarro)		// investment
gen loansgdp = tloans/gdp*100			// loans to gdp ratio
gen lspreal = log(stock/cpi)			// real stock prices index
gen cay		= 100*(ca/gdp)				// current account to gdp ratio


* Taking Differences
xtset id year
local varlist lrgdp lrcon lriy lwage lcpi ltrate stir lunemp unemp lspreal loansgdp lsumgdp cay
foreach var in `varlist'{
	gen d`var' = d.`var'
}

* Creating differentiated controls for the oil crisis period
cap drop sevs
gen sevs = cond(year >= 1973 & year <= 1980, 1, 0)
foreach v in dlunemp dunemp dlwage dlrcon dlrgdp dlcpi dlriy dstir dltrate dloansgdp dlspreal unemp dlsumgdp cay{
	cap drop `v'1 `v'2
	gen `v'1=`v'*sevs
	gen `v'2=`v'*(1-sevs)
}


********************************************************************************
* Preparing State-Dependencies (output and unemployment gaps)
********************************************************************************

**** 1) output gap 
cap drop hpsm
sort iso
by iso: hprescott rgdpbarro, stub(hp) smooth(100)
egen double hpsm = rowtotal(hp_rgdpbarro_sm_*)
drop hp_rgdpbarro_sm_*
gen outgap=(1-hpsm/rgdpbarro)


**** 2) unemployment gap

* by country replace missing unemployment gaps by average across entire sample
gen unempp=unemp
forvalues x=1/18{
	sum unemp if id==`x'
	replace unempp = r(mean) if id==`x' & unemp ==.
}
* remove periods for each we do not have initial data
replace unempp = . if id==1 & year<1901
replace unempp = . if id==2 & year<1921
replace unempp = . if id==3 & year<1916
replace unempp = . if id==4 & year<1874
replace unempp = . if id==5 & year<1920
replace unempp = . if id==6 & year<1895
replace unempp = . if id==7 & year<1887
replace unempp = . if id==8 & year<1919
replace unempp = . if id==9 & year<1930
replace unempp = . if id==11 & year<1904
replace unempp = . if id==12 & year<1953
replace unempp = . if id==13 & year<1933
replace unempp = . if id==14 & year<1911
replace unempp = . if id==15 & year<1913
replace unempp = . if id==17 & year<1890
replace unempp = . if id==18 & year<1960

cap drop hpsmm
sort iso
by iso:  hprescott unempp, stub(hp) smooth(100)
egen double hpsmm = rowtotal(hp_unempp_sm_*)
drop hp_unempp_sm_*
gen unempgap=(1-hpsmm/unemp)


**** 3) Capital Openess
* merge Capital Openess from Quinn et al.(2011) extended in JST (2020) and by me until 2020 and for Ireland
merge 1:1 iso year using "$hp\Data\openquinn_extended_IRL.dta"
drop if _merge==2
drop _merge

**** 4) Trade Openess measure
gen trade = (imports+exports)/gdp


**** 5) CB Rates from Zimmermann (2020)
merge 1:1 year country using "$hp\Data\cb_rates.dta"
drop if _merge==2
drop _merge


********************************************************************************
* Instrument construction
********************************************************************************
do trilemma_iv

* to use the trilemma instrument directly from JST data comment the previous line and uncomment the following two lines
*xtset id year
*replace JSTtrilemmaIV_R = . if peg==0 | l.peg==0

}

********************************************************************************
* Saving the Data
********************************************************************************
xtset id year
save "$hp\Data\Data_MScThesis_Analysis.dta", replace
