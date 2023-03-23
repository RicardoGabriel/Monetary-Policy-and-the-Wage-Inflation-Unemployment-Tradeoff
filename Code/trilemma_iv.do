/*
trilemma_iv.do

Here, I follow the code from Jordà, Schularick, and Taylor (2020) JME 
to re-construct the trilemma instrument until 2020.
*/

quietly{

**************************************************************************
* CONSTRUCT THE INSTRUMENTAL VARIABLE 
**************************************************************************
	
* extended Ireland capital openess variable (assume from 1960 onwards same capital openess as the UK) - waiting on data from Dennis Quinn to confirm this
* extend dataset until 2020 (according to their classification all countries in this dataset are today with capital openess = 100)
replace openquinn = 100 if year >2012


********* MAKE BASE INTEREST RATE DATA

* collect ibase data for UK/FR/US
preserve
keep iso year stir
keep if iso=="GBR"
keep year stir
rename stir stir_gbr
sort year
save ../Data/stir_gbr.dta, replace
restore

preserve
keep iso year stir
keep if iso=="USA"
keep year stir
rename stir stir_usa
sort year
save ../Data/stir_usa.dta, replace
restore

preserve
keep iso year stir
keep if iso=="DEU"
keep year stir
rename stir stir_deu
sort year
save ../Data/stir_deu.dta, replace
restore


* collect ibase data for interwar UK/FR/US and "goldR" from OST IMFER dataset
preserve
use ../Data/interwar3IMF , clear
keep if ccode==1
keep year ukmm usmm frmm goldr
sort year
save ../Data/stir_ost.dta, replace
restore

cap drop _merge
sort year
merge m:1 year using ../Data/stir_gbr.dta // JST uk rate
drop _merge
sort year
merge m:1 year using ../Data/stir_usa.dta // JST us rate
drop _merge
sort year
merge m:1 year using ../Data/stir_deu.dta // JST deu rate
drop _merge
sort year
merge m:1 year using ../Data/stir_ost.dta // OST interwar uk/us/fr rates and peg indictaor
drop _merge
sort iso year

*erase ../Data/stir_gbr.dta
*erase ../Data/stir_usa.dta
*erase ../Data/stir_deu.dta
*erase ../Data/stir_ost.dta

********** 1. Make IV using the raw change in the base country interest rate
********** IV dibpeg = dibase*peg 

* force sort tsset again
sort  iso year
tsset id year, yearly

* use base coding from JST dataset
capture drop dibase
gen      dibase = .
replace  dibase = d.stir_usa   if peg_base=="USA"
replace  dibase = d.stir_gbr   if peg_base=="GBR"
replace  dibase = d.stir_deu   if peg_base=="DEU"
replace  dibase = d.goldr      if peg_base=="HYBRID" // OST hybrid for interwar
replace  dibase = . if hyper == 1 // drop DEU hyperinflation


* IV is impulse to short rate due to change in base when pegged in year T and T-1
capture drop dibpeg
gen     dibpeg = dibase * peg * l.peg  
replace dibpeg = dibpeg * (openquinn/100)  // scale by quinn capital openness
replace dibpeg = . if peg==0 | l.peg==0



********** 2. Make IV using the residualized change in the base country interest rate
********** IV dibpegF = dibaseF*peg (without R&R forecast for base countries - here it is about peg regimes)

**************************************************************************
******** CONSTRUCT THE INSTRUMENTAL VARIABLE                      ********
********  USING TAYLOR RULE RESIDS OR FACTOR AUGMENTATION         ********
**************************************************************************

* force sort tsset again
sort iso year
tsset id year, yearly
estimates clear						

* forecasting equation = regressor list uses 1 lag of RHS 7
local rhsstirF l.dlrcon l.dltrate l.dstir l.dlrgdp l.dlcpi l.dlriy l.cay
 
* forecast stir for pre-WW2
cap drop dstir_hat
gen dstir_hat =.
xtreg   d.stir  `rhsstirF'  ///
	if year < 1939 & war==0 & (iso=="USA"|iso=="GBR"|iso=="FRA") & hyper~=1 , fe
cap drop temp
predict temp ///
	if year < 1939 &  war==0 & (iso=="USA"|iso=="GBR"|iso=="FRA") & hyper~=1
replace dstir_hat = temp if year < 1939 &  war==0 & (iso=="USA"|iso=="GBR"|iso=="FRA") & hyper~=1

* forecast stir for post-WW2
xtreg   d.stir  `rhsstirF'  ///
	if year > 1945 &  war==0 & (iso=="DEU"|iso=="USA"|iso=="GBR") & hyper~=1 , fe
cap drop temp
predict temp ///
	if year > 1945 &  war==0 & (iso=="DEU"|iso=="USA"|iso=="GBR") & hyper~=1
replace dstir_hat = temp if year > 1945 &  war==0 & (iso=="DEU"|iso=="USA"|iso=="GBR") & hyper~=1

* make the residualized change in stir that will be the basis for the IV
cap drop dstir_resid
gen dstir_resid = d.stir - dstir_hat

* copy into new series
cap drop dibaseF_usa dibaseF_gbr dibaseF_deu dibaseF_fra
gen dibaseF_usa = dstir_resid if iso=="USA"  // dibase for new IV
gen dibaseF_gbr = dstir_resid if iso=="GBR"  // dibase for new IV
gen dibaseF_deu = dstir_resid if iso=="DEU"  // dibase for new IV
gen dibaseF_fra = dstir_resid if iso=="FRA"  // dibase for new IV


cap drop temp
bysort year: egen temp = mean(dibaseF_usa)
replace dibaseF_usa = temp
cap drop temp
bysort year: egen temp = mean(dibaseF_gbr)
replace dibaseF_gbr = temp
cap drop temp
bysort year: egen temp = mean(dibaseF_deu)
replace dibaseF_deu = temp
cap drop temp
bysort year: egen temp = mean(dibaseF_fra)
replace dibaseF_fra = temp


* make the IV, same as standard trilemma IV (use composite GBR-USA-FRA for interwar)
sort iso year
xtset id year


* use base coding from JST dataset and replicate hybrid construction of OST
cap drop dibaseF
gen      dibaseF = .
replace  dibaseF = dibaseF_usa   if peg_base=="USA"
replace  dibaseF = dibaseF_gbr   if peg_base=="GBR"
replace  dibaseF = dibaseF_deu   if peg_base=="DEU"
replace  dibaseF = (dibaseF_usa)/1 ///
			if year>=1919 & year<=1925 & peg_base=="HYBRID"
replace  dibaseF = (dibaseF_usa+dibaseF_gbr+dibaseF_fra)/3  ///
			if year>=1926 & year<=1930 & peg_base=="HYBRID"
replace  dibaseF = (dibaseF_usa+dibaseF_fra)/2  ///
			if year>=1931 & year<=1932 & peg_base=="HYBRID"
replace  dibaseF = (dibaseF_fra)/1  ///
			if year>=1933 & year<=1938 & peg_base=="HYBRID"
replace  dibaseF = . if hyper == 1 // drop DEU hyperinflation

*****************
* impulse to short rate due to change in base when pegged in year T and T-1
cap drop dibpegF
gen      dibpegF = .
replace  dibpegF = dibaseF * peg * l.peg  
replace  dibpegF = dibpegF * (openquinn/100)  // scale by quinn capital openness
replace  dibpegF = . if peg==0 | l.peg==0

* check whether new update is in line with original JST (2020) series
* corr 99.76%
noi: corr dibpegF JSTtrilemmaIV_R


* replace original JST estimates by these new ones
replace JSTtrilemmaIV 	= dibpeg
replace JSTtrilemmaIV_R = dibpegF
label var JSTtrilemmaIV   "JST trilemma instrument (raw base rate changes)"
label var JSTtrilemmaIV_R  "JST trilemma instrument (residualized base rate changes)"


*****************
*  save trilemma IVs in their own file
preserve
keep      year country iso ifs JSTtrilemmaIV JSTtrilemmaIV_R peg peg_type peg_base
order     year country iso ifs JSTtrilemmaIV JSTtrilemmaIV_R peg peg_type peg_base
label var peg_type "Peg type: BASE, PEG, or FLOAT"
label var peg_base "Peg base: GBR, USA, DEU, or HYBRID"
sort iso year
save  ../Data/JSTtrilemmaIV2.dta , replace
restore

}
