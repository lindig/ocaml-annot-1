
module S = Scanner
module P = Parser

exception Error of string
let error fmt = Printf.kprintf (fun msg -> raise (Error msg)) fmt
let eprintf   = Printf.eprintf
let printf    = Printf.printf

let (@@) f x = f x

let process f = function
    | Some path -> 
        let io = open_in path in 
            ( f io
            ; close_in io
            )
    | None -> f stdin
            
let scan io =
    let lexbuf  = Lexing.from_channel io in
    let rec loop lexbuf =
        match S.token' lexbuf with
        | P.EOF  -> print_endline @@ S.to_string P.EOF
        | tok  -> ( print_endline @@ S.to_string tok
                  ; loop lexbuf
                  )
    in
        loop lexbuf

let escape io =
    let lexbuf = Lexing.from_channel io in
        Escape.escape stdout lexbuf

let doc io =
    let lexbuf  = Lexing.from_channel io in
    let ast     = P.litprog S.token' lexbuf in
        Syntax.index ast
        

let parse io =
    Syntax.print @@ doc io


let print_chunk chunk doc =
    let rec loop = function
        | Syntax.Str(s)  -> print_string s
        | Syntax.Ref(s)  -> List.iter loop (Syntax.SM.find s doc.Syntax.code)
        | Syntax.Sync(p) -> printf "# %d \"%s\"\n" p.Syntax.line p.Syntax.file
    in
        List.iter loop (Syntax.SM.find chunk doc.Syntax.code)

let expand chunk io =
    print_chunk chunk @@ doc io

let chunks io =
    let d = doc io in
    let print key v = print_endline key in
        Syntax.SM.iter print d.Syntax.code

let help this =
    ( eprintf "%s scan [file.lp]\n" this
    ; eprintf "%s parse [file.lp]\n" this
    ; exit 1
    )  
      
let main () =
    let argv    = Array.to_list Sys.argv in
    let this    = Filename.basename (List.hd argv) in
    let args    = List.tl argv in
        match args with
        | "scan" ::file::[]     -> process scan  (Some file)
        | "parse"::file::[]     -> process parse (Some file)
        | "scan" ::[]           -> process scan   None
        | "parse"::[]           -> process parse  None
        | "expand"::s::file::[] -> process (expand s) (Some file)
        | "chunks"::file::[]    -> process chunks (Some file)
        | "escape"::file::[]    -> process escape (Some file)
        
        | "help"::_             -> help this
        | "-help"::_            -> help this
        | []                    -> help this
        | _                     -> help this


let () = 
    try 
        main (); exit 0
    with 
        | Error(msg)         -> eprintf "error: %s\n" msg; exit 1
        | Failure(msg)       -> eprintf "error: %s\n" msg; exit 1
        | Scanner.Error(msg) -> eprintf "error: %s\n" msg; exit 1
        (*
        | _                  -> Printf.eprintf "some unknown error occurred\n"; exit 1  
        *)