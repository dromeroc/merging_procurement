/* 
Cleaning dataset of Procurement data

This version: 
	Does the process for each variable separately.
	Uses the new dataset "names_nifs_1995_2013.dta"
	Works with batches==0 cases
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

* Run external function
run mysplit2

********************************************************************************
* BOE_final_all (Procurement dataset)
********************************************************************************

* 1) Reading data
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

*-------------------------------------------------------------------------------
* Batches==0
*-------------------------------------------------------------------------------

* Drop some observations that are not alphanumeric names (nothing to save here)
g aux = 1 if regexm(name_clean_aux,"^(--|---)$")
drop if aux==1
drop aux

* Drop if declared "DESIERTO/A", "VARIOS", "NINGUNO/A", "ANULADO", "ESPANOLA",
* "CONTRATISTA" "EMPRESA:"
foreach var of varlist name_clean_aux{
	drop if regexm(`var',"^(DESIERT[O|A]|VARIOS|NINGUN[O|A]|ANULADO|ESPANOLA)$")/*
		*/ & batches==0
	drop if regexm(`var',"^(NO PROCEDE|CONTRATISTA)$")/*
		*/ & batches==0
	drop if regexm(`var',"^(LICITACION DESIERTA)$")/*
		*/ & batches==0
	drop if regexm(`var',"^VER PERFIL DEL CONTRATANTE$")/*
		*/ & batches==0
	drop if regexm(`var',"^SE DECLARA DESIERTO POR FALTA DE OFERTAS$")/*
		*/ & batches==0	
	drop if regexm(`var',"^NO HAY ADJUDICATARIO$")/*
		*/ & batches==0
	drop if regexm(`var',"^ADJUDICACION DESIERTA$")/*
		*/ & batches==0
	drop if regexm(`var',"^DESIERTO POR FALTA DE LICITADORES$")/*
		*/ & batches==0	
	
	* Clean "numbers + :" at the beginning of names
	replace `var' = regexr(`var',"^[0-9].*:","") if batches==0
	
	* Clean "letter + #" at the beginning of names, where # is an 0-digits number	
	replace `var' = regexr(`var',"^[A-Z][-]?[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][,]? ","")/*
		*/ if batches==0
	
	* Cleaning observations with certain expressions at the beginning
	foreach rexp in "CONTRATISTA[S]?[:]?[,]? " "EMPRESA: " "LOS DOS LOTES A"{
		replace `var' = regexr(`var',"^`rexp'","") if batches==0
	}	
	
	* Clean observations with name starting as a date
	foreach rexp in "ENERO" "FEBRERO" "MARZO" "ABRIL" "MAYO" "JUNIO" "JULIO" /*
		*/"AGOSTO" "SEPTIEMBRE" "OCTUBRE" "NOVIEMBRE" "DICIEMBRE"{
		replace `var' = regexr(`var',"^([1-9][0-9]? DE `rexp' DE [0-9][0-9][0-9][0-9])","")/*
		*/ if batches==0
	}	
}

* Write correct "EMPRESA"
replace name_clean_aux = regexr(name_clean_aux,"ESMPRESAS","EMPRESAS") if batches==0

* Drop "UNION TEMPORAL DE EMPRESAS"
replace name_clean_b_aux = regexr(name_clean_b_aux,"^[UNION TEMPORAL DE EMPRESAS]+[ FORMADA POR ]?","")/*
*/ if batches==0

* 3) Replace possible spellings of ESPAÑA
replace name_clean_aux = regexr(name_clean_aux,"ESPA—A|ESPAÑA","ESPANA")/*
*/ if batches==0
	
* Drop observations with only numbers in name
drop if regexm(name_clean_aux,"^: [0-1]") & batches==0

* Some names start with "1)" but are single firms. Clean those cases
replace name_clean_aux = regexr(name_clean_aux,"^1\) ","") if /*
*/regexm(name_clean_aux,"^[0-1]\)") & regexm(name_clean_aux,"2\)")!=1 & batches==0

* Drop if "Contratista" at the beginning
replace name_clean_aux = regexr(name_clean_aux,"^CONTRATISTA:[\.]?","") if batches==0

* Drop super freak case
drop if identifier=="BOE-B-2015-23824"

