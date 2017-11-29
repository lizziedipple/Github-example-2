clear all

// Specify the location of datasets

// Lizzie (working locally to start with)
global dir "C:\Users\elizabeth.dipple\Documents\Aspirations project\Data files" 
global input $dir\input
global output $dir\output
global temp $dir\temp

log using "$output\Distributions price data log.smcl", replace


// Dec 2016 surveys - need correcting variable types
use "$input\ASP_price_siaya_122016_IPA.dta", clear


// Variables with missing values need to be made the correct type for putting files together
// First check that the contents are blank (i.e. "" for string and "." for number)
// After changing variable type, replace missing contents with correct version for that variable type 

tab s504kg2_a, m
destring s504kg2_a, replace

foreach var of varlist sfo1name s710w1 s710j1 s710w2 s710j2 s710j3 {
tab `var', m
tostring `var', replace
replace `var' = "" if `var' == "."
}

browse s*quant_b
tostring s*quant_b, replace
foreach i of numlist 201/227 401/414 424 {
	replace s`i'quant_b = "" if s`i'quant_b == "."
}

browse *var_b
tostring s*var_b, replace
foreach j of numlist 201/227 401/414 424 501/539 {
	replace s`j'var_b = "" if s`j'var_b == "."
}

save "$temp\ASP_price_siaya_122016_IPA_v2.dta", replace


// Feb 2017 surveys - need correcting variable types
use "$input\ASP_price_siaya_022017_IPA.dta", clear
tab altitude, m
destring altitude, replace
save "$temp\ASP_price_siaya_022017_IPA_v2.dta", replace


// Baseline Siaya price surveys - Nov 2016
// Start building up total file from this
use "$input\ASP_price_siaya_112016_IPA.dta", clear

tab accuracy, m
destring accuracy, replace

browse *quant_b
tostring s*quant_b, replace
foreach i of numlist 201/227 401/414 424 {
	replace s`i'quant_b = "" if s`i'quant_b == "."
}

browse *var_b
tostring s*var_b, replace
foreach j of numlist 201/227 401/414 424 501/539 {
	replace s`j'var_b = "" if s`j'var_b == "."
}

// Append other files (using corrected versions as necessary)
append using "$temp\ASP_price_siaya_122016_IPA_v2.dta", gen(flag12_2016)
append using "$input\ASP_price_siaya_012017_IPA.dta", gen(flag01_2017)
append using "$temp\ASP_price_siaya_022017_IPA_v2.dta", gen(flag02_2017)
append using "$input\ASP_price_siaya_042017_IPA.dta", gen(flag04_2017)
append using "$input\ASP_price_siaya_052017_IPA.dta", gen(flag05_2017)
append using "$input\ASP_price_siaya_062017_IPA.dta", gen(flag06_2017)


// Make formid for Siaya markets consistent with Rachuonyo 
// Numbering order comes from price survey management document
replace formid = "ASP_price_SY01" if formid == "ASP_price_baseline_BONDO"
replace formid = "ASP_price_SY02" if formid == "ASP_price_baseline_Ajigo" ///
	| formid == "ASP_price_Ajigo"
replace formid = "ASP_price_SY03" if formid == "ASP_price_baseline_Abom"
replace formid = "ASP_price_SY04" if formid == "ASP_price_baseline_Ndira"
replace formid = "ASP_price_SY05" if formid == "ASP_price_baseline_Usenge"
replace formid = "ASP_price_SY06" if formid == "ASP_price_baseline_Uhwaya"
replace formid = "ASP_price_SY07" if formid == "ASP_price_baseline_NAMBO"
replace formid = "ASP_price_SY08" if formid == "ASP_price_baseline_Usigu"
replace formid = "ASP_price_SY09" if formid == "ASP_price_baseline_Nyamonye" ///
	| formid == "ASP_price_Nyamonye"
