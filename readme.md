# ppx_format

This ppx rewriter rewrites expression of the shape `f ... {%i|...|}`.

It allows one to rewrite 

```ocaml
let () = Format.printf {|Hello, World %s %a %d%!|} s Format.pp_print_char (Char.chr 65) x
```

as:

```ocaml
let () = Format.printf {%i|Hello, World {%s s} {%a Format.pp_print_char % Char.chr 65} {%d x}%!|}
```

It works with any function that takes a printf format string as input, and does the same thing as using the function without the ppx.
