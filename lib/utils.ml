open Ppxlib

let print_pos fmt (loc_start, loc_end) =
  Ocaml_common.Location.print_loc fmt {loc_start; loc_end; loc_ghost= false}

  let (let*) = Result.bind
