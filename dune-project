(lang dune 3.14)

(name ppx_format)

(generate_opam_files true)

(source
 (github EmileTrotignon/ppx_format))

(authors "Emile Trotignon, Pixie Dust")

(maintainers "Emile Trotignon")

(license MIT)

(package
 (name ppx_format)
 (synopsis "Interpolate format strings")
 (description "String interpolation, but compatible with format strings")
 (depends
  (ocaml
   (>= 4.8.0))
  dune
  ppxlib
  ocamllex))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
