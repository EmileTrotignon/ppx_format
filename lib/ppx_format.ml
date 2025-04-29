open Ppxlib
(* open Utils *)

let set_position lexbuf position =
  Lexing.(
    lexbuf.lex_curr_p <- {position with pos_fname= lexbuf.lex_curr_p.pos_fname} ;
    lexbuf.lex_abs_pos <- position.pos_cnum )

let parse_expr t =
  let expr, pos = t in
  (* print_endline code ; *)
  let buffer = Lexing.from_string expr in
  set_position buffer pos ;
  try
    Ocaml_common.Parser.parse_expression Ocaml_common.Lexer.token buffer
    |> Selected_ast.Of_ocaml.copy_expression
  with Syntaxerr.Escape_error | Stdlib.Parsing.Parse_error ->
    let loc =
      {loc_start= pos; loc_end= Lexing.lexeme_end_p buffer; loc_ghost= false}
    in
    Ast_builder.Default.pexp_extension ~loc
    @@ Location.error_extensionf ~loc "Syntax error in\n%s" expr

let parse ~loc str : expression list =
  match Lexer.string ~pos:loc.loc_start str with
  | Error (e, loc_start, loc_end) ->
      let msg =
        match e with
        | `Unterminated_interpolation ->
            "unterminated interpolation"
        | `Unknown_format_specifier fmt ->
            Printf.sprintf "unknown format specifier %s" fmt
      in
      [ Ast_builder.Default.pexp_extension ~loc
          (let loc = {loc_start; loc_end; loc_ghost= false} in
           Location.error_extensionf ~loc "%s" msg ) ]
  | Ok (format, args) ->
      let args = List.map parse_expr args in
      Ast_builder.Default.(
        pexp_constant ~loc (Pconst_string (format, loc, None)) )
      :: args

let traverse =
  object
    inherit Ast_traverse.map as super

    method! expression e =
      let e = super#expression e in
      match e with
      | [%expr
          [%e? func]
            [%i
              [%e?
                { pexp_desc=
                    Pexp_constant (Pconst_string (payload, locpayload, _))
                ; _ }]]] ->
          let loc = func.pexp_loc in
          let args =
            parse ~loc:locpayload payload |> List.map (fun e -> (Nolabel, e))
          in
          Ast_builder.Default.pexp_apply ~loc func args
      | { pexp_desc=
            Pexp_apply
              ( func
              , [ arg
                ; ( Nolabel
                  , [%expr
                      [%i
                        [%e?
                          { pexp_desc=
                              Pexp_constant
                                (Pconst_string (payload, locpayload, _))
                          ; _ }]]] ) ] )
        ; _ } ->
          let loc = func.pexp_loc in
          let args =
            arg
            :: List.map (fun e -> (Nolabel, e)) (parse ~loc:locpayload payload)
          in
          Ast_builder.Default.pexp_apply ~loc func args
      | _ ->
          e
  end

let traverse_ui_impl = traverse#structure

let () = Driver.register_transformation "ppx_format" ~impl:traverse_ui_impl
