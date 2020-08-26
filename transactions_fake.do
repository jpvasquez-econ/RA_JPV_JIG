***
*** SIMULATING TRANSACTIONS
***
clear
set more off
set seed 123
cd "C:\Users\Jose Pablo\Dropbox\0-mycomputer\mydocuments\0-LSE\0-Reseach\Z-RAs"

* NUMBER OF PRODUCERS
global n_producers=1000
* NUMBER OF SECTORES 
global n_sectors=20
* NUMBER OF YEARS
global n_years=10
* MEAN PROB OF KEEPING SAME SUPPLIER
global mean_prob=0.7
* share of good suppliers
global share_good=0.1

program drop _all 
******************************************************************************** 
***  STRUCTURE   
********************************************************************************
prog main
	n_sectors_each_year
	supplier_draw
	transactions
end

capture erase temp_n_sectors_each_year.dta
capture erase temp_supplier_draw.dta
capture erase temp_transactions.dta
******************************************************************************** 
***  n_sectors_each_year   
********************************************************************************
prog n_sectors_each_year

clear
* #producers
set obs $n_producers
gen ID=_n

* #sectors each one uses (akin to production function)
gen nsectors=floor((${n_sectors})*runiform()+1)

* year of entry, year of exit
gen entry= floor((2*${n_years}+1)*runiform() + 1990)
replace entry=2000 if entry<=1995
gen exit= floor((2*${n_years}+1)*runiform() + 1990)
replace exit=. if exit<=entry 
local final_year= 2000+${n_years}

forvalue i=2000/`final_year'{
gen year_`i'=1 if entry<=`i' & `i'<=exit
}
* creating panel
reshape long year_, i(ID) j(year)
drop if year_==.
drop year_

* #suppliers
forvalue i=1/$n_sectors {
gen supplier_`i'=1 if `i'<=nsectors
}
* creating trans panel
reshape long supplier_, i(ID year) j(seller_sector)
drop if supplier_==.
drop supplier_
save temp_n_sectors_each_year.dta, replace
end

******************************************************************************** 
***  supplier_draw   
********************************************************************************
prog supplier_draw
use temp_n_sectors_each_year.dta, clear
*draw first year
bys ID: egen min_year=min(year)
gen seller=floor((${n_producers}/${n_sectors})*runiform()+1) if year==min_year

*supplier in other years

*keeping same supplier
gen u=runiform()
gen keeping=(u<${mean_prob})

sort ID seller_sector year

local final_year= 2000+${n_years}
forvalue i=2001 /`final_year' {
replace seller=seller[_n-1] if ID==ID[_n-1] & seller_sector==seller_sector[_n-1] ///
& year==`i' & keeping==1
replace seller=floor((${n_producers}/${n_sectors})*runiform()+1) ///
if ID==ID[_n-1] & seller_sector==seller_sector[_n-1] & year==`i' & keeping!=1
}

save temp_supplier_draw.dta, replace
end 

******************************************************************************** 
***  transactions   
********************************************************************************
prog transactions
use temp_supplier_draw, clear

*transactions value
gen total_trans=year/1000+ID+seller_sector+seller/100+rnormal()*nsectors
replace total_=1 if total<1

*good suppliers
gen good= (seller> (1-$share_good) * ${n_producers}/${n_sectors})

*dropping random 10% of sample
capture drop u
gen u=runiform()
drop if u<0.1

*production
gen temp_prod=total_ + 1000*good
bys ID year: egen production=total(temp_pr)

*keeping relevant variables
keep ID year seller* total_t production
rename ID buyer
rename production buyer_sales

order year buyer buyer_sales seller seller_se total_

export delimited using "C:\Users\Jose Pablo\Dropbox\0-mycomputer\mydocuments\0-LSE\0-Reseach\Z-RAs\sales_new.csv", replace

end

main


******************************************************************************** 
***  ERASING TEMP FILES  
********************************************************************************
capture erase temp_n_sectors_each_year.dta
capture erase temp_supplier_draw.dta
capture erase temp_transactions.dta





/*

set obs 1000




***
*** SIMULATING TRANSACTIONS
***
clear
set more off
set seed 123

* obs
set obs 100000

*1000 sellers and 900 buyers
gen seller=ceil(1000*runiform())
gen buyer=ceil(900*runiform())
drop if seller==buyer

*year 
gen year=floor((2000-1995+1)*runiform() + 1995)

*sectors
local n_sectors=20
egen tag_s=tag(seller)
gen temp_state_seller = floor((`n_sectors')*runiform() + 1) if tag_s==1
bys seller: egen sector_seller=mean(temp_state_seller)
drop temp* tag*
preserve
collapse sector_seller, by(seller)
rename seller buyer
rename sector_seller sector_buyer
tempfile buyer
save `buyer', replace
restore
*merging buyer sector
merge m:1 buyer using `buyer'
replace sector_buyer=`n_sectors' if sector_buyer==.
drop if _m==2
drop _m

*states
local n_states=15
egen tag_s=tag(seller)
gen temp_state_seller = floor((`n_states')*runiform() + 1) if tag_s==1
bys seller: egen state_seller=mean(temp_state_seller)
drop temp* tag*
preserve
collapse state_seller, by(seller)
rename seller buyer
rename state_seller state_buyer
tempfile buyer
save `buyer', replace
restore
*merging buyer state
merge m:1 buyer using `buyer'
replace state_buyer=`n_sectors' if state_buyer==.
drop if _m==2

gen amount= seller/10+buyer/10+state_seller+state_buyer+sector_buyer+sector_seller+year/100+rnormal(0,10)
drop if amount<0
*drop random obs
gen u=uniform()
drop if u<0.1
drop u _m
order year state_se sector_se seller state_b sector_b buyer amount
sort seller buyer
compress

export delimited using "C:\Users\Jose Pablo\Dropbox\0-mycomputer\mydocuments\0-LSE\0-Reseach\Z-RAs\sales_states.csv", replace
