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

@Description: gets the information from sashelp.vtable about the defined
    datasets.

@Dependencies:
    anyblankmvar.sas
    expand_datasets.sas
    upcasemvars.sas

@Inputs: SASHELP.VTABLE

@Outputs: &_DSOUT

@Required parameters:
    DSIN=: datasets to describe. The value can be the actual table, ex.
        SASHELP.CLASS or datasets in a specified library defined as SASHELP.
        or dataset in any assigned library, ex. .CLASS or any combination of
        described values.

@Optional parameters:
    _DSOUT=: output dataset, if blank, DSOUT=DATASET_STRUCTURE (default value).
    _EXCLUDE=: datasets to exclude, defined in the same style as DSIN values,
        default: WORK. SASHELP. SASUSER. &DSOUT

@Notes:
    Default value for exclude is WORK, SASHELP and SASUSER libraries from 
    the list of libraries to search.

@BLOB: $Id$
*******************************************************************************/
%macro get_dataset_structure(
    DSIN=,
    _DSOUT=DATASET_STRUCTURE,
    _EXCLUDE=WORK. SASHELP. SASUSER. &DSOUT
);
    %put Macro &sysmacroname started.;
    %local __startdt __retmis __i;
    %let __startdt = %sysfunc(datetime());

    %upcasemvars(MVARS=DSIN _DSOUT _EXCLUDE);

    %* Check if user is sane *;
    %anyblankmvar(
        MVARS=DSIN _DSOUT _EXCLUDE,
        _RETMVAR=__retmis,
        _RETMVARS=YES,
        _TOLOG=NO
    );

    %if %index(&__retmis, DSIN) %then %do;
        %* So user forgot to set DSIN *;
        %put Datasets not specified in DSIN parameter.;
        %goto macro_end;
    %end;

    %if %index(&__retmis, _DSOUT) %then %let _DSOUT=DATASET_STRUCTURE;

    %* Get list of datasets *;
    %expand_datasets(INMVAR=DSIN, _EXCLUDE=&_EXCLUDE);

    %if %str(&DSIN) eq %str() %then %do;
        %put Nothing exists to check.;
        %goto macro_end;
    %end;

    data &_DSOUT;
        set sashelp.vtable
            (where=(upcase(cats(libname, '.', memname)) in (
                %let __i = 1;
                %do %while(%scan(&DSIN, &__i, %str( )) ne %str());
                    "%scan(&DSIN, &__i, %str( ))"
                    %let __i = %eval(&__i + 1);
                %end;
                )
            ));
    run;

    %macro_end:
    %put Macro &sysmacroname finished in %sysfunc(putn(%sysevalf(%sysfunc(datetime()) - &__startdt), tod.));
%mend get_dataset_structure;

/* Usage:

%newmacro;

/**/
