/*
State Dependencies - Monetary Policy and the Wage-Inflation Unemployment Trade-off

SD Phillips Multiplier and IRFs close to Barnichon and Mesters (2020):
Adding two lags of unemployment and wage inflation but also country 
fixed effects and global gdp growth.

Calls SD_BM_Reg.do and Sd_BM_Graphs.do 

*/

clear all

* Upload data
use "$hp\Data\Data_Analysis_Quarter.dta", clear


* Call chosen state
local s1 $state

* Log from here
cap log close
log using "$Log\asym_`s1'_quarter.log" , replace


********************************************************************************
* Setup - Choice of state-dependency
********************************************************************************
 
if ("`s1'" == "lowflat") {
	cap drop dlcpilo dlcpihi
	gen dlcpilo = cond(l.dlcpi_yoy< 2.1, 1, 0) if l.dlcpi_yoy!=.
	gen dlcpihi = cond(l.dlcpi_yoy>=2.1, 1, 0) if l.dlcpi_yoy!=.
		global a1 dlcpihi
		global a2 dlcpilo
		global ta1 high inflation
		global ta2 low inflation
		global asym Lowflation
}

else if ("`s1'" == "boombust") {
	cap drop boom bust
	gen boom = cond(unempgap>0, 1, 0) if unempgap!=.
	gen bust = cond(unempgap<0, 1, 0) if unempgap!=.
		global a1 boom
		global a2 bust
		global ta1 Unemp Gap > 0
		global ta2 Unemp Gap < 0
		global asym Booms vs. busts
}	

else if ("`s1'" == "negpos") {	
	cap drop negative positive
	gen positive = cond(dstir>0, 1, 0) if dstir!=.
	gen negative = cond(dstir<0, 1, 0) if dstir!=.
		global a1 positive
		global a2 negative
		global ta1 dstir > 0
		global ta2 dstir < 0
		global asym NegPos
}

else if ("`s1'" == "tradeoc") {	
	cap drop opent closet
	gen opent	= cond(trade>0.4,  1, 0) if trade!=.
	gen closet	= cond(trade<=0.4, 1, 0) if trade!=.
		global a1 opent
		global a2 closet
		global ta1 trade > 40%
		global ta2 trade < 40%
		global asym Trade
}

else if ("`s1'" == "capitaloc") {	
	cap drop openk closek
	gen openk	= cond(openquinn == 100, 1, 0) if openquinn!=.
	gen closek	= cond(openquinn < 100, 1, 0) if openquinn!=.
		global a1 openk
		global a2 closek
		global ta1 capital = 100
		global ta2 capital < 100
		global asym Quinn
}

else if ("`s1'" == "postwar") {	
	cap drop pre post
	gen pre	= cond(year>=1946 & year <=1999,1,0)
	gen post= cond((year>=2000 & year <=2020)|(year>=1870 & year <=1913),1,0)
		global a1 pre
		global a2 post
		global ta1 1946-1999
		global ta2 1870-1913 & 2000-2020
		global asym postwar
}

* file extension
global what _`s1'

********************************************************************************
* Setup - Create necessary variables
********************************************************************************

* generate storage for HAC p-value and AR p-value tests
	gen arph_lwage = .
	gen arph_lwage_2 = .	


* Define State Variable
	gen state=.
	replace state=1 if $a1 == 1
	replace state=0 if $a2 == 1

* Also interact country FE
tabulate id, gen(id)
	
* Generate instrument and controls interacted with state variable
local varlist JSTtrilemmaIV unemp dlwage dlsumgdp dlrgdp dlcpi dstir ///
			  id1 id2 id3 id4 id5 id6 id7 id8 id9 id10 id11 id12 ///
			  id13 id14 id15 id16 id17 dlcpi_yoy
	foreach var in `varlist'{
		gen `var'_s1 = `var' * state
		gen `var'_s2 = `var' * (1 - state)
	}
	
********************************************************************************
* Estimation and Production of graphs
********************************************************************************

do SD_BM_Reg_Quarter						// LP regressions, asymmetries
do SD_BM_Graphs_Quarter  					// LP graphs by asymmetry
		
eststo clear
cap log close
