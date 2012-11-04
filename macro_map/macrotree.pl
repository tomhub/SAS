#!/usr/bin/perl -w
#
# Copyright (c) 2012 Tomas Demcenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

use Getopt::Long;
use File::Slurp;
use strict;
use warnings;

my $mpath = ".";
GetOptions("path|p=s" => \$mpath);

unless (-d $mpath) {
    die "Could not access or does not exist: $mpath";
}

opendir(DIR, $mpath) or die $!;

my @existing_macros;
my @dependency_macros;
my @independent_macros;

my %deps;

while(my $file = readdir(DIR)) {
    # select only SAS files;
    # probably we want recursively find programs inside... TODO later.
    next unless (-f "$mpath/$file");

    next unless ($file =~ m/\.sas$/i);

    print("Found: $file\n");
    push @existing_macros, $file;
    my $file_contents = read_file "$mpath/$file";
    $deps{"$file"} = [$file_contents =~ m/[[:word:]]+\.sas/gi];
    unless ($deps{"$file"}[0]) {
        push @independent_macros, $file;
    }
}

close(DIR);

my %macros = map {$_, 1} @existing_macros;
@existing_macros = sort(keys %macros);


# Create blank file
open FILE, ">graphiz" or die $!;
print FILE "digraph unix {\n size=\"20, 20\"\n node [color=lightblue2, style=filled];\n";
close FILE;

# Append nodes and connections
open FILE, ">>graphiz" or die $!;

foreach my $macro (keys %deps) {

    foreach my $dep (@{$deps{"$macro"}}) {
        print FILE "\"$macro\" -> \"$dep\"\n";
    }
}

foreach my $im (@independent_macros) {
    print FILE "\"$im\"\n";
}


print FILE "}\n";
close FILE;
print "\n";
print "Now run: dot -Tpng graphiz -o macro_deps.png\n";
exit 0;
