/* 
Cleaning dataset of Procurement data

This version: 
	Does the process for each variable separately.
	Uses the new dataset "names_nifs_1995_2013.dta"
	Works with batches==1 cases
	Uses temp4.dta, which manually drops useless information
	January, 2018

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

* Run external function
run mysplit2

********************************************************************************
* BOE_final_all (Procurement dataset)
********************************************************************************

* 1) Reading data
* This version does the procedure directly, without manual dropping.
insheet using /*
*/"$path/spanish_contracts/JanRadermacher/finalData_201711080100/BOE_final_all.csv",/*
*/delim(";") clear

* 2) Create upper case company name and change format (to see it more easily in editor)
g name_clean_aux = upper(winningfirm)
g name_clean_b_aux = upper(winningfirms_batches)

* 3) Drop cases where there is no name
drop if winningfirm=="" & winningfirms_batches==""

* 4) Keep only relevant variables
keep identifier manual batches winningfirm winningfirms_batches name_clean_aux name_clean_b_aux
keep if batches==1

* Drop if declared "DESIERTO/A", "VARIOS", "NINGUNO/A", "ANULADO", "ESPANOLA",
* "CONTRATISTA" "EMPRESA:"
foreach var of varlist name_clean_aux name_clean_b_aux{
	drop if regexm(`var',"^(DESIERT[O|A]|VARIOS|NINGUN[O|A]|ANULADO|ESPANOLA)$")
	drop if regexm(`var',"^(NO PROCEDE|CONTRATISTA)$")
	drop if regexm(`var',"^(LICITACION DESIERTA)$")
	drop if regexm(`var',"^VER PERFIL DEL CONTRATANTE$")
	drop if regexm(`var',"^SE DECLARA DESIERTO POR FALTA DE OFERTAS$")
	drop if regexm(`var',"^NO HAY ADJUDICATARIO$")
	drop if regexm(`var',"^ADJUDICACION DESIERTA$")
	drop if regexm(`var',"^DESIERTO POR FALTA DE LICITADORES$")
	
	* Clean "numbers + :" at the beginning of names
	replace `var' = regexr(`var',"^[0-9].*:","")
	
	* Clean "letter + #" at the beginning of names, where # is an 0-digits number	
	replace `var' = regexr(`var',"^[A-Z][-]?[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][,]? ","")
	
	* Cleaning observations with certain expressions at the beginning
	foreach rexp in "CONTRATISTA[S]?[:]?[,]? " "EMPRESA: " "LOS DOS LOTES A"{
		replace `var' = regexr(`var',"^`rexp'","")
	}	
	
	* Clean observations with name starting as a date
	foreach rexp in "ENERO" "FEBRERO" "MARZO" "ABRIL" "MAYO" "JUNIO" "JULIO" /*
		*/"AGOSTO" "SEPTIEMBRE" "OCTUBRE" "NOVIEMBRE" "DICIEMBRE"{
		replace `var' = regexr(`var',"^([1-9][0-9]? DE `rexp' DE [0-9][0-9][0-9][0-9])","")
	}	
}

* Clean initial and final blank spaces
replace name_clean_b_aux = strtrim(name_clean_b_aux)
	
* Drop observations with only numbers in name
drop if regexm(name_clean_aux,"^: [0-1]")
drop if regexm(name_clean_b_aux,"^: [0-1]")

* Some names start with "1)" but are single firms. Clean those cases
replace name_clean_aux = regexr(name_clean_aux,"^1\) ","") if /*
*/regexm(name_clean_aux,"^[0-1]\)") & regexm(name_clean_aux,"2\)")!=1

replace name_clean_b_aux = regexr(name_clean_b_aux,"^1\) ","") if /*
*/regexm(name_clean_b_aux,"^[0-1]\)") & regexm(name_clean_b_aux,"2\)")!=1

* Drop if "Contratista" at the beginning
replace name_clean_aux = regexr(name_clean_aux,"^CONTRATISTA:[\.]?","")
replace name_clean_b_aux = regexr(name_clean_b_aux,"^CONTRATISTA:[\.]?","")

* Clean certain initial characters like "(,/,-,_)"
replace name_clean_b_aux = regexr(name_clean_b_aux,"^(\(|\)|/|-|_|:|, |,|S\)\. )+[ ]?","")

* Clean specific characters
replace name_clean_b_aux = regexr(name_clean_b_aux,"^5\.B\.[1-9]\. ","")

* Clean certain initial numbers plus characters
replace name_clean_b_aux = regexr(name_clean_b_aux,"^[1-9]+(\.|:|,)+[ ]?","")

* Clean certain initial words plus characters
replace name_clean_b_aux = regexr(name_clean_b_aux,"^LOTE [1-9]+(\.|:|,)","")

* Clean initial numbers plus PESETAS/EUROS
replace name_clean_b_aux = regexr(name_clean_b_aux,"^[1-9]+[0-9]+.(PESETAS|EUROS)+\)?(\.|,|:)? ","")
replace name_clean_b_aux = regexr(name_clean_b_aux,"^[1-9]+[0-9]+.(PESETAS|EUROS)+\)?(\.|,|:)?","")

* Clean initial EXPEDIENTE plus numbers and characters
replace name_clean_b_aux = regexr(name_clean_b_aux,"^EXPEDIENTE [0-9]+.: ","")

* Clean initial S plus (
replace name_clean_b_aux = regexr(name_clean_b_aux,"^S \(","")

* Clean initial (
replace name_clean_b_aux = regexr(name_clean_b_aux,"^\(","")

* Clean initial number plus EUROS
forval j=1/10{
	replace name_clean_b_aux = regexr(name_clean_b_aux,"\(?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)? EUROS\)?(\.|,)? ","")
	replace name_clean_b_aux = regexr(name_clean_b_aux,"\(?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)? EUROS\)?(\.|,)?","")
	replace name_clean_b_aux = regexr(name_clean_b_aux,"\(?[0-9]+(\.|,)?[0-9]+(\.|,)? EUROS\)?(\.|,)? ","")
	replace name_clean_b_aux = regexr(name_clean_b_aux,"\(?[0-9]+(\.|,)?[0-9]+(\.|,)? EUROS\)?(\.|,)?","")
	replace name_clean_b_aux = regexr(name_clean_b_aux,"\(?[0-9]+(\.|,)? EUROS\)?(\.|,)? ","")
	replace name_clean_b_aux = regexr(name_clean_b_aux,"\(?[0-9]+(\.|,)? EUROS\)?(\.|,)?","")
}
	
* Clean initial number plus PESETAS
forval j=1/10{
	replace name_clean_b_aux = regexr(name_clean_b_aux,"\(?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)? PESETAS\)?(\.|,)? ","")
	replace name_clean_b_aux = regexr(name_clean_b_aux,"\(?[0-9]+(\.|,)?[0-9]+(\.|,)?[0-9]+(\.|,)? PESETAS\)?(\.|,)?","")
	replace name_clean_b_aux = regexr(name_clean_b_aux,"\(?[0-9]+(\.|,)?[0-9]+(\.|,)? PESETAS\)?(\.|,)? ","")
	replace name_clean_b_aux = regexr(name_clean_b_aux,"\(?[0-9]+(\.|,)?[0-9]+(\.|,)? PESETAS\)?(\.|,)?","")
	replace name_clean_b_aux = regexr(name_clean_b_aux,"\(?[0-9]+(\.|,)? PESETAS\)?(\.|,)? ","")
	replace name_clean_b_aux = regexr(name_clean_b_aux,"\(?[0-9]+(\.|,)? PESETAS\)?(\.|,)?","")
}

* Clean EXPEDIENTE plus number
forval j=1/10{
	replace name_clean_b_aux = regexr(name_clean_b_aux,"EXPEDIENTE [0-9]+(\.|,)?[0-9]+(\.|,|:)?[0-9]+(\.|,|:)[ ]?","")
	replace name_clean_b_aux = regexr(name_clean_b_aux,"EXPEDIENTE [0-9]+(\.|,)?[0-9]+(\.|,|:)?[ ]?","")
	replace name_clean_b_aux = regexr(name_clean_b_aux,"EXPEDIENTE [0-9]+(\.|,)?[0-9]+[ ]?","")
}

* Clean initial number plus dot
replace name_clean_b_aux = regexr(name_clean_b_aux,"^\(?[1-9]+\.","")

********************************************************************************

* Use the same loop of previous versions (MAIN FILTER)
foreach var of varlist name_clean_b_aux{
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
	foreach rexp in "[,]?[ ]?SOCIEDAD ANONIMA[ ]?[.]?[,]?.*$" "[,]?[ ]?SOCIEDAD LIMITADA[ ]?[.]?[ ]?.*$" /*
		*/"[^A-Z^a-z^0-9]+([,]*[ ]*[sS][ ]?(\.|,)?[ ]?(\.|,)?[lL]\.?)[^A-Z].*$" /*
		*/"[^A-Z^a-z^0-9]+([,]*[ ]*[lL][ ]?(\.|,)?[ ]?(\.|,)?[tT][ ]?(\.|,)?[dD]\.?)[^A-Z].*$" /*
		*/"[^A-Z^a-z^0-9]+([,]*[ ]*[sS][ ]?(\.|,)?[ ]?(\.|,)?[rR][ ]?(\.|,)?[lL]\.?)[^A-Z].*$" /*
		*/"[^A-Z^a-z^0-9]+([,]*[ ]*[sS][ ]?(\.|,)?[ ]?(\.|,)?[lL]\.?[ ]?([lL]|[uU]|[pP])?[ ]?)[^A-Z].*$"/*
		*/"[,]? SOCIEDAD ANONIMA LABORAL $"/*
		*/"[,]? SOCIEDAD LIMITADA UNIPERSONAL"/*
		*/"[,]? SOCIEDAD DE RESPONS.*$" "[,]? [sS][.]?[ ]?[cC]?[.]?[ ]?[aA]?$"/*
		*/"[,]? SOCIEDAD LIMITADA LAB.*$"/*
		*/"[,]?[ ]?[sS][.]?[ ]?[lL][.]?[ ]?[nN]?[.]?[ ]?[eE][.]?[ ]?$"/*
		*/"[,]? SOCIEDAD (L|LIMI|LIMIT|LIMITA)[.]?.$"/*
		*/"[,]?[ ]?SOCIEDAD ANO-NIMA[(.|,)]?.*$"/*
		*/"[,]?[ ]?SOCIEDAD COOPERATIVA LIMITADA[(.|,)]?.*$"/*
		*/"[,]?[ ]?S[\.]?[ ]?COOP[(.|,)]?.*$"{
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

* 5) Arrange format of new names
format %100s winningfirms_batches name_clean_b_aux*

* 5) Clear @SA 
replace name_clean_b_aux2 = regexr(name_clean_b_aux2,", @SA","")
rename name_clean_b_aux2 name_clean
drop name_clean_b_aux*

* Solve initial characters problem
replace name_clean = regexr(name_clean,"^\., ","")

* 6) Save database
save names_Proc_1_alt, replace