********************************************************************************

/* Detecting erroneous cases within Batches==0

Here I try to fix some cases that are assigned to a single firm (batches==0), 
while in reality they are for multiple firms.

Cases:
	- Starting with "UTE" and variations
	- Starting with "Union Temporal de Empresas"
	
The procedure is as follows
	(i) Use the expression above to detect relevant cases
	(ii) Drop the expression and any other irrelevant information at the 
		beginning (e.g. "UTE integrada por")
	(iii) Manually detect patterns to separate firms within the observation
	
Unfortunately, it is easier to work with an specific subset of observations
and not with the full sample and applying "if" conditions.

Update (December 21, 2017)
	Even doing case by case and by subsamples generates many errors. An 
	alternative is to apply an interative procedure over cases. Slower but more
	accurate.
*/

* 1) Generate name variable for these incorrect cases, an indicator variable
* 	 with completed cases, the variable that saves names, an id variable for 
* 	 each case (same role for identifier but harder to compare), and a dummy
* 	 variable that indicates if an id requieres extra manual work.
g name_wrong_batch = ""
g case_ok = .
g WFs = ""
g id_case = _n
g manual_id = .

* 2) Keep only if batches==0
/* There is too much data to apply the procedure. Better to work with subsets
	and then append. Also, is better to work with many different conditions 
	and not to try to do everything at one time (it takes a while) */	
keep if batches==0 // # obs: 95,283

* 3) "Union Temporal de Empresas"
* To detect these cases use:
* br if regexm(name_clean_aux,"^UNION TEMPORAL DE EMPRESAS") & batches==0

* (i-ii) Drop expression and irrelevant information
replace name_wrong_batch = /*
	*/regexr(name_clean_aux,"^UNION TEMPORAL DE EMPRESAS[,]?[/]?[:]?[ ]?","")
	
foreach rexp in "FORMADA POR LAS SIGUIENTES PERSONAS FISICAS: " /*
	*/"FORMADA POR LAS ENTIDADES "/*
	*/"(FORMADA|INTEGRADA|COMPUESTA)+ POR " "\(UTE\) "{
	replace name_wrong_batch = regexr(name_wrong_batch,"^(`rexp')","")
}
		
* Solve manually some specific cases
replace name_wrong_batch = regexr(name_wrong_batch,"^LEY 18/82 ","")

* (iii) Separate by patterns
quietly{
	g qn = 1 if regexm(name_clean_aux,"^UNION TEMPORAL DE EMPRESAS") /*
		*/& case_ok!=1 & regexm(name_wrong_batch,"([ ]/[ ][A-Z])")
	bysort qn: g qn_ = _n if qn==1
	sum qn_
	scalar rN = r(N)
}
	
qui sort id_case
forval j=1/`=rN'{
	mysplit2 name_wrong_batch if case_ok!=1 & qn_==`j' & /*
		*/regexm(name_clean_aux,"^UNION TEMPORAL DE EMPRESAS"), /*
		*/match(([ ]/[ ][A-Z])) posl(-1) posr(-1) maximum(10)
}
replace case_ok = 1 if WFs!=""

*_______________________________________________________________________________

drop qn*
quietly{
	g qn = 1 if regexm(name_clean_aux,"^UNION TEMPORAL DE EMPRESAS") /*
		*/& case_ok!=1 & regexm(name_wrong_batch,"([ ]-[ ][A-Z])")
	bysort qn: g qn_ = _n if qn==1
	sum qn_
	scalar rN = r(N)
}

forval j=1/`=rN'{
	mysplit2 name_wrong_batch if case_ok!=1 & qn_==`j' & /*
		*/regexm(name_clean_aux,"^UNION TEMPORAL DE EMPRESAS"), /*
		*/match(([ ]-[ ][A-Z])) posl(-1) posr(-1) maximum(10)
}
replace case_ok = 1 if WFs!=""

*_______________________________________________________________________________

drop qn*
quietly{
	g qn = 1 if regexm(name_clean_aux,"^UNION TEMPORAL DE EMPRESAS") /*
		*/& case_ok!=1 & regexm(name_wrong_batch,"([A-Z]/[A-Z])")
	bysort qn: g qn_ = _n if qn==1
	sum qn_
	scalar rN = r(N)
}

