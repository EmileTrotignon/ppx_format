  $ cp type_error.ml main.ml
  $ dune exec ./main.exe
  File "main.ml", line 5, characters 45-46:
  Error: The value s has type string but an expression was expected of type int
  [1]
  $ rm main.ml
  $ cp unterminated_interpolation.ml main.ml
  $ dune exec ./main.exe
  File "main.ml", line 1, characters 41-44:
  Error: unterminated interpolation
  [1]
  $ rm main.ml
  $ cp ocaml_syntax_error.ml main.ml
  $ dune exec ./main.exe
  File "main.ml", line 5, characters 44-51:
  Error: Syntax error in
          let x
  [1]
  $ rm main.ml
  $ cp ocaml_syntax_error_2.ml main.ml
  $ dune exec ./main.exe
  Hello, escaping {%s  !
  $ rm main.ml
  $ cp unknown_format_specifier.ml main.ml
  $ dune exec ./main.exe
  File "main.ml", line 1, characters 41-45:
  Error: unknown format specifier %q
  [1]
  $ rm main.ml
  $ cp unknown_format_specifier_2.ml main.ml
  $ dune exec ./main.exe
  File "main.ml", line 1, characters 41-44:
  Error: unknown format specifier %q
  [1]
