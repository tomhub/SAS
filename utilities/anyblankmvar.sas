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

@Description: to check if any of the macros are blank. Usually this check is
    required in macros to check if required parameters are not blank. This macro
    assignes a return value to specified macro parameter and produces a log
    message for each blank macro variable.

@Dependencies:

@Inputs: macro variables defined by &MVARS

@Outputs: macro variable defined by &_RETMVAR

@Required parameters:
    MVARS: a space separated list of macro variable names to check

@Optional parameters:
    _RETMVAR=CHKMBLANK: macro variable name to indicate if any of the checked
        macro variables are blank. If it is blank, no macro variable is used
        to indicate.
    _SETGLOBAL=NO|YES: if YES the &_RETMVAR will be set global, default: NO
    _RETMVARS=NO|YES: if YES, the return value is set to macro variable names
        which are blank. If NO, the return values are 0 (no blank macro
        variables) or 1 (1 or more blank macro variables), default: NO
    _TOLOG=YES|NO: if YES the macro variable names will be reported to log,
        default: YES

@Notes:

@BLOB: $Id$
*******************************************************************************/
%macro anyblankmvar(
    MVARS=,
    _RETMVAR=CHKMBLANK,
    _SETGLOBAL=NO,
    _RETMVARS=NO,
    _TOLOG=YES
);
    %put Macro &sysmacroname started.;
    %local __i __name;

    %if %sysevalf(%superq(_RETMVAR)=,boolean) %then %do;
        %local __temp;
        %let _RETMVAR = __temp;
    %end;
    %else %do;
        %if &_SETGLOBAL eq YES %then %do;
            %global &_RETMVAR;
        %end;
    %end;

    %let &_RETMVAR =;
    %let __i = 1;
    %do %while(%scan(&MVARS, &__i, %str( )) ne %str());
        %if not %sysevalf(%superq(%scan(&MVARS, &__i, %str( )))=,boolean) %then %do;
            %let &_RETMVAR = &&&_RETMVAR %scan(&MVARS, &__i, %str( ));
            %if &_TOLOG eq YES %then %put Macro variable %scan(&MVARS, &__i, %str( )) is blank.;
        %end;
        %let __i = %eval(&__i + 1);
    %end;

    %if &_RETMVARS eq NO %then %do;
        %if %sysfunc(%superq(&_RETMVAR)=,boolean) %then %let &_RETMVAR = 0;
        %else %let &_RETMVAR = 1;
    %end;
%mend anyblankmvar;
/* Usage:

%anyblankmvar(mvars=inputds outputds, _retmvar=isblank);

/**/