forval j=1/`=rN'{
	mysplit2 name_wrong_batch if case_ok!=1 & qn_==`j' & /*
		*/regexm(name_clean_aux,"^UNION TEMPORAL DE EMPRESAS"), /*
		*/match(([A-Z]/[A-Z])) posl(0) posr(0) maximum(10)
}		
replace case_ok = 1 if WFs!=""
*replace manual_id = 1 if id_case==16660

*_______________________________________________________________________________

drop qn*
quietly{
	g qn = 1 if regexm(name_clean_aux,"^UNION TEMPORAL DE EMPRESAS") /*
		*/& case_ok!=1 & regexm(name_wrong_batch,"([A-Z]-[A-Z])")
	bysort qn: g qn_ = _n if qn==1
	sum qn_
	scalar rN = r(N)
}

forval j=1/`=rN'{	
	mysplit2 name_wrong_batch if case_ok!=1 & qn_==`j' & /*
		*/regexm(name_clean_aux,"^UNION TEMPORAL DE EMPRESAS"), /*
		*/match(([A-Z]-[A-Z])) posl(0) posr(0) maximum(10)
}
replace case_ok = 1 if WFs!=""
*replace manual_id = 1 if id_case==48099

*_______________________________________________________________________________

drop qn*
quietly{
	g qn = 1 if regexm(name_clean_aux,"^UNION TEMPORAL DE EMPRESAS") /*
		*/& case_ok!=1 & regexm(name_wrong_batch,"(\.-[A-Z])")
	bysort qn: g qn_ = _n if qn==1
	sum qn_
	scalar rN = r(N)
}

forval j=1/`=rN'{
	mysplit2 name_wrong_batch if case_ok!=1 & qn_==`j' & /*
		*/regexm(name_clean_aux,"^UNION TEMPORAL DE EMPRESAS"), /*
		*/match((\.-[A-Z])) posl(-1) posr(0) maximum(10)
}		
replace case_ok = 1 if WFs!=""

*_______________________________________________________________________________

drop qn*
quietly{
	g qn = 1 if regexm(name_clean_aux,"^UNION TEMPORAL DE EMPRESAS") /*
		*/& case_ok!=1 & regexm(name_wrong_batch,"([A-Z]-[ ][A-Z])")
	bysort qn: g qn_ = _n if qn==1
	sum qn_
	scalar rN = r(N)
}

forval j=1/`=rN'{
	mysplit2 name_wrong_batch if case_ok!=1 & qn_==`j' & /*
		*/regexm(name_clean_aux,"^UNION TEMPORAL DE EMPRESAS"), /*
		*/match(([A-Z]-[ ][A-Z])) posl(0) posr(0) maximum(10)
}		
replace case_ok = 1 if WFs!=""

*_______________________________________________________________________________

drop qn*
quietly{
	g qn = 1 if regexm(name_clean_aux,"^UNION TEMPORAL DE EMPRESAS") /*
		*/& case_ok!=1 & regexm(name_wrong_batch,"([A-Z]/[ ][A-Z])")
	bysort qn: g qn_ = _n if qn==1
	sum qn_
	scalar rN = r(N)
}

forval j=1/`=rN'{
	mysplit2 name_wrong_batch if case_ok!=1 & qn_==`j' & /*
		*/regexm(name_clean_aux,"^UNION TEMPORAL DE EMPRESAS"), /*
		*/match(([A-Z]/[ ][A-Z])) posl(0) posr(0) maximum(10)
}		
replace case_ok = 1 if WFs!=""

* Drop some erroneous cases
drop if regexm(WFs,"^(SOCIEDAD ANONIMA|SOCIEDAD ANOMINA|SOCIEDAD LIMITADA|S\. A|S\. L)+") /*
	*/& case_ok==1 & regexm(name_clean_aux,"^UNION TEMPORAL DE EMPRESAS")

*-------------------------------------------------------------------------------	
	
* 4) "UTE" and variations
* To detect these cases use:
* br if regexm(name_clean_aux,"^U[\.]?T[\.]?E[\.]?") & batches==0