replace formid = "ASP_price_SY10" if formid == "ASP_price_baseline_Bondo-Kwach"
replace formid = "ASP_price_SY11" if formid == "ASP_price_baseline_DARAJA"
replace formid = "ASP_price_SY12" if formid == "ASP_price_baseline_Ugambe"
replace formid = "ASP_price_SY13" if formid == "ASP_price_baseline_OELE BEACH_"
replace formid = "ASP_price_SY14" if formid == "ASP_price_baseline_Utonga" ///
	| formid == "ASP_price_Utonga" | formid == "ASP_price_baseline_UTONGA"
replace formid = "ASP_price_SY15" if formid == "ASP_price_baseline_Kamenga"
replace formid = "ASP_price_SY16" if formid == "ASP_price_baseline_KAPIYO"
replace formid = "ASP_price_SY17" if formid == "ASP_price_baseline_Kambajo"
replace formid = "ASP_price_SY18" if formid == "ASP_price_baseline_Maranda"
replace formid = "ASP_price_SY19" if formid == "ASP_price_baseline_Koyucho" ///
	| formid == "ASP_price_Koyucho"
replace formid = "ASP_price_SY20" if formid == "ASP_price_baseline_Wichlum" ///
	| formid == "ASP_price_Wich Lum" | formid == "ASP_price_WichLum" | formid == "ASP_price_Wichlum"
replace formid = "ASP_price_SY21" if formid == "ASP_price_baseline_Anyungi"
replace formid = "ASP_price_SY22" if formid == "ASP_price_baseline_Uhanya" ///
	| formid == "ASP_price_Uhanya"
replace formid = "ASP_price_SY23" if formid == "ASP_price_baseline_Nyenye"
replace formid = "ASP_price_SY24" if formid == "ASP_price_baseline_Anyanga"


// Correct errors
replace dd = 27 if formid == "ASP_price_SY07"
replace s2market_1 = "Nambo" if formid == "ASP_price_SY07"
replace s2dd_1 = 27 if formid == "ASP_price_SY07"
replace s2mm_1 = 11 if formid == "ASP_price_SY07"
*replace observations = "Airtime vouchers given out were 20KSH in value (not 50KSH)" if formid == "ASP_price_SY07"

// swap round two values
gen toswap = accuracy 
replace accuracy = altitude if formid == "ASP_price_SY14" & mm == 6 & dd == 14 & yy == 2017 // Utonga
replace altitude = toswap if formid == "ASP_price_SY14" & mm == 6 & dd == 14 & yy == 2017
replace accuracy = altitude if formid == "ASP_price_SY19" & mm == 6 & dd == 14 & yy == 2017 // Koyucho
replace altitude = toswap if formid == "ASP_price_SY19" & mm == 6 & dd == 14 & yy == 2017
drop toswap

// missing decimal points
replace accuracy = accuracy/10 if formid == "ASP_price_SY22" & mm == 6 & dd == 15 & yy == 2017 // Uhanya
replace altitude = altitude/10 if formid == "ASP_price_SY22" & mm == 6 & dd == 15 & yy == 2017 
replace accuracy = accuracy/10 if formid == "ASP_price_SY09" & mm == 6 & dd == 14 & yy == 2017 // Nyamonye
replace altitude = altitude/10 if formid == "ASP_price_SY09" & mm == 6 & dd == 14 & yy == 2017
replace accuracy = accuracy/10 if formid == "ASP_price_SY20" & mm == 6 & dd == 15 & yy == 2017 // Wich Lum
replace altitude = altitude/10 if formid == "ASP_price_SY20" & mm == 6 & dd == 15 & yy == 2017
replace accuracy = accuracy/10 if formid == "ASP_price_SY19" & mm == 6 & dd == 14 & yy == 2017 // Koyucho
replace altitude = altitude/10 if formid == "ASP_price_SY19" & mm == 6 & dd == 14 & yy == 2017
replace altitude = altitude/10 if formid == "ASP_price_SY14" & mm == 6 & dd == 14 & yy == 2017 // Utonga


save "$temp\ASP_price_siaya.dta", replace

// What about x and X in s710 variables?
// Also, what doed * mean?

// What's formid2 in 012017 file?


log close

translate "$output\Distributions price data log.smcl" "$output\Distributions price data log.pdf", replace
