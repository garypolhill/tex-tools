# tex-tools
Scripts for LaTeX files

This repository contains various scripts for mangling bits of LaTeX files as and when I feel like I need them

## `tex-2col-tab.pl`

Usage: `./tex-2col-tab.pl <tex file>`

This script takes a `.tex` file as input and tries to parse it to find tables as defined by `\begin{table}`. When it does, it looks for the `\begin{tabular}` bit and doubles up the number of columns, with an extra column in between. This should mean a 'long thin' table occupies half the space on a page. Don't expect it to handle complicatd tables very well, or to cope with inconsistently formatted and messy LaTeX code implementing the table. Data rows need to end with `\\` to be detected as such, and if there is an odd number of data rows, it needs columns of data separated with ` & ` (i.e. white space either side of the ampersand).

Output to stdout.