* (i-ii) Drop expression and irrelevant information
replace name_wrong_batch = /*
	*/regexr(name_clean_aux,"^U[\.]?T[\.]?E[\.]?[\)]?[:]? ","")

foreach rexp in "CONSTITUIDA POR LAS EMPRESAS " "INTEGRADA POR "{
	replace name_wrong_batch = regexr(name_wrong_batch,"^(`rexp')","") /*
	*/if regexm(name_clean_aux,"^U[\.]?T[\.]?E[\.]?[\)]?[:]? ")
}

* Replace some SA (and similar) cases 
forval j=1/50{
	* Final space
	replace name_wrong_batch = /*
		*/ regexr(name_wrong_batch,"[,]?[ ]+S[\.][ ]?(A|L)+[\.][ ]?[U|E]?[\.]?[ ]*"," @SA ") 
		*/ if case_ok!=1 & regexm(name_clean_aux,"^U[\.]?T[\.]?E[\.]?[\)]?[:]? ")
		
	replace name_wrong_batch = /*
		*/ regexr(name_wrong_batch,"[,]?[ ]+S[\.]?[ ](A|L)+[\.]?[ ][U|E]?[\.]?[ ]*"," @SA ") 
		*/ if case_ok!=1 & regexm(name_clean_aux,"^U[\.]?T[\.]?E[\.]?[\)]?[:]? ")
		
	replace name_wrong_batch = /*
		*/ regexr(name_wrong_batch,"[,]?[ ]+S[\.](A|L)+[\.]?[U|E]?[\.]?[ ]*"," @SA ") 
		*/ if case_ok!=1 & regexm(name_clean_aux,"^U[\.]?T[\.]?E[\.]?[\)]?[:]? ")
		
}

* (iii) Separate by patterns
drop qn*
quietly{
	g qn = 1 if regexm(name_clean_aux,"^U[\.]?T[\.]?E[\.]?[\)]?[:]? ") /*
		*/& case_ok!=1 & regexm(name_wrong_batch,"([ ]/[ ][A-Z])")
	bysort qn: g qn_ = _n if qn==1
	sum qn_
	scalar rN = r(N)
}

qui sort id_case
forval j=1/`=rN'{
	mysplit2 name_wrong_batch if case_ok!=1 & qn_==`j' & /*
		*/regexm(name_clean_aux,"^U[\.]?T[\.]?E[\.]?[\)]?[:]? "), /*
		*/match(([ ]/[ ][A-Z])) posl(-1) posr(-1) maximum(10)
}		
replace case_ok = 1 if WFs!=""
*replace manual_id = 1 if id_case==27257 | id_case==29527

*_______________________________________________________________________________

drop qn*
quietly{
	g qn = 1 if regexm(name_clean_aux,"^U[\.]?T[\.]?E[\.]?[\)]?[:]? ") /*
		*/& case_ok!=1 & regexm(name_wrong_batch,"([ ]-[ ][A-Z])")
	bysort qn: g qn_ = _n if qn==1
	sum qn_
	scalar rN = r(N)
}

forval j=1/`=rN'{
	mysplit2 name_wrong_batch if case_ok!=1 & qn_==`j' & /*
		*/regexm(name_clean_aux,"^U[\.]?T[\.]?E[\.]?[\)]?[:]? "), /*
		*/match(([ ]-[ ][A-Z])) posl(-1) posr(-1) maximum(10)
}		
replace case_ok = 1 if WFs!=""
/*replace manual_id = 1 if id_case==71925 | id_case==42799 | id_case==68839 /*
	*/id_case==45501 | id_case==2514 | id_case==38273 | id_case==64009 /*
	*/id_case==3638 | id_case==61574
*/
	
*_______________________________________________________________________________

drop qn*
quietly{
	g qn = 1 if regexm(name_clean_aux,"^U[\.]?T[\.]?E[\.]?[\)]?[:]? ") /*
		*/& case_ok!=1 & regexm(name_wrong_batch,"([A-Z]/[A-Z])")
	bysort qn: g qn_ = _n if qn==1
	sum qn_
	scalar rN = r(N)
}	
	
