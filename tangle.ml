
module SM = Map.Make(String)

exception NoSuchFormat of string

type position = 
    { file:     string
    ; line:     int
    ; column:   int
    ; offset:   int
    }
    
type t = out_channel -> position -> string -> unit


    
let fprintf = Printf.fprintf
let escaped = String.escaped
let (@@) f x = f x
    
let plain io pos str = 
    output_string io str

let cpp io pos str =
    ( fprintf io "# %d \"%s\"\n" pos.line (escaped pos.file)
    ; output_string io str
    )

let comment cstr io pos str =
    ( fprintf io "%s %s %d\n" cstr (escaped pos.file) pos.line
    ; output_string io str
    )

let formats =
    List.fold_left (fun map (key,v) -> SM.add key v map) SM.empty
    [ "plain", plain
    ; "cpp", cpp
    ; "postscript", comment "%"
    ; "tex", comment "%"
    ; "ruby", comment "#"
    ; "shell", comment "#"
    ]

let lookup fmt = 
    try 
        SM.find fmt formats
    with
        Not_found -> raise (NoSuchFormat fmt)

let formats = List.map fst @@ SM.bindings formats     