let s = "lala"

let x = 123

let () = Format.printf [%i "Hello, World {%d s} {%a Format.pp_print_char % Char.chr 65} {%d x} !\n%!"]