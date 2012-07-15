
module S  = Scanner
module P  = Parser
module LP = Litprog
module T  = Tangle

exception Error of string
let error fmt = Printf.kprintf (fun msg -> raise (Error msg)) fmt
let eprintf   = Printf.eprintf
let printf    = Printf.printf
let giturl    = "https://github.com/lindig/lipsum.git"


let (@@) f x = f x

let copyright () =
    List.iter print_endline
    [ giturl
    ; "Copyright (c) 2012, Christian Lindig <lindig@gmail.com>"
    ; "All rights reserved."
    ; ""
    ; "Redistribution and use in source and binary forms, with or"
    ; "without modification, are permitted provided that the following"
    ; "conditions are met:"
    ; ""
    ; "(1) Redistributions of source code must retain the above copyright"
    ; "    notice, this list of conditions and the following disclaimer."
    ; "(2) Redistributions in binary form must reproduce the above copyright"
    ; "    notice, this list of conditions and the following disclaimer in"
    ; "    the documentation and/or other materials provided with the"
    ; "    distribution."
    ; ""
    ; "THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND"
    ; "CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES,"
    ; "INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF"
    ; "MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE"
    ; "DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR"
    ; "CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,"
    ; "SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT"
    ; "LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF"
    ; "USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED"
    ; "AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT"
    ; "LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN"
    ; "ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE"
    ; "POSSIBILITY OF SUCH DAMAGE."
    ]

type 'a result = Success of 'a | Failed of exn

let finally f x cleanup = 
    let result =
        try Success (f x) with exn -> Failed exn
    in
        cleanup x; 
        match result with
        | Success y  -> y 
        | Failed exn -> raise exn

let set_fname lexbuf fname =
    ( lexbuf.Lexing.lex_curr_p <-  
        { lexbuf.Lexing.lex_curr_p with Lexing.pos_fname = fname }
    ; lexbuf
    )

let scan_and_process f = function
    | Some path -> 
        let io = open_in path in
        let lexbuf = set_fname (Lexing.from_channel io) path in
            finally f lexbuf (fun _ -> close_in io)
    | None      -> 
        let lexbuf = set_fname (Lexing.from_channel stdin) "stdin" in
            f lexbuf
            
let scan lexbuf =
    let rec loop lexbuf =
        match S.token' lexbuf with
        | P.EOF  -> print_endline @@ S.to_string P.EOF
        | tok  -> ( print_endline @@ S.to_string tok
                  ; loop lexbuf
                  )
    in
        loop lexbuf

let escape lexbuf = 
    Escape.escape stdout lexbuf

let litprog lexbuf =
    let ast = P.litprog S.token' lexbuf in
        LP.make ast

let parse lexbuf =
    LP.print @@ litprog lexbuf

let tangle fmt chunk lexbuf =
    LP.tangle (litprog lexbuf) (T.lookup fmt) chunk

let weave lexbuf =
    (Weave.lookup "plain") stdout @@ LP.doc @@ litprog lexbuf

let chunks lexbuf =
    List.iter print_endline @@ LP.code_chunks @@ litprog lexbuf

let roots lexbuf =
    List.iter print_endline @@ LP.code_roots @@ litprog lexbuf

let check lexbuf =
    List.iter print_endline @@ LP.unknown_references @@ litprog lexbuf

let help io =
    let print_endline s = (output_string io s; output_char io '\n') in
    let this = "lipsum" in
    List.iter print_endline 
    [ this^" is a utility for literate programming"
    ; ""
    ; this^" help                               emit help to stdout"
    ; this^" roots [file.lp]                    list root chunks"
    ; this^" chunks [file.lp]                   list all chunks"
    ; this^" check [file.lp]                    emit undefined code chunks"
    ; this^" tangle [-f fmt] file.c [file.lp]   extract file.c from file.lp"
    ; this^" tangle -f                          show tangle formats available"
    ; this^" prepare [file]                     prepare file to be used as chunk"
    ; this^" copyright                          display copyright notice"
    ; ""
    ; "See the manual lipsum(1) for documentation."
    ; ""
    ; "Debugging commands:"
    ; this^" scan [file.lp]                     tokenize file and emit tokens"
    ; this^" parse [file.lp]                    parse file and emit it"
    ; ""
    ; giturl
    ; "Copyright (c) 2012 Christian Lindig <lindig@gmail.com>"
    ]

let tangle_formats () =
    print_endline @@ String.concat " " T.formats
 
let path = function 
    | []        -> None 
    | [path]    -> Some path 
    | args      -> error "expected a single file name but found %d" 
                        (List.length args) 
      
let main () =
    let argv    = Array.to_list Sys.argv in
    let args    = List.tl argv in
        match args with
        | "scan" ::args     -> scan_and_process scan  @@ path args
        | "parse"::args     -> scan_and_process parse @@ path args
        | "expand"::s::args -> scan_and_process (tangle "plain" s) @@ path args
        | "tangle"::"-f"::fmt::chunk::args -> 
                               scan_and_process (tangle fmt chunk) @@ path args
        | "tangle"::s::args -> scan_and_process (tangle "plain" s) @@ path args
        | "chunks"::args    -> scan_and_process chunks @@ path args
        | "roots"::args     -> scan_and_process roots @@ path args
        | "prepare"::args   -> scan_and_process escape @@ path args
        | "weave"::args     -> scan_and_process weave @@ path args        
        | "check"::args     -> scan_and_process check @@ path args        
        | "help"::_             -> help stdout; exit 0
        | "-help"::_            -> help stdout; exit 0
        | "copyright"::_        -> copyright (); exit 0
        | []                    -> help stderr; exit 1
        | _                     -> help stderr; exit 1


let () = 
    try 
        main (); exit 0
    with 
        | Error(msg)         -> eprintf "error: %s\n" msg; exit 1
        | Failure(msg)       -> eprintf "error: %s\n" msg; exit 1
        | Scanner.Error(msg) -> eprintf "error: %s\n" msg; exit 1
        | Sys_error(msg)     -> eprintf "error: %s\n" msg; exit 1
        | T.NoSuchFormat(s)  -> eprintf "unknown tangle format %s\n" s; exit 1
        | LP.NoSuchChunk(msg)-> eprintf "no such chunk: %s\n" msg; exit 1
        | LP.Cycle(s)        -> eprintf "chunk <<%s>> is part of a cycle\n" s;
                                exit 1
        (*
        | _                  -> Printf.eprintf "some unknown error occurred\n"; exit 1  
        *)