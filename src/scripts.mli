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

(** [is_other_script s] returns [true] when the file with name [s]
    starts with a magic string that indicates a script other than
    posix shell, otherwise it returns [false]. Raises [Sys_error]
    when the file cannot be opened. *)
val is_other_script: string -> bool

(** [is_elf s] returns [true] when the file with name [s] starts with
    the magic number for ELF, otherwise it returns [false].
    Raises [Sys_error] when the file cannot be opened. *)
val is_elf: string -> bool

(** [parse_file s] attempts to parse the file with name [s], and returns
    its concrete syntax tree. *)
val parse_file: string -> CST.program

(** [parse_string s c] attempts to parse the file with name [s] whose contents
    is [c], and returns its concrete syntax tree. *)
val parse_string: string -> string -> CST.program

(** [parse_string_interactive on_ps2 lexbuf state] reads input
      from the lexbuf, prompting with on_ps2 on incomplete commands at newlines.
      If state is not None, the parser will use that state to continue parsing
      from lexbuf. It returns the first command read, along with the lexbuf, and parser state.
   *)
val parse_string_interactive :
  (unit -> unit) ->
  Lexing.lexbuf ->
  Engine.state option ->
  Lexing.lexbuf * Engine.state * CST.program CST.located
