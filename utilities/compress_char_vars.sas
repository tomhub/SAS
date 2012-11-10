/*******************************************************************************
Copyright (c) 2012 Tomas Demcenko

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
********************************************************************************
@Author(s):
    Tomas Demcenko

@Contributors:

@Description: to modify SAS dataset character variable length to maximum length
    of a value or to length $1 if all values are missing.

@Dependencies:

@Inputs: &DSIN

@Outputs: &DSOUT

@Required parameters:
    &DSIN: input dataset, ex. libname.memname or just memname if in WORK lib.

@Optional parameters:
    DSOUT=: output dataset, if blank, DSOUT=&DSIN
    VARS=: list of variables to check length and modify accordingly. If blank,
        all character variables will be processed.
    EXCLUDE_VARS=: a list of variable names to exclude from checking and
        modifying.

@Notes: &DSIN should not contain variable names ___LEN1, ___LEN2 - this will
    be used while checking the variable lengths.

@BLOB: $Id$
*******************************************************************************/
%macro compress_char_vars(dsin=, dsout=, vars=, exclude_vars=);
    %put Macro &sysmacroname started.;
    %local __startdt;
    %let __startdt = %sysfunc(datetime());

    %* Check if required parameter is non-missing;
    %if %sysevalf(%superq(dsin)=,boolean) %then %do;
        %put Macro parameter DSIN cannot be blank.;
        %goto macro_end;
    %end;

    %* Check if &DSIN exists..;
    %if not %sysfunc(exist(&dsin)) %then %do;
        %put Dataset DSIN="&dsin" does not exist.;
        %goto macro_end;
    %end;

    %* Define output dataset;
    %if %str(&dsout) eq %str() %then %let dsout=&dsin;

    %local __vars_to_modify __libname __memname;
    *% get libname and memname;
    %if %index(&dsin, .) %then %do;
        %let __libname = %upcase(%scan(&dsin, 1, .));
        %let __memname = %upcase(%scan(&dsin, 2, .));
    %end;
    %else %do;
        %let __libname = WORK;
        %let __memname = %upcase(&dsin);
    %end;


    %* get output libname and memname;
    %local __outlib __outname;
    %if %index(&dsout, .) %then %do;
        %let __outlib = %upcase(%scan(&dsout, 1, .));
        %let __outname = %upcase(%scan(&dsout, 2, .));
    %end;
    %else %do;
        %let __outlib = WORK;
        %let __outname = %upcase(&dsout);
    %end;

    %*get actual list of varialbes to modify;
    proc sql noprint;
        select
            distinct upcase(strip(name))
                into :__vars_to_modify separated by " "
            from sashelp.vcolumn
            where type eq "char" and libname eq "&__libname"
                and memname eq "&__memname"
                 %if %str(&vars) ne %str() %then %do;
                     and indexw(upcase("&vars"), upcase(strip(name)))
                 %end;
                 %if %str(&exclude_vars) ne %str() %then %do;
                     and indexw(upcase("&exclude_vars"), upcase(strip(name))) eq 0
                 %end;
        ;
    quit;

    %* Work on destination file *;
    %if &__libname ne &__outlib or &__memname ne &__outname %then %do;
        %* This needs to be fixed: dataset label will be lost.*;
        data &dsout;
            set &dsin;
        run;
    %end;

    %if %str(&__vars_to_modify) eq %str() %then %do;
        %put Nothing to do, exiting..;
        %goto macro_end;
    %end;

    %* check if dataset has at least one obs, otherwise, do nothing *;
    %local __dsid __rc __nobs;
    %let __dsid = %sysfunc(open(&dsout));
    %let __nobs = %sysfunc(attrn(&__dsid, NOBS));
    %* just in case we did not get the NOBS *;
    %if &__nobs eq -1 %then %let __nobs = %sysfunc(attrn(&dsid, NLOBSF));
    %let __rc = %sysfunc(close(&__dsid));

    %if &__nobs lt 1 %then %do;
        %put No obs - cannot check any value length, exiting..;
        %goto macro_end;
    %end;

    %put Variables to check and alter length: &__vars_to_modify;

    %local __i __nvars __lenghts;
    %let __nvars = %sysevalf(%sysfunc(lengthn(&__vars_to_modify)) - %sysfunc(lengthn(%sysfunc(compress(&__vars_to_modify)))) + 1);

    %* set &__LENx as local variables;
    %do __i = 1 %to &__nvars;
        %local __len&__i;
    %end;

    %* Get maximum value lenght per variable *;
    data _null_;
        set &dsout(keep=&__vars_to_modify) end=__eof;
        array __vars_to_modify {*} $ &__vars_to_modify;
        array __lens{*} %do __i=1 %to &__nvars; __len&__i %end; ;

        %* Minimum length for blank variables is 1 *;
        retain %do __i=1 %to &__nvars; __len&__i %end; 1;

        do __k = 1 to dim(__vars_to_modify);
            __lens[__k] = max(__lens[__k], lengthn(trimn(__vars_to_modify[__k])));
        end;

        if __eof then do;
            do __k = 1 to dim(__vars_to_modify);
                call symput("__len"||put(__k, 8.-L), put(__lens[__k], 8.));
            end;
        end;
    run;

    proc sql noprint;
        alter table &dsout
            modify
            %do __i = 1 %to &__nvars;
                %if &__i gt 1 %then ,;
                %scan(&__vars_to_modify, &__i) character(&&__len&__i)
            %end;
        ;
    quit;

    %macro_end:
    %put Macro &sysmacroname finished in %sysfunc(putn(%sysevalf(%sysfunc(datetime()) - &__startdt), tod.));
%mend compress_char_vars;
/* Usage example:
%compress_char_vars(dsin=sashelp.class,dsout=test);


/**/
