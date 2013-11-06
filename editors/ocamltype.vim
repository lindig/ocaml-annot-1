" 
" Lookup type annotation at cursor position in *.annot file.
" The name for the annot file is derived from the buffer name.
" 
" By calling annot with a relative file name we make it
" search for the file (in a limited way).
"
function! OCamlType()
    let col  = col('.')
    let line = line('.')
    let file = expand("%:r")
    echo system("annot -n -type " . line . " " . col . " " . file . ".annot")
endfunction    
map <leader>t :call OCamlType()<return>


