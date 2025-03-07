(*
let a = "*)"
*)

(*

Printf.fprintf stderr {|asdpo {%s txt} {%d 123}|}

Printf.fprintf stderr {|asdpo %s %d|} txt 123

---

Printf.printf {| asdpo {%s txt} |}

Printf.printf {|asdpo %s|} txt


f a b
(f a) b
*)

{

open Utils

}

let digit =  "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"

let format_flag =  "#" | "0" | "-" | "+"

let format_width = digit+

let format_precision =  "."  digit+

let simple_format =
      "d"
    | "i"
    | "u"
    | "n"
    | "l"
    | "N"
    | "L"
    | "x"
    | "o"
    | "X"
    | "s"
    | "c"
    | "S"
    | "C"
    | "f"
    | "e"
    | "E"
    | "g"
    | "G"
    | "h"
    | "H"
    | "b"
    | "B"
    | (("l" | "n" | "L") ("d" | "i" | "u" | "x" | "X" | "o"))
    | "t"
    | "a"

let format =
    "%" (format_flag?) (format_width?) (format_precision?) simple_format

rule main b args = parse
| "{" (format as format)
  { Buffer.add_string b format;
    let pos_start = Lexing.lexeme_start_p lexbuf in
    let pos = Lexing.lexeme_end_p lexbuf in
    let* new_args =
      match parse_arg 0 (Buffer.create 8) [] pos lexbuf with
      | Ok v -> Ok v
      | Error `Unterminated_interpolation ->
          Error (`Unterminated_interpolation, pos_start, pos)
    in
    main b (new_args @ args) lexbuf }
| "{%" { find_unknown_format_specifier (Lexing.lexeme_start_p lexbuf) lexbuf }
| eof { Ok (Buffer.contents b , List.rev args) }
| _ { Buffer.add_string b (Lexing.lexeme lexbuf) ; main b args lexbuf }

and find_unknown_format_specifier pos_start = shortest
| (_* as fmt) (' ' | eof)
  { Error
      ( `Unknown_format_specifier ("%" ^ fmt)
      , pos_start
      , Lexing.lexeme_end_p lexbuf
      )
  }

and parse_string_literal depth b acc pos = parse
| '\\' '"'
  { Buffer.add_string b (Lexing.lexeme lexbuf);
    parse_string_literal depth b acc pos lexbuf
  }
| '"'
  { Buffer.add_string b (Lexing.lexeme lexbuf);
    parse_arg depth b acc pos lexbuf
  }
| _
  { Buffer.add_string b (Lexing.lexeme lexbuf);
    parse_string_literal depth b acc pos lexbuf
  }

and parse_arg depth b acc pos = parse
| '"'
  { Buffer.add_string b (Lexing.lexeme lexbuf);
    parse_string_literal depth b acc pos lexbuf
  }
| "{"
  { Buffer.add_string b (Lexing.lexeme lexbuf);
    parse_arg (depth + 1) b acc pos lexbuf
  }
| "%"
  {
    let acc = (Buffer.contents b, pos) :: acc in
    Buffer.clear b;
    let pos = Lexing.lexeme_end_p lexbuf in
    parse_arg depth b acc pos lexbuf
  }
| "}"
  {
    if depth = 0
    then Ok ((Buffer.contents b, pos) :: acc)
    else (
        Buffer.add_string b (Lexing.lexeme lexbuf) ;
        parse_arg (depth - 1) b acc pos lexbuf
    )
  }
| eof { Error `Unterminated_interpolation }
| _
  {
    Buffer.add_string b (Lexing.lexeme lexbuf) ;
    parse_arg depth b acc pos lexbuf
  }

{

let set_position lexbuf position =
  Lexing.(
    lexbuf.lex_curr_p <- {position with pos_fname= lexbuf.lex_curr_p.pos_fname} ;
    lexbuf.lex_abs_pos <- position.pos_cnum )

let string ~pos str =
  let lexbuf = Lexing.from_string str in
  set_position lexbuf pos;
  let b = Buffer.create (String.length str) in
  main b [] lexbuf
}
