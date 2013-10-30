
# ANNOT 1.0.0

This is the source code for Annot, a tool to lookup annotations for
Objective Caml source code. The main purpose is to lookup the type
annotation for a given identifier in an OCaml source file from within an
editor.  Annot works by taking the line and column of the identifier
and looking up the information in an annotations file produced by the
OCaml compiler:

    $ annot -type 57 5 main.annot
    string -> (in_channel -> 'a) -> 'a

The code above looks up the type annotation for an identifier in
main.ml, at line 57, column 5. The invocation of this command is
typically bound to a key in an editor rather than invoked explicitly in
a shell.  For full documentation, please refer to the manual page
annot.pod.

OCaml 3.09 introduced the -dtypes compiler flag that causes the compiler
`ocamlc` to write annotation files while compiling a source file. In recent
versions of the compiler the flag was re-named to `-annot`.  Hence,
invoking compiler runs with `-annot` keeps the annotation files up to date.
Currently the compiler only generates type annotations; however, in
principle other annotations could be looked up as well.

## INSTALLATION

Annot is implemented in Objective Caml. To compile it from source code,
try the following:

    make
    make install

The latest tested version is OCaml 4.00.

## USING ANNOT FROM AN EDITOR

To use Annot from Vim, include the following code into your ~/.vimrc
file (also provided in editors/):

    function! OCamlType()
        let col  = col('.')
        let line = line('.')
        let file = expand("%:p:r")
        echo system("annot -n -type ".line." ".col." ".file.".annot")
    endfunction    
    map <leader>t :call OCamlType()<return>

The key combination ",t" (without quotes and assuming the leader key is
comma) looks up the type annotation for the identifier under the cursor.

Instructions for other editors can be found in the editors/ directory.

## SOURCE CODE

The source code is a literate program for the NoWeb literate programming
tools and resides in the *.nw file in directory src/. However, you don't
need NoWeb to compile and install the Annot.  

## COPYRIGHT

Please see the manual page annot.pod for the exact copyright. 

## AUTHORS AND CONTACT

Anil Madhavapeddy
anil@recoil.org
http://anil.recoil.org

Christian Lindig (original author)
lindig@gmail.com