forval j=1/`=rN'{	
	mysplit2 name_wrong_batch if case_ok!=1 & qn_==`j' & /*
		*/regexm(name_clean_aux,"^U[\.]?T[\.]?E[\.]?[\)]?[:]? "), /*
		*/match(([A-Z]/[A-Z])) posl(0) posr(0) maximum(10)
}		
replace case_ok = 1 if WFs!=""

*_______________________________________________________________________________

drop qn*
quietly{
	g qn = 1 if regexm(name_clean_aux,"^U[\.]?T[\.]?E[\.]?[\)]?[:]? ") /*
		*/& case_ok!=1 & regexm(name_wrong_batch,"([A-Z]-[A-Z])")
	bysort qn: g qn_ = _n if qn==1
	sum qn_
	scalar rN = r(N)
}

forval j=1/`=rN'{
	mysplit2 name_wrong_batch if case_ok!=1 & qn_==`j' & /*
		*/regexm(name_clean_aux,"^U[\.]?T[\.]?E[\.]?[\)]?[:]? "), /*
		*/match(([A-Z]-[A-Z])) posl(0) posr(0) maximum(10)
}		
replace case_ok = 1 if WFs!=""

*_______________________________________________________________________________

drop qn*
quietly{
	g qn = 1 if regexm(name_clean_aux,"^U[\.]?T[\.]?E[\.]?[\)]?[:]? ") /*
		*/& case_ok!=1 & regexm(name_wrong_batch,"(\.-[A-Z])")
	bysort qn: g qn_ = _n if qn==1
	sum qn_
	scalar rN = r(N)
}

forval j=1/`=rN'{
	mysplit2 name_wrong_batch if case_ok!=1 & qn_==`j' & /*
		*/regexm(name_clean_aux,"^U[\.]?T[\.]?E[\.]?[\)]?[:]? "), /*
		*/match((\.-[A-Z])) posl(-1) posr(0) maximum(10)
}		
replace case_ok = 1 if WFs!=""

*_______________________________________________________________________________

drop qn*
quietly{
	g qn = 1 if regexm(name_clean_aux,"^U[\.]?T[\.]?E[\.]?[\)]?[:]? ") /*
		*/& case_ok!=1 & regexm(name_wrong_batch,"([A-Z]-[ ][A-Z])")
	bysort qn: g qn_ = _n if qn==1
	sum qn_
	scalar rN = r(N)
}
	
forval j=1/`=rN'{	
	mysplit2 name_wrong_batch if case_ok!=1 & qn_==`j' & /*
		*/regexm(name_clean_aux,"^U[\.]?T[\.]?E[\.]?[\)]?[:]? "), /*
		*/match(([A-Z]-[ ][A-Z])) posl(0) posr(0) maximum(10)
}		
replace case_ok = 1 if WFs!=""

*_______________________________________________________________________________

drop qn*
quietly{
	g qn = 1 if regexm(name_clean_aux,"^U[\.]?T[\.]?E[\.]?[\)]?[:]? ") /*
		*/& case_ok!=1 & regexm(name_wrong_batch,"([A-Z][ ]-[A-Z])")
	bysort qn: g qn_ = _n if qn==1
	sum qn_
	scalar rN = r(N)
}

forval j=1/`=rN'{
	mysplit2 name_wrong_batch if case_ok!=1 & qn_==`j' & /*
		*/regexm(name_clean_aux,"^U[\.]?T[\.]?E[\.]?[\)]?[:]? "), /*
		*/match(([A-Z][ ]-[A-Z])) posl(0) posr(0) maximum(10)
}		
replace case_ok = 1 if WFs!=""

*_______________________________________________________________________________

drop qn*
quietly{
	g qn = 1 if regexm(name_clean_aux,"^U[\.]?T[\.]?E[\.]?[\)]?[:]? ") /*
		*/& case_ok!=1 & regexm(name_wrong_batch,"([A-Z]/[ ][A-Z])")
	bysort qn: g qn_ = _n if qn==1
	sum qn_
	scalar rN = r(N)
}

forval j=1/`=rN'{
	mysplit2 name_wrong_batch if case_ok!=1 & qn_==`j' & /*
		*/regexm(name_clean_aux,"^U[\.]?T[\.]?E[\.]?[\)]?[:]? "), /*
		*/match(([A-Z]/[ ][A-Z])) posl(0) posr(0) maximum(10)
}
replace case_ok = 1 if WFs!=""

