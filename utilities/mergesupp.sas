/*******************************************************************************
Copyright (c) 2013 Tomas Demcenko

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

@Description: To merge SDTM supplemental qualifiers back to the domain dataset.

@Dependencies:

@Inputs: &DSIN &SUPPDSIN

@Outputs: &DSOUT

@Required parameters:
    DSIN=: input dataset, ex. libname.memname.

@Optional parameters:
    SUPPDS=: if blank, library where &DSIN resides will be checked for SUPP and
        SUPPxx. If both exist - both will be used to merge back the data.
    DSOUT=: output dataset, default: work.<&DSIN memname>_v

@Notes: Macro should be called outside data step. Output dataset will be overwritten.
    Temporary datasets __TMP01 __TMP02 will be created and deleted after running.

@BLOB: $Id$
*******************************************************************************/
%macro mergesupp(dsin=, suppds=, dsout=);
    %put Macro &sysmacroname started.;
    %local __startdt;
    %let __startdt = %sysfunc(datetime());

    %if %sysfunc(%superq(DSIN)=,boolean) %then %do;
        %put DSIN is a required parameter.;
        %goto macro_end;
    %end;

    %if not %sysfunc(exist(&dsin)) %then %do;
        %put Dataset &DSIN does not exist.;
        %goto macro_end;
    %end;

    %local libname memname;
    %if not %index(&DSIN, %str(.)) %then %let DSIN = WORK.%upcase(&DSIN);
    %else %let dsin = %upcase(&dsin);

    %let libname = %scan(&DSIN, 1, %str(.));
    %let memname = %scan(&DSIN, 2, %str(.));

    %* prepare suppds *;
    %if &dsout eq %str() %then %let dsout = WORK.&memname._v;



    %macro_end:
    %put Macro &sysmacroname finished in %sysfunc(putn(%sysevalf(%sysfunc(datetime()) - &__startdt), tod.));
%mend newmacro;

/* Usage:

%newmacro;

/**/
