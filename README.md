# SAS (r) Various Macro Utilities
=================================
## Here are macros for SAS. The Power to Know: www.sas.com
Directory listing
<pre>
utilites/                   macros run outside procedures and data steps
templates/                  template files
macro_map/                  graphical visualization of dependencies
</pre>
-------------------------------------------------------------------------------
SAS macro listings:
==================
## utilities/
<pre>
anyblankmvar:               check if macro variables are blank
compress_char_variables:    compress character variable to the maximum length of a variable value
expand_datasets:            checks and expands macro value to dataset names
upcasemvars:                upcases macro variable values
balancecharvars:            changes char variables across datasets to avoid truncations
mergesupp:                  merge supplemental qualifiers datasets back to the domain
</pre>
-------------------------------------------------------------------------------
## templates/
<pre>
newmacro.sas:               SAS macro template to write a new macro
</pre>
-------------------------------------------------------------------------------
## macro_map/
<pre>
macrotree.pl                Perl script to generate SAS macro dependencies
graphiz                     Dot file
macro_deps.png              Map
</pre>
