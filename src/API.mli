(**************************************************************************)
(*  Copyright (C) 2017 Yann Régis-Gianas, Nicolas Jeannerod,              *)
(*  Ralf Treinen.                                                         *)
(*                                                                        *)
(*  This is free software: you can redistribute it and/or modify it       *)
(*  under the terms of the GNU General Public License, version 3.         *)
(*  The complete license terms can be found in the file COPYING.          *)
(**************************************************************************)

(** This interface defines the API of libmorbig *)

(** Raised in case of syntax error with a message. *)
exception SyntaxError of CST.position * string

(** [parse_file filename] performs the syntactic analysis of
   [filename] and returns a concrete syntax tree if [filename] content
   is syntactically correct.
   Raise {SyntaxError (pos, msg)} otherwise. *)
val parse_file: string -> CST.complete_command_list
