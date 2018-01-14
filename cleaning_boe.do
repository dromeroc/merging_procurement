/* 
Cleaning dataset of Bank of Spain data

This version: 
	Does the process for each variable separately.
	Uses the new dataset "names_nifs_1995_2013.dta"
	November, 2017

REQUIERES: 
	- To remove some characters: findit strip
	- To group companies with similar names: findit strgroup
	- To see some random results and check procedure: findit listsome

Damian Romero
UPF	
	
*/

clear
set more off

* Set global directory
global path "/Users/damianromero/Dropbox/Research_Assistant/UPF/Julian_diGiovanni"

* Change directory
cd "$path/python/stata_version"

********************************************************************************
* names_nifs_1995_2013 (Bank of Spain dataset)
********************************************************************************

* 1) Reading data
use names_nifs_1995_2013, clear

* 2) Remove some useless characters
/* 
This new dataset contains a lot of observations with useless characters, such
as "'" at the beginning and the end of names. Try to drop those first.
*/
g name_fc = regexr(name,"^(&|,|\.)","")
replace name_fc = regexr(name_fc,"&$","")
replace name_fc = subinstr(name_fc, `"""',  "", .)
replace name_fc = subinstr(name_fc, "'",  "", .)
replace name_fc = subinstr(name_fc, "-",  "", .)

* 3) Replace possible spellings of ESPAÑA
replace name_fc = regexr(name_fc,"ESPA—A|ESPAÑA","ESPANA")

* 4) Use the same loop of previous versions
foreach var of varlist name_fc{
	g `var'2 = `var'
	foreach rexp in " \(EN LIQUIDACION\)$" " \(EXTINGUIDA\)$" /*
		*/"\(EN LIQUIDACION\)$" "\(EXTINGUIDA\)$"{
		replace `var'2 = regexr(`var'2,"`rexp'","")
	}
	
	* Replacing all SA cases
	g `var'3 = `var'2 + " "
	foreach rexp in "[,]*[ ]*[sS](\.|,)?[ ]?[aA]\.?" "[,]*[ ]*[sS][ ]?(\.|,)?[ ]?(\.|,)?[aA]\.?[ ]?([lL]|[uU]|[pP])?[ ]?"{
		replace `var'2 = regexr(`var'3,"[^A-Z^a-z^0-9]+(`rexp')[^A-Z].*$",", @SA")
	}
	
	* Changing other specifications
	foreach rexp in "[,]? SOCIEDAD ANONIMA[ ]?[.]? $" "[,]? SOCIEDAD LIMITADA[ ]?[.]? $" /*
		*/"[^A-Z^a-z^0-9]+([,]*[ ]*[sS][ ]?(\.|,)?[ ]?(\.|,)?[lL]\.?)[^A-Z].*$" /*
		*/"[^A-Z^a-z^0-9]+([,]*[ ]*[sS][ ]?(\.|,)?[ ]?(\.|,)?[lL]\.?[ ]?([lL]|[uU]|[pP])?[ ]?)[^A-Z].*$"/*
		*/"[,]? SOCIEDAD ANONIMA LABORAL $"/*
		*/"[,]? SOCIEDAD DE RESPONS.*$" "[,]? [sS][.]?[ ]?[cC]?[.]?[ ]?[aA]?$"/*
		*/"[,]? SOCIEDAD LIMITADA LAB.*$"/*
		*/"[,]?[ ]?[sS][.]?[ ]?[lL][.]?[ ]?[nN]?[.]?[ ]?[eE][.]?[ ]?$"/*
		*/"[,]? SOCIEDAD (L|LIMI|LIMIT|LIMITA)[.]?.$"{
		replace `var'2 = regexr(`var'2,"`rexp'",", @SA")
	}
	
	* Changing weird characters
	* This part assumes which is the right way of writing things
	* Use 'charlist' to identify
	replace `var'2 = regexr(`var'2,"Ç|ç|¢|©","C")
	replace `var'2 = regexr(`var'2,"Ä|á|à|ã|Æ|ª|À|Ã|Â|Á","A")
	replace `var'2 = regexr(`var'2,"É|é|è|Ê|Ë|È","E")
	replace `var'2 = regexr(`var'2,"Ñ|ñ","N")
	replace `var'2 = regexr(`var'2,"Ö|ó|ò|Ø|º|Õ|Ó|Ò","O")
	replace `var'2 = regexr(`var'2,"í|ì|ï|Í|Î|Ï|Ì","I")
	replace `var'2 = regexr(`var'2,"ú|ü|µ|Ú|Û|Ù","U")
	
	* Drop weird final characters
	* Use 'charlist' to identify
	*replace `var'2 = regexr(`var'2,"\.$|,$|&$|\+$|/$|-$|:$|;$|¿$|·$|'$|Ç$|Ñ$|!$|@$|\\$|_$|`$|{$|}|\|$|~$","")
	
	* Erase initial and final blank spaces
	replace `var'2 = strtrim(`var'2)
}	

* To list some random cases
* listsome name name_fc2 if name!="", random max(10)

* 5) Clear @SA 
replace name_fc2 = regexr(name_fc2,", @SA","")
rename name_fc2 name_clean
drop name_fc*

* 6) Save database
replace name_clean = upper(name_clean)
replace name_clean = regexr(name_clean,"ESPA—OLA","ESPANOLA")
save names_BoS, replace
