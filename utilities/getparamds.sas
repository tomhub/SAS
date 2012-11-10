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

@Description: get existing datasets from parameter. Parameter can be used in 3
    ways: 1. LIBNAME.MEMNAME - actual dataset; 2. LIBNAME. - whole libname;
    3. .MEMNAME - all matching MEMNAME across assigned datasets. Parameter can
    have more than one dataset, variant assigned, but it needs to be space
    separated.

@Dependencies:
    anyblankmvar.sas

@Inputs: SASHELP.VSTABLE

@Outputs: macro variable &_RETMVAR

@Required parameters:
    MVAR=: macro variable with list of datasets

@Optional parameters:
    _RETMVAR=: macro variable to return list of existing LIBNAME.MEMNAME
        datasets, default: &MVAR

@Notes: SASUSER and SASHELP libraries are always excluded.

@BLOB: $Id$
*******************************************************************************/
%macro getparamds(
    MVAR=,
    _RETMVAR=
);
    %local __startdt blankmvars;
    %let __startdt = %sysfunc(datetime());

    %anyblankmvar(MVARS=MVAR _RETMVAR, _RETMVAR=blankmvars, _RETMVARS=YES);

    %if %sysfunc(indexw(&blankmvars, MVAR)) %then %do;
        %put MVAR is a required parameter and cannot be blank, exiting..;
        %goto %macro_end;
    %end;

    %if %sysfunc(indexw(&blankmvars,  _RETMVAR)) %then %do;
        %let _RETMVAR = &MVAR;
    %end;

    %upcasemvars(MVARS=MVAR);

    %local i memname libname p d;
    proc sql noprint;
        select distinct upcase(cats(libname, '.', memname))
            into :&_RETMVAR separated by " "
            from sashelp.vstable
                where libname not in ("SASUSER" "SASHELP")
                    and (
                        %let i = 1;
                        %do %while(%scan(&&&MVAR, &i) ne %str());
                            %let p = %scan(&&&MVAR, &i);

                            %let d = %index(&p, .);
                            %if &d eq 0 %then %do;
                                %let p = WORK.&p;
                            %end;

                            %if &i ne 1 %then %do;
                                or
                            %end;

                            %if &d eq %length(&p) %then %do;
                                upcase(libname) eq "%substr(&p, 1, %length(&p)-1)"
                            %end;
                            %else %if &d eq 1 %then %do;
                                upcase(memname) eq "%substr(&p, 2)"
                            %end;
                            %else %do;
                                upcase(libname) eq "%scan(&p, 1, .)"
                                    and
                                upcase(memname) eq "%scan(&p, 2, .)"
                            %end;
                            %let i = %eval(&i + 1);
                        %end;
                    ) /*end of where*/
        ;
    quit;

    %macro_end:
    %put &sysmacroname finished in %sysfunc(putn(%sysevalf(%sysfunc(datetime()) - &__startdt), tod.));
%mend balancecharvars;