*-------------------------------------------------------------------------------

* 5) " EUROS), " and variations
* To detect these cases use:
* br if regexm(name_clean_aux," EUROS\), ") & batches==0

drop qn*
quietly{
	g qn = 1 if regexm(name_clean_aux," EUROS\), ") /*
		*/& case_ok!=1 & regexm(name_wrong_batch,"( EUROS\), )")
	bysort qn: g qn_ = _n if qn==1
	sum qn_
	scalar rN = r(N)
}

qui sort id_case
forval j=1/`=rN'{
	mysplit2 name_wrong_batch if case_ok!=1 & qn_==`j' & /*
		*/regexm(name_clean_aux," EUROS\), "), /*
		*/match("( EUROS\), )") posl(-1) posr(0) maximum(10)
}		
replace case_ok = 1 if WFs!=""

*-------------------------------------------------------------------------------

* 6) "[0-9] PESETAS\. " and variations
* To detect these cases use:
* br if regexm(name_clean_aux,"[0-9] PESETAS\. ") & batches==0

drop qn*
quietly{
	g qn = 1 if regexm(name_clean_aux,"[0-9] PESETAS\. ") /*
		*/& case_ok!=1 & regexm(name_wrong_batch,"([0-9] PESETAS\. )")
	bysort qn: g qn_ = _n if qn==1
	sum qn_
	scalar rN = r(N)
}

qui sort id_case
forval j=1/`=rN'{
	mysplit2 name_wrong_batch if case_ok!=1 & qn_==`j' & /*
		*/regexm(name_clean_aux,"[0-9] PESETAS\. "), /*
		*/match("([0-9] PESETAS\. )") posl(0) posr(0) maximum(10)
}		
replace case_ok = 1 if WFs!=""

*-------------------------------------------------------------------------------

* 7) " [1-9]\)" and variations
* Solve initial case which is "1) ". Add an initial white space
replace name_wrong_batch = regexr(name_clean_aux,"1\) "," 1) ") /*
	*/if regexm(name_clean_aux,"^1\) ") & case_ok!=1

drop qn*
quietly{
	g qn = 1 if regexm(name_wrong_batch," 1\) ") /*
		*/& case_ok!=1 & regexm(name_wrong_batch,"( [0-9]\) )")
	bysort qn: g qn_ = _n if qn==1
	sum qn_
	scalar rN = r(N)
}	
	
qui sort id_case
forval j=1/`=rN'{
	mysplit2 name_wrong_batch if case_ok!=1 & qn_==`j' & /*
		*/regexm(name_wrong_batch," 1\) "), /*
		*/match("( [0-9]\) )") posl(0) posr(0) maximum(10)
}		
replace case_ok = 1 if WFs!=""

/* The former generate many errors. Try the following instead
g asdf = 1 if regexm(name_wrong_batch," 1\) ") & case_ok!=1
bysort asdf: g asdf_ = _n if regexm(name_wrong_batch," 1\) ") & case_ok!=1

qui sum asdf_
qui sort id_case
forval j=3/67{
	mysplit2 name_wrong_batch if case_ok!=1 & asdf_==`j' & /*
	*/regexm(name_wrong_batch," 1\) "), /*
	*/match("( [0-9]\) )") posl(0) posr(0) maximum(10)
}*/
	
********************************************************************************

* Combine results
rename name_clean_aux name_clean_aux_
g name_clean_aux = ""
replace name_clean_aux = name_clean_aux_ if case_ok==.
replace name_clean_aux = WFs if case_ok==1

