(**************************************************************************)
(*  -*- tuareg -*-                                                        *)
(*                                                                        *)
(*  Copyright (C) 2017,2018 Yann Régis-Gianas, Nicolas Jeannerod,         *)
(*  Ralf Treinen.                                                         *)
(*                                                                        *)
(*  This is free software: you can redistribute it and/or modify it       *)
(*  under the terms of the GNU General Public License, version 3.         *)
(*                                                                        *)
(*  Additional terms apply, due to the reproduction of portions of        *)
(*  the POSIX standard. Please refer to the file COPYING for details.     *)
(**************************************************************************)

exception ParseError of Lexing.position

exception LexicalError of Lexing.position * string

let string_of_error = function
  | ParseError pos ->
     Printf.sprintf "%s: Syntax error."
       CSTHelpers.(string_of_lexing_position pos)
  | LexicalError (pos, msg) ->
     Printf.sprintf "%s: Lexical error (%s)."
       CSTHelpers.(string_of_lexing_position pos)
       msg
  | Failure s ->
     "Failure: " ^ s ^ "."
  | Sys_error s ->
     "Error: " ^ s ^ "."
  | e -> raise e
