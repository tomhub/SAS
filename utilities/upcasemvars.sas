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

@Description: upcases macro variable values in listed macro variables, changes
    Y to YES and N to NO if required

@Dependencies:

@Inputs:

@Outputs:

@Required parameters:
    MVARS=: a list of macro variables to get their values uppercased.

@Optional parameters:
    _EXTEND=NO|YES: if YES, changes N to NO and Y to YES, default: NO

@Notes:

@BLOB: $Id$
*******************************************************************************/
%macro upcasemvars(
    MVARS=,
    _EXTEND=NO
);
    %put Macro &sysmacroname started.;
    %local __startdt;
    %let __startdt = %sysfunc(datetime());

    %if %str(&MVARS) eq %str() %then %do;
        %put No macro variables specified in MVARS.;
        %goto macro_end;
    %end;

    data _null_;
        i = 1;
        length mvar $32 mvars mval $65534;
        mvars = symget("mvars");
        do while(scan(mvars, i) ne " ");
            mvar = scan(mvars, i);
            mval = upcase(strip(symget(mvar)));
            %if &_EXTEND eq YES %then %do;
                select(mval);
                    when("Y") mval = "YES";
                    when("N") mval = "NO";
                    otherwise;
                end;
            %end;
            call symput(mvar, strip(mval));
            i = i + 1;
        end;
    run;

    %macro_end:
    %put Macro &sysmacroname finished in %sysfunc(putn(%sysevalf(%sysfunc(datetime()) - &__startdt), tod.));
%mend upcasemvars;

/* Usage:

%newmacro;

/**/
