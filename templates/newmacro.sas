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
@Author(s):
    <Name Surename>

@Contributors:
    <Name2 Surename2>
    (<Name4 Surename4> etc..)

@Description: description of the macro, what is the reason, etc. etc. The long
    line goes like this. So this is a four chars indent.

@Dependencies:
    assign_libraries.sas
    another_dependency.sas

@Inputs: &DSIN

@Outputs: &DSOUT WORK.STATIC_OUTPUT WORK.DYNAMIC_OUTPUT_: &&MACRO_VARIABLE

@Required parameters:
    DSIN=: input dataset, ex. libname.memname or just memname if in WORK lib.

@Optional parameters:
    DSOUT=: output dataset, if blank, DSOUT=&DSIN..NEWMACRO To be more
        specific how to document, this is a very long sentence. As you can see,
        this is an eight character indentation. Just to make this text look
        nice.
    ANOTHER_PARAM=example: as you can see this parameter has a default value
        set (example)

@Notes: Put any related notices here. No need to have version/history - it is
    kept within git repository. Explain how macro might work etc etc etc
    Don't forget that you can remove anything you don't like in this macro.

    To check when the file was last time modified, see @BLOB.

@BLOB: $Id$
*******************************************************************************/
%macro newmacro;
    %put Macro &sysmacroname started.;
    %local __startdt;
    %let __startdt = %sysfunc(datetime());


    %put SOME CODE HERE;


    %macro_end:
    %put Macro &sysmacroname finished in %sysfunc(putn(%sysevalf(%sysfunc(datetime()) - &__startdt), tod.));
%mend newmacro;

/* Usage:

%newmacro;

/**/
