					*** Data Management Quarterly ***

* List of country codes: AU BE CA DK FI FR DE IE IT JP NL NO PT ES SE GB US
				
					
* Import data from FRED date range 1995Q1-2020Q1; when monthly agg to quarter

*quietly{

********************************************************************************
* 								   Wages
* Hourly Earnings: Private Sector (LCEA)
* Hourly Wage Rate: Private Sector for the Netherlands and Australia (LCWR)
********************************************************************************
import fred LCEAPR01SEQ189N LCEAPR01ITQ661S LCEAPR01USQ189S LCEAPR01FRQ661S ///
LCWRPR01NLQ661S LCEAPR01IEQ661S LCEAPR01PTQ661S LCEAMN01CAQ189S LCEAPR01BEQ661S ///
LCEAMN03NOQ661N LCEAPR03JPQ661S LCEAPR01FIQ661S LCEAPR01DKQ661S LCEAPR01DEQ661S ///
LCEATT01ESQ189N LCEAPR02GBQ661S LCWRTT01AUQ661N ///
, daterange(1995-01-01 2020-01-01) aggregate(quarterly,avg) long clear

* Country Name (9 and 10 character)
gen country = substr(series_id,9,2)

* Seasonally adjusted (N: not seasonally adjusted; S: seasonally adjusted)
gen seasonal_wage = substr(series_id,15,1)

* change name of the series and store as .dta file
rename value wage
tempfile wage
save `wage'


********************************************************************************
* 							  Interest Rates
* 3-Month or 90-day Rates and Yields: Interbank Rates
* Immediate Rates: Less than 24 Hours: Call Money/Interbank Rate for Japan
********************************************************************************
import fred IR3TIB01AUQ156N IR3TIB01BEQ156N IR3TIB01CAQ156N IR3TIB01DKQ156N ///
IR3TIB01FIQ156N IR3TIB01FRQ156N IR3TIB01DEQ156N IR3TIB01IEQ156N IR3TIB01ITQ156N ///
IRSTCI01JPQ156N IR3TIB01NLQ156N IR3TIB01NOQ156N IR3TIB01PTQ156N IR3TIB01ESQ156N ///
IR3TIB01SEQ156N IR3TIB01GBQ156N IR3TIB01USQ156N ///
, daterange(1995-01-01 2020-01-01) aggregate(quarterly,avg) long clear

* Country Name (9 and 10 character)
gen country = substr(series_id,9,2)

* Seasonally adjusted (N: not seasonally adjusted; S: seasonally adjusted)
gen seasonal_stir = substr(series_id,15,1)

* change name of the series and store as .dta file
rename value stir
tempfile stir
save `stir'



********************************************************************************
* 									GDP
* Real Gross Domestic Product
********************************************************************************
import fred NGDPRSAXDCAUQ CLVMNACSCAB1GQBE NGDPRSAXDCCAQ CLVMNACSCAB1GQDK ///
CLVMNACSCAB1GQFI CLVMNACSCAB1GQFR CLVMNACSCAB1GQDE CLVMNACNSAB1GQIE CLVMNACSCAB1GQIT ///
JPNRGDPEXP CLVMNACSCAB1GQNL CLVMNACSCAB1GQNO CLVMNACSCAB1GQPT CLVMNACSCAB1GQES ///
CLVMNACSCAB1GQSE CLVMNACSCAB1GQUK GDPC1 ///
, daterange(1995-01-01 2020-01-01) aggregate(quarterly,avg) long clear

* Country Name
gen country = substr(series_id,15,2)
replace country = substr(series_id,11,2) if substr(series_id,1,3) == "NGD"
replace country = "JP" if series_id == "JPNRGDPEXP"
replace country = "US" if series_id == "GDPC1"
replace country = "GB" if country == "UK"

* Seasonally adjusted (N: not seasonally adjusted; S: seasonally adjusted)
gen seasonal_gdp = "S"
replace seasonal_gdp = "N" if country == "IE"

* change name of the series and store as .dta file
rename value gdp
tempfile gdp
save `gdp'


********************************************************************************
* 							Consumer Price Index
********************************************************************************
import fred AUSCPIALLQINMEI BELCPIALLQINMEI CPALCY01CAM661N DNKCPIALLQINMEI ///
FINCPIALLQINMEI FRACPIALLQINMEI DEUCPIALLQINMEI IRLCPIALLQINMEI ITACPIALLQINMEI ///
JPNCPIALLQINMEI NLDCPIALLQINMEI NORCPIALLQINMEI PRTCPIALLQINMEI ESPCPIALLQINMEI ///
SWECPIALLQINMEI GBRCPIALLQINMEI USACPIALLQINMEI ///
, daterange(1995-01-01 2020-01-01) aggregate(quarterly,avg) long clear

* Country Name
gen country = substr(series_id,1,2)
replace country = "CA" if country == "CP"
replace country = "DK" if country == "DN"
replace country = "IE" if country == "IR"
replace country = "PT" if country == "PR"
replace country = "SE" if country == "SW"

* Seasonally adjusted (N: not seasonally adjusted; S: seasonally adjusted)
gen seasonal_cpi = "N"

* change name of the series and store as .dta file
rename value cpi
tempfile cpi
save `cpi'


********************************************************************************
* 							Unemployment Rates
*Harmonised Unemployment Rates: Total: All Persons 
********************************************************************************
import fred LRHUTTTTAUQ156S LRHUTTTTBEQ156S LRHUTTTTCAQ156S LRHUTTTTDKQ156S ///
LRHUTTTTFIQ156S LRHUTTTTFRQ156S LRHUTTTTDEQ156S LRHUTTTTIEQ156S LRHUTTTTITQ156S ///
LRHUTTTTJPQ156S LRHUTTTTNLQ156S LRHUTTTTNOQ156S LRHUTTTTPTQ156S LRHUTTTTESQ156S ///
LRHUTTTTSEQ156S LRHUTTTTGBQ156S LRHUTTTTUSQ156S ///
, daterange(1995-01-01 2020-01-01) aggregate(quarterly,avg) long clear

* Country Name (9 and 10 character)
gen country = substr(series_id,9,2)

* Seasonally adjusted (N: not seasonally adjusted; S: seasonally adjusted)
gen seasonal_unemp = substr(series_id,15,1)

* change name of the series and store as .dta file
rename value unemp
tempfile unemp
save `unemp'


********************************************************************************
* 							Quarterly Dataset
********************************************************************************

* Merge different variables
foreach var in wage cpi stir gdp {
	merge 1:1 country daten using ``var''
	drop _merge
}

* Date
generate dateq = qofd(daten)
generate quarter = quarter(daten)

* Cid
egen id = group(country), label

* Panel data
xtset id dateq, quarter


* remove seasonality from not seasonally adjusted series (wages for group and gdp for Ireland)
foreach var in wage gdp {
	by id:  hprescott `var', stub(hp) smooth(100)
	egen double hpsmm = rowtotal(hp_`var'_sm_*)
	replace `var' = hpsmm if seasonal_`var' == "N"
	drop hp_`var'_* hp_`var'_sm_* hpsmm
}

* Index to 2015-01-01 = 100 for comparability?
* ?

* add capital openess variable under the assumption it does not change within the same year
gen year = substr(datestr,1,4)
destring year, replace
merge m:1 country year using "$hp\Data\openquinn_extended_IRL.dta"
drop if _merge == 2
drop _merge
xtset id dateq, quarter
replace iso = iso[_n-1] if id==id[_n-1]

* drop unnecessary variables
drop daten datestr seasonal_* country series_id

* save FRED data
save "$hp\Data\FRED_Imported.dta", replace


use "$hp\Data\FRED_Imported.dta", clear

* get peg definitions from yearly data from JST (2020)
preserve
use "$hp\Data\JSTdataset_v100.dta", clear
keep year iso peg peg_base peg_type
tempfile JST
save `JST'
restore

* merge with quarterly data
merge m:1 iso year using `JST'
drop if _merge == 2
drop _merge

xtset id dateq, quarter

********************************************************************************
* Creation of control variables
********************************************************************************
				
* price inflation (growth rate of cpi) in % year on year (yoy)
gen dpyoy = cpi/l4.cpi-1
replace dpyoy=dpyoy*100
label var dpyoy "Price inflation (%) yoy"

gen dp = cpi/l1.cpi-1
replace dp=dp*100
gen ldp = l.dp
label var dp "Price inflation (%)"

* wage inflation (growth rate of wage index) in %
gen dwn = wage/l1.wage-1
replace dwn=dwn*100
label var dwn "Wage inflation (%)"

* unemployment					
label var unemp "Unemployment rate"

* world GDP growth following JST (2020)
sort dateq
by dateq: egen countgdp = count(gdp)  
by dateq: egen sumGDP = sum(gdp)

* correcting for artificial growth coming from potential missing observations
replace sumGDP = sumGDP / countgdp
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
gen lrgdp   = 100*log(gdp)				// real GDP
gen lcpi    = 100*log(cpi)				// price index


/*
gen lriy 	= 100*log(iy*rgdpbarro)		// investment
gen loansgdp = tloans/gdp*100			// loans to gdp ratio
gen lspreal = log(stock/cpi)			// real stock prices index
gen cay		= 100*(ca/gdp)				// current account to gdp ratio
gen lrcon   = 100*log(rconsbarro)		// real consumption index from Barro
*/

* Taking Differences
xtset id dateq, quarter
local varlist lrgdp lwage lsumgdp lcpi stir lunemp unemp 
*ltrate lspreal loansgdp  cay lrcon lriy 
foreach var in `varlist'{ 
	gen d`var' = d.`var'
}

	gen dlcpi_yoy = 100*log(cpi)-100*log(l4.cpi)


********************************************************************************
* Preparing State-Dependencies (output and unemployment gaps)
********************************************************************************
/*
**** 1) output gap 
cap drop hpsm
sort iso
by iso: hprescott gdp, stub(hp) smooth(100)
egen double hpsm = rowtotal(hp_gdp_sm_*)
drop hp_gdp_sm_*
gen outgap=(1-hpsm/gdp)


**** 2) unemployment gap

* by country replace missing unemployment gaps by average across entire sample
gen unempp=unemp
forvalues x=1/18{
	sum unemp if id==`x'
	replace unempp = r(mean) if id==`x' & unemp ==.
}

cap drop hpsmm
sort iso
by iso:  hprescott unempp, stub(hp) smooth(100)
egen double hpsmm = rowtotal(hp_unempp_sm_*)
drop hp_unempp_sm_*
gen unempgap=(1-hpsmm/unemp)
*/

********************************************************************************
* Instrument construction
********************************************************************************
do trilemma_iv_Quarter

*}

********************************************************************************
* Saving the Data
********************************************************************************
xtset id dateq, quarter
drop if dateq==240
save "$hp\Data\Data_Analysis_Quarter.dta", replace
