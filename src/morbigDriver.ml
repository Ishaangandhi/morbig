(**************************************************************************)
(*  -*- tuareg -*-                                                        *)
(*                                                                        *)
(*  Copyright (C) 2017,2018,2019 Yann Régis-Gianas, Nicolas Jeannerod,    *)
(*  Ralf Treinen.                                                         *)
(*                                                                        *)
(*  This is free software: you can redistribute it and/or modify it       *)
(*  under the terms of the GNU General Public License, version 3.         *)
(*                                                                        *)
(*  Additional terms apply, due to the reproduction of portions of        *)
(*  the POSIX standard. Please refer to the file COPYING for details.     *)
(**************************************************************************)

open Morbig

let save input_filename (cst : CST.program) =
  Options.(
    if backend () = NoSerialisation
    then
      ()
    else
      let cout = open_out (output_file_of_input_file input_filename) in
      begin match backend () with
      | Bin -> save_binary_cst cout cst
      | Json -> save_json_cst cout cst
      | SimpleJson -> JsonHelpers.save_as_json true cout cst
      | Dot -> JsonHelpers.save_as_dot cout cst
      | NoSerialisation -> assert false
      end;
      close_out cout
  )
(** write the concrete syntax tree [cst] to the output file
   corresponding to [input_filename]. The format and the name of the
   output file are determined by the program options. *)

let save_error input_filename message =
  let eout = open_out (input_filename ^ ".morbigerror") in
  output_string eout message;
  output_string eout "\n";
  close_out eout
(** write string [message] to the error file corresponding to
   [input_filename]. *)

let not_a_script input_filename =
  Options.skip_nosh ()
  && (Scripts.(is_elf input_filename || is_other_script input_filename))

let nb_inputs = ref 0
let nb_inputs_skipped = ref 0
let nb_inputs_erroneous = ref 0

let show_stats () =
  if Options.display_stats () then begin
      Printf.printf "Number of input files: %i\n" !nb_inputs;
      Printf.printf "Number of skipped files: %i\n" !nb_inputs_skipped;
      Printf.printf "Number of rejected files: %i\n" !nb_inputs_erroneous
    end

let parse_one_file input_filename =
  Debug.printf "Trying to open: %s\n" input_filename;
  incr nb_inputs;
  if not_a_script input_filename then
    incr nb_inputs_skipped
  else
    try
      parse_file input_filename |> save input_filename
    with e ->
      incr nb_inputs_erroneous;
      if Options.continue_after_error () then
        save_error input_filename (Errors.string_of_error e)
      else (
        output_string stderr (Errors.string_of_error e ^ "\n");
        exit 1
      )

let parse_input_files_provided_via_stdin () =
  try
    while true do
      parse_one_file (read_line ())
    done
  with End_of_file -> ()

let parse_input_files_provided_on_command_line () =
  if List.length (Options.input_files ()) <= 0 then begin
      Printf.eprintf "morbig: no input files.\n";
      exit 1
    end;
  List.iter parse_one_file (Options.input_files ())

let parse_interactively_via_stdin filename =
  let on_ps1 () = Printf.eprintf "%!$ %!";  in
  let on_ps2 () = Printf.eprintf "%!  > %!" in
  let csts = ref [] in
  let lexbuf = ref @@  (Morbig__ExtPervasives.lexing_make_interactive filename) in
  let parser_state = ref None in
  try
    while true do
    (
        incr nb_inputs;
        try
          on_ps1 ();
          let next_lexbuf, next_parser_state, next_cst =
            Engine.parse_interactively on_ps2 false PrelexerState.initial_state 
              !lexbuf !parser_state
          in
          parser_state := Some next_parser_state;
          lexbuf := next_lexbuf;
          csts := next_cst :: !csts
        with e ->
          incr nb_inputs_erroneous;
          if Options.continue_after_error () then
            save_error filename (Errors.string_of_error e)
          else (
            output_string stderr (Errors.string_of_error e ^ "\n");
            exit 1
          )
    )
    done
  with End_of_file -> 
    csts := List.rev !csts;
    let cst = Morbig__ExtPervasives.reduce CSTHelpers.empty_program CSTHelpers.concat_programs !csts in
    save filename cst.CST.value

let parse_input_files () =
  if Options.from_stdin () then
    parse_input_files_provided_via_stdin ()
  else if Options.interactive () then
  (
    if List.length (Options.input_files ()) != 1 then begin
      Printf.eprintf "morbig: must specify exactly one filename for interactive session.\n";
      exit 1
    end;
    let filename = List.hd @@ Options.input_files () in
    parse_interactively_via_stdin filename
  )
  else
    parse_input_files_provided_on_command_line ()

let main =
  Options.analyze_command_line_arguments ();
  parse_input_files ();
  show_stats ()
