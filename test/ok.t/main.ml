let s = "lala"

let x = 123

let () = Format.printf [%i "Hello, World {%s s} {%a Format.pp_print_char % Char.chr 65} {%d x} !\n%!"]


let () = Printf.printf {%i|Hello, escaping {%s " {%s-\"-"}|}
