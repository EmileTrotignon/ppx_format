let s = "lala"

let x = 123

let () = Format.printf [%i "Hello, World {%s s} {%a Format.pp_print_char % Char.chr 65} {%d x} !\n%!"]


let () = Printf.printf {%i|Hello, escaping {%s " {%s-\"-"}|}


let () = Format.fprintf Format.std_formatter [%i "Hello, World {%s s} {%a Format.pp_print_char % Char.chr 65} {%d x} !\n%!"]


let () = Printf.fprintf stdout {%i|Hello, World {%s s} {%d x} !{%c '\n'}%!|}

let fprintf_label ~ch =
  Printf.fprintf ch

let () = fprintf_label ~ch:stdout {%i|Hello, World {%s s} {%d x}!%!|}