* 6??) Use the same loop of previous versions (MAIN FILTER)
foreach var of varlist name_clean_aux{
	g `var'2 = `var'
	foreach rexp in " \(EN LIQUIDACION\)$" " \(EXTINGUIDA\)$" /*
		*/"\(EN LIQUIDACION\)$" "\(EXTINGUIDA\)$"{
		replace `var'2 = regexr(`var'2,"`rexp'","") if batches==0
	}
	
	* Replacing all SA cases
	g `var'3 = `var'2 + " "
	foreach rexp in "[,]*[ ]*[sS](\.|,)?[ ]?[aA]\.?" "[,]*[ ]*[sS][ ]?(\.|,)?[ ]?(\.|,)?[aA]\.?[ ]?([lL]|[uU]|[pP])?[ ]?"{
		replace `var'2 = regexr(`var'3,"[^A-Z^a-z^0-9]+(`rexp')[^A-Z].*$",", @SA")/*
			*/ if batches==0
	}
	
	* Changing other specifications
	foreach rexp in "[,]?[ ]?SOCIEDAD ANONIMA[ ]?[.]?[,]?.*$" "[,]?[ ]?SOCIEDAD LIMITADA[ ]?[.]?[ ]?.*$" /*
		*/"[^A-Z^a-z^0-9]+([,]*[ ]*[sS][ ]?(\.|,)?[ ]?(\.|,)?[lL]\.?)[^A-Z].*$" /*
		*/"[^A-Z^a-z^0-9]+([,]*[ ]*[lL][ ]?(\.|,)?[ ]?(\.|,)?[tT][ ]?(\.|,)?[dD]\.?)[^A-Z].*$" /*
		*/"[^A-Z^a-z^0-9]+([,]*[ ]*[sS][ ]?(\.|,)?[ ]?(\.|,)?[rR][ ]?(\.|,)?[lL]\.?)[^A-Z].*$" /*
		*/"[^A-Z^a-z^0-9]+([,]*[ ]*[sS][ ]?(\.|,)?[ ]?(\.|,)?[lL]\.?[ ]?([lL]|[uU]|[pP])?[ ]?)[^A-Z].*$"/*
		*/"[,]? SOCIEDAD ANONIMA LABORAL $"/*
		*/"[,]? SOCIEDAD DE RESPONS.*$" "[,]? [sS][.]?[ ]?[cC]?[.]?[ ]?[aA]?$"/*
		*/"[,]? SOCIEDAD LIMITADA LAB.*$"/*
		*/"[,]?[ ]?[sS][.]?[ ]?[lL][.]?[ ]?[nN]?[.]?[ ]?[eE][.]?[ ]?$"/*
		*/"[,]? SOCIEDAD (L|LIMI|LIMIT|LIMITA)[.]?.$"/*
		*/"[,]?[ ]?SOCIEDAD ANO-NIMA[(.|,)]?.*$"/*
		*/"[,]?[ ]?SOCIEDAD COOPERATIVA LIMITADA[(.|,)]?.*$"/*
		*/"[,]?[ ]?S[\.]?[ ]?COOP[(.|,)]?.*$"{
		replace `var'2 = regexr(`var'2,"`rexp'",", @SA") if batches==0
	}
	
	* Changing weird characters
	* This part assumes which is the right way of writing things
	* Use 'charlist' to identify
	replace `var'2 = regexr(`var'2,"Ç|ç|¢|©","C") if batches==0
	replace `var'2 = regexr(`var'2,"Ä|á|à|ã|Æ|ª|À|Ã|Â|Á","A") if batches==0
	replace `var'2 = regexr(`var'2,"É|é|è|Ê|Ë|È","E") if batches==0
	replace `var'2 = regexr(`var'2,"Ñ|ñ","N") if batches==0
	replace `var'2 = regexr(`var'2,"Ö|ó|ò|Ø|º|Õ|Ó|Ò","O") if batches==0
	replace `var'2 = regexr(`var'2,"í|ì|ï|Í|Î|Ï|Ì","I") if batches==0
	replace `var'2 = regexr(`var'2,"ú|ü|µ|Ú|Û|Ù","U") if batches==0
	
	* Drop weird final characters
	* Use 'charlist' to identify
	*replace `var'2 = regexr(`var'2,"\.$|,$|&$|\+$|/$|-$|:$|;$|¿$|·$|'$|Ç$|Ñ$|!$|@$|\\$|_$|`$|{$|}|\|$|~$","")
	
	* Erase initial and final blank spaces
	replace `var'2 = strtrim(`var'2) if batches==0
}	

* 5) Arrange format of new names
format %100s winningfirm name_clean*

* 5) Clear @SA 
replace name_clean_aux2 = regexr(name_clean_aux2,", @SA","")
rename name_clean_aux2 name_clean
drop name_clean_aux*

* 6) Save database
save names_Proc_0, replace
