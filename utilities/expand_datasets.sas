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

@Description: expands values to dataset names, removes if non are found.
    The expansion is done this way:
    1. Change every LIBNAME. to LIBNAME.DATASET1 LIBNAME.DATASET2 and so on.
    2. Change every MEMNAME to WORK.MEMNAME
    3. Change every .MEMNAME to LIBNAME1.MEMNAME LIBNAME2.MEMNAME and so on.
    4. Removes non-existing and duplicate datasets from the list.

@Dependencies:
    anyblankmvar.sas

@Inputs: SASHELP.VSTABLE

@Outputs: macro variable specified by &_OUTMVAR

@Required parameters:
    INMVAR=: input macro variable

@Optional parameters:
    _OUTMVAR=: if blank, then &INMVAR is used to store a list of datasets,
        default: blank
    _EXCLUDE=: libraries and memnames to exclude, default: SASUSER. SASHELP.

@Notes:

@BLOB: $Id$
*******************************************************************************/
%macro expand_datasets(
    INMVAR=,
    _OUTMVAR=,
    _EXCLUDE=SASUSER. SASHELP.
);
    %local __startdt __retblank;
    %let __startdt = %sysfunc(datetime());

    %* Check if user is sane *;
    %anyblankmvar(MVARS=INMVAR, _RETMVAR=__retblank);
    %if &__retblank %then %do;
        %put Macro variable is not set in INMVAR parameter.;
        %goto macro_end;
    %end;

    %anyblankmvar(MVARS=&INMVAR, _RETMAVAR=__retblank);
    %if &__retblank %then %do;
        %put Macro variable INMVAR=&INMVAR is blank.;
        %goto macro_end;
    %end;

    %if &_OUTMVAR eq %str() %then %let _OUTMVAR = &INMVAR;

    %if not %sysevalf(%superq(_EXCLUDE)=,boolean) %then %do;
        %expand_datasets(INMVAR=_EXCLUDE, _EXCLUDE=);
    %end;

    %local __i __ds __lib __mem;
    proc sql noprint;
        select upcase(cats(libname, '.', memname))
            into :&_OUTMVAR separated by " "
            from sashelp.vstable
            where (
            %let __i = 1;
            %do %while(%scan(&&&INMVAR, &__i, %str( )) ne %str());
                %* select all that user want *;

                %if &__i > 1 %then or;

                %let __ds = %scan(&&&INMVAR, &__i, %str( ));

                %if not %index(&__ds, %str(.)) %then %do;
                    %* no dot - search dataset in work *;
                    %let __lib = WORK.&__ds;
                %end;

                %let __lib = %scan(&__ds, 1, %str(.));
                %let __mem = %scan(&__ds, 2, %str(.));

                %if &__lib ne %str() %then %do;
                    upcase(libname) eq "&__lib"
                %end;
                %if &__lib ne %str() and &__mem ne %str() %then %do;
                    and
                %end;
                %if &__mem ne %str() %then %do;
                    upcase(memname) eq "&__mem"
                %end;

                %let __i = %eval(&__i + 1);
            %end;
            )
            %if %str(&_EXCLUDE) ne %str() %then %do;
                %* Very bad example, but it is almost the repeat of above *;
                and (
                    %let __i = 1;
                    %do %while(%scan(&_EXCLUDE, &__i, %str( )) ne %str());
                        %* exclude all that user want *;

                        %if &__i > 1 %then and;

                        %let __ds = %scan(&_EXCLUDE, &__i, %str( ));

                        %if not %index(&__ds, %str(.)) %then %do;
                            %* no dot - exclude dataset in work *;
                            %let __lib = WORK.&__ds;
                        %end;

                        %let __lib = %scan(&__ds, 1, %str(.));
                        %let __mem = %scan(&__ds, 2, %str(.));

                        %if &__lib ne %str() %then %do;
                            upcase(libname) ne "&__lib"
                        %end;
                        %if &__lib ne %str() and &__mem ne %str() %then %do;
                            and
                        %end;
                        %if &__mem ne %str() %then %do;
                            upcase(memname) ne "&__mem"
                        %end;

                        %let __i = %eval(&__i + 1);
                    %end;
                    )
            %end;
        ;
    quit;

    %macro_end:
    %put &sysmacroname finished in %sysfunc(putn(%sysevalf(%sysfunc(datetime()) - &__startdt), tod.));
%mend expand_datasets;
