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

@Description: before merging or setting datasets with different length of char
    variables truncation can occur. This macro makes each matching character
    variable to have the maximum length across datasets.

@Dependencies:
    anyblankmvar.sas
    expand_datasets.sas

@Inputs: &DSIN

@Outputs: same datasets as &DSIN, or with suffix defined by parameter _SUFFIX

@Required parameters:
    DSIN=: input datasets, ex. LIBNAME. .MEMNAME LIBNAME.MEMNAME

@Optional parameters:
    _SUFFIX=: suffix to append to output datasets, default: blank

@Notes: At least two datasets needs to be defined for macro to process.
    Otherwise, macro will not do anything.
    If _SUFFIX is not blank, ex _SUFFIX=_M, and input dataset is L.M, output
    dataset will be L.M_M. However, if L.M_M exists - it will be overwritten.
    If _SUFFIX=_M and DSIN contains L.M and L.M_M, you can get unexpected
    results.

@BLOB: $Id$
*******************************************************************************/
%macro balancecharvars(
    DSIN=,
    _SUFFIX=
);
    %local __startdt blankmvars;
    %let __startdt = %sysfunc(datetime());

    %anyblankmvar(MVARS=DSIN _SUFFIX, _RETMVAR=blankmvars, _RETMVARS=YES);

    %if %sysfunc(indexw(&_RETMVARS, DSIN)) %then %do;
        %put DSIN is a required parameter.;
        %goto macro_end;
    %end;

    %expand_datasets(INMVAR=DSIN, EXCLUDE=SASUSER. SASHELP.);

    %if %str(&DSIN) eq %str() %then %do;
        %put No datasets available with DSIN=&DSIN.;
        %goto macro_end;
    %end;

    %local i dsname libname memname;
    %if &_SUFFIX ne %str() %then %do;
        %* Copy to destination every available dataset *;
        %let i = 1;
        %local newdsin;
        %let newdsin =;
        %do %while(%scan(&DSIN, &i, %str( )) ne %str());
            %let dsname = %scan(&DSIN, &i, %str( ));
            %let libname = %scan(&dsname, 1, .);
            %let memname = %scan(&dsname, 2, .);
            %let newdsin = &newdsin &dsname.&_SUFFIX;
            proc datasets nolist library=&libname nowarn force;
                %if %sysfunc(exist(&dsname.&_SUFFIX)) %then %do;
                    delete &memname.&_SUFFIX;
                    run;
                %end;
                append base=&memname.&_SUFFIX data=&memname;
                run;
            quit;
            %let i = %eval(&i + 1);
        %end;
        %let DSIN = &newdsin;
    %end;

    %if %index(%sysfunc(strip(&DSIN)), %str( )) eq 0 %then %do;
        %put Only one dataset (&DSIN) available - nothing to do, exiting..;
        %goto macro_end;
    %end;

    %* Do now what macro has to do: get common char variables, find maximum *;
    %* length across datasets for each char variable and change in every    *;
    %* dataset *;

    %local j modst name st dsid rc ds nalt;
    proc sql noprint;
        select distinct catx(" ", name, "character(", put(len, 8.), ")")
            into :modst separated by "|"
        from
            (select distinct
                upcase(name) as name length=32
                ,max(lenght) as len
                ,count(*)  as n
                from sashelp.vcolumns
                    where type eq "char"
                        %let i = 1;
                        %do %while(%scan(&DSIN, &i, %str( )) ne %str());
                            %if &i gt 1 %then or;
                            upcase(cats(libname, '.', memname)) eq "%scan(&DSIN, &i, %str( ))"
                            %let i = %eval(&i + 1);
                        %end;
                    group by name
                    having n > 1
            )
        ;

        %if %str(&modst) eq %str() %then %do;
            quit;
            %put No character variable to update, exiting..;
            %goto macro_end;
        %end;

        %let i = 1;
        %* Process every dataset *;
        %do %while(%scan(&DSIN, &i, %str( )) ne %str());
            %let ds = %scan(&DSIN, &i, %str( ));
            %let j = 1;
            alter table &ds
                modify
                %let nalt = 1;
                %let dsid = %sysfunc(open(&ds));
                %* Check each character variable if available*;
                %do %while(%scan(%str(&modst), &j, %str(|)) ne %str());
                    %let st = %scan(%str(&modst), &j, %str(|));
                    %let name = %scan(%str(&st), 1);
                    %* If dataset contains character variable - modify *;
                    %if %sysfunc(varnum(&dsid, &name)) gt 0 %then %do;
                        %if &nalt %then %let nalt = 0;
                        %else ,;
                        &st
                    %end;
                    %let j = %eval(&j + 1);
                %end;
                %let rc = %sysfunc(close(&ds));
            ;
            %let i = %eval(&i + 1);
        %end;
    quit;

    %macro_end:
    %put &sysmacroname finished in %sysfunc(putn(%sysevalf(%sysfunc(datetime()) - &__startdt), tod.));
%mend balancecharvars;
