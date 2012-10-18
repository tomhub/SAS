/*******************************************************************************
Copyright (c) <year> <author>

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
-Author: <Name Surename>

-Contributors: <Name2 Surename2>
               <Name4 Surename4> etc..
    
-Purpose: short description of the macro, what is the reason etc. etc.

-Dependencies: assign_libraries.sas
               another_dependency.sas

-Inputs: <defined by parmeter DSIN>

-Outputs: <defined by parameter DSOUT>

-Parameters:
   Required:
     DSIN: input dataset, ex. libname.memname or just memname in work.

   Optional:
     DSOUT: output dataset, if blank, DSOUT=&DSIN, default: blank

-Notes:
    Put any related notices here. No need to have version/history - it is kept
    within git. Explain how macro might do etc etc etc
*******************************************************************************/

%macro newmacro;
    %put Macro &sysmacroname started.;
    %local __startdt;
    %let __startdt = %sysfunc(datetime()); 
    %macro __skip; %mend __skip;


    %put SOME CODE HERE;


    %macro_end:
    %put Macro &sysmacroname finished in %sysfunc(putn(%sysevalf(%sysfunc(datetime()) - &__startdt), tod.));
%mend newmacro;

/* Usage:

%newmacro;

/**/
