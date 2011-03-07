(* Yoann Padioleau
 * 
 * Copyright (C) 2011 Facebook
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2.1 as published by the Free Software Foundation, with the
 * special exception on linking described in file license.txt.
 * 
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the file
 * license.txt for more details.
 *)
open Common 

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)

(*****************************************************************************)
(* Types *)
(*****************************************************************************)
type program2 = Ast_web.web_document * Ast_web.token list

exception Parse_error of Parse_info.info

(*****************************************************************************)
(* Main entry point *)
(*****************************************************************************)

let parse2 filename = 
  raise Todo

let parse a = 
  Common.profile_code "Parse_web.parse" (fun () -> parse2 a)
