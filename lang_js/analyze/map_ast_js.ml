(* Yoann Padioleau
 *
 * Copyright (C) 2019 r2c
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
open OCaml

open Ast_js

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)

(* hooks *)

type visitor_in = {
(*
  kexpr: (expr  -> expr) * visitor_out -> expr  -> expr;
  kstmt: (stmt -> stmt) * visitor_out -> stmt -> stmt;
*)
  kinfo: (tok -> tok) * visitor_out -> tok -> tok;

}
and visitor_out = {
  vtop: toplevel -> toplevel;
  vprogram: program -> program;
  vexpr: expr -> expr;
  vany: any -> any;
}

let map_option = Common2.map_option
let map_scope x = x

let default_visitor =
  { 
(*
    kexpr   = (fun (k,_) x -> k x);
    kstmt = (fun (k,_) x -> k x);
*)
    kinfo = (fun (k,_) x -> k x);
  }

let (mk_visitor: visitor_in -> visitor_out) = fun vin ->
(* start of auto generation *)

(* generated by ocamltarzan with: camlp4o -o /tmp/yyy.ml -I pa/ pa_type_conv.cmo pa_map.cmo  pr_o.cmo /tmp/xxx.ml  *)

let rec map_tok v = 
  (* old: Parse_info.map_info v *)
  let k x =
    match x with
    { Parse_info.token = v_pinfo;
      transfo = v_transfo;
    } ->
    let v_pinfo =
      (* todo? map_pinfo v_pinfo *)
    v_pinfo
    in
    (* not recurse in transfo ? *)
    { Parse_info.token = v_pinfo;   (* generete a fresh field *)
      transfo = v_transfo;
    }
  in
  vin.kinfo (k, all_functions) v

and map_wrap:'a. ('a -> 'a) -> 'a wrap -> 'a wrap = fun _of_a (v1, v2) ->
  let v1 = _of_a v1 and v2 = map_tok v2 in (v1, v2)

and map_bracket:'a. ('a -> 'a) -> 'a bracket -> 'a bracket = 
  fun of_a (v1, v2, v3) ->
  let v1 = map_tok v1 and v2 = of_a v2 and v3 = map_tok v3 in (v1, v2, v3)
  
and map_name v = map_wrap map_of_string v
and map_ident x = map_name x
  
and map_qualified_name v = map_of_string v
  
and map_resolved_name =
  function
  | Local -> Local
  | Param -> Param
  | Global v1 -> let v1 = map_qualified_name v1 in Global ((v1))
  | NotResolved -> NotResolved
  
and map_special =
  function
  | Null -> Null
  | Undefined -> Undefined
  | This -> This
  | Super -> Super
  | Exports -> Exports
  | Module -> Module
  | Define -> Define
  | Arguments -> Arguments
  | New -> New
  | NewTarget -> NewTarget
  | Eval -> Eval
  | Require -> Require
  | Seq -> Seq
  | Void -> Void
  | Typeof -> Typeof
  | Instanceof -> Instanceof
  | In -> In
  | Delete -> Delete
  | Spread -> Spread
  | Yield -> Yield
  | YieldStar -> YieldStar
  | Await -> Await
  | Encaps v1 -> let v1 = map_of_bool v1 in Encaps ((v1))
  | UseStrict -> UseStrict
  | ArithOp v -> let v = map_of_arith_op v in ArithOp v
  | IncrDecr v -> let v = map_of_inc_dec v in IncrDecr ((v))

and map_of_inc_dec x = x
and map_of_arith_op x = x
  
and map_label v = map_wrap map_of_string v
  
and map_filename v = map_wrap map_of_string v
  
and map_property_name =
  function
  | PN v1 -> let v1 = map_name v1 in PN ((v1))
  | PN_Computed v1 -> let v1 = map_expr v1 in PN_Computed ((v1))


and map_xml {
            xml_tag = v_xml_tag;
            xml_attrs = v_xml_attrs;
            xml_body = v_xml_body
          } =
  let v_xml_body = map_of_list map_xml_body v_xml_body in
  let v_xml_attrs =
    map_of_list
      (fun (v1, v2) ->
         let v1 = map_ident v1 and v2 = map_xml_attr v2 in (v1, v2))
      v_xml_attrs in
  let v_xml_tag = map_ident v_xml_tag in 
  { xml_tag = v_xml_tag; xml_attrs = v_xml_attrs; xml_body = v_xml_body }

and map_xml_attr v = map_expr v
and map_xml_body =
  function
  | XmlText v1 -> let v1 = map_wrap map_of_string v1 in XmlText ((v1))
  | XmlExpr v1 -> let v1 = map_expr v1 in XmlExpr ((v1))
  | XmlXml v1 -> let v1 = map_xml v1 in XmlXml ((v1))

and map_expr =
  function
  | Xml v1 -> let v1 = map_xml v1 in Xml v1
  | Bool v1 -> let v1 = map_wrap map_of_bool v1 in Bool ((v1))
  | Num v1 -> let v1 = map_wrap map_of_string v1 in Num ((v1))
  | String v1 -> let v1 = map_wrap map_of_string v1 in String ((v1))
  | Regexp v1 -> let v1 = map_wrap map_of_string v1 in Regexp ((v1))
  | Id ((v1, v2)) ->
      let v1 = map_name v1
      and v2 = map_of_ref map_resolved_name v2
      in Id ((v1, v2))
  | IdSpecial v1 -> let v1 = map_wrap map_special v1 in IdSpecial ((v1))
  | Nop -> Nop
  | Assign ((v1, v2, v3)) ->
      let v1 = map_expr v1 and v2 = map_tok v2 and v3 = map_expr v3 in
      Assign ((v1, v2, v3))
  | Obj v1 -> let v1 = map_obj_ v1 in Obj ((v1))
  | Ellipsis v1 -> let v1 = map_tok v1 in Ellipsis ((v1))
  | DeepEllipsis v1 -> let v1 = map_bracket map_expr v1 in DeepEllipsis ((v1))
  | Class (v1, v2) -> 
    let v1 = map_class_ v1 in
    let v2 = map_option map_name v2 in
    Class ((v1, v2))
  | ObjAccess ((v1, t, v2)) ->
      let v1 = map_expr v1
      and v2 = map_property_name v2
      and t = map_tok t 
      in ObjAccess ((v1, t, v2))
  | Arr v1 -> let v1 = map_bracket (map_of_list map_expr) v1 in Arr ((v1))
  | ArrAccess ((v1, v2)) ->
      let v1 = map_expr v1 and v2 = map_expr v2 in ArrAccess ((v1, v2))
  | Fun ((v1, v2)) ->
      let v1 = map_fun_ v1
      and v2 = map_of_option map_name v2
      in Fun ((v1, v2))
  | Apply ((v1, v2)) ->
      let v1 = map_expr v1
      and v2 = map_of_list map_expr v2
      in Apply ((v1, v2))
  | Conditional ((v1, v2, v3)) ->
      let v1 = map_expr v1
      and v2 = map_expr v2
      and v3 = map_expr v3
      in Conditional ((v1, v2, v3))
and map_stmt =
  function
  | VarDecl v1 -> let v1 = map_var v1 in VarDecl ((v1))
  | Block v1 -> let v1 = map_of_list map_stmt v1 in Block ((v1))
  | ExprStmt v1 -> let v1 = map_expr v1 in ExprStmt ((v1))
  | If ((t, v1, v2, v3)) ->
      let t = map_tok t in
      let v1 = map_expr v1
      and v2 = map_stmt v2
      and v3 = map_stmt v3
      in If ((t, v1, v2, v3))
  | Do ((t, v1, v2)) ->
      let t = map_tok t in
      let v1 = map_stmt v1 and v2 = map_expr v2 in Do ((t, v1, v2))
  | While ((t, v1, v2)) ->
      let t = map_tok t in
      let v1 = map_expr v1 and v2 = map_stmt v2 in While ((t, v1, v2))
  | For ((t, v1, v2)) ->
      let t = map_tok t in
      let v1 = map_for_header v1 and v2 = map_stmt v2 in For ((t, v1, v2))
  | Switch ((v0, v1, v2)) ->
      let v0 = map_tok v0 in
      let v1 = map_expr v1
      and v2 = map_of_list map_case v2
      in Switch ((v0, v1, v2))
  | Continue (t, v1) -> 
      let t = map_tok t in
      let v1 = map_of_option map_label v1 in Continue ((t, v1))
  | Break (t, v1) -> 
      let t = map_tok t in
      let v1 = map_of_option map_label v1 in Break ((t, v1))
  | Return (t, v1) -> 
      let t = map_tok t in
      let v1 = map_expr v1 in Return ((t, v1))
  | Label ((v1, v2)) ->
      let v1 = map_label v1 and v2 = map_stmt v2 in Label ((v1, v2))
  | Throw (t, v1) -> 
      let t = map_tok t in
      let v1 = map_expr v1 in Throw ((t, v1))
  | Try ((t, v1, v2, v3)) ->
      let t = map_tok t in
      let v1 = map_stmt v1
      and v2 =
        map_of_option
          (fun (t, v1, v2) ->
            let t = map_tok t in
             let v1 = map_name v1 and v2 = map_stmt v2 in (t, v1, v2))
          v2
      and v3 = map_of_option map_tok_and_stmt v3
      in Try ((t, v1, v2, v3))

and map_tok_and_stmt (t, v) = 
  let t = map_tok t in
  let v = map_stmt v in
  (t, v)

and map_for_header =
  function
  | ForClassic ((v1, v2, v3)) ->
      let v1 = OCaml.map_of_either (map_of_list map_var) map_expr v1
      and v2 = map_expr v2
      and v3 = map_expr v3
      in ForClassic ((v1, v2, v3))
  | ForIn ((v1, t, v2)) ->
      let t = map_tok t in
      let v1 = OCaml.map_of_either map_var map_expr v1
      and v2 = map_expr v2
      in ForIn ((v1, t, v2))
and map_case =
  function
  | Case ((t, v1, v2)) ->
      let t = map_tok t in
      let v1 = map_expr v1 and v2 = map_stmt v2 in Case ((t, v1, v2))
  | Default (t, v1) -> 
      let t = map_tok t in
      let v1 = map_stmt v1 in Default ((t, v1))
and
  map_var {
            v_name = v_v_name;
            v_kind = v_v_kind;
            v_init = v_v_init;
            v_resolved = v_v_resolved
          } =
  let v_v_resolved = map_of_ref map_resolved_name v_v_resolved in
  let v_v_init = map_expr v_v_init in
  let v_v_kind = map_wrap map_var_kind v_v_kind in
  let v_v_name = map_name v_v_name in 
    { v_name = v_v_name; v_kind = v_v_kind; v_init = v_v_init;
      v_resolved = v_v_resolved }

and map_var_kind = function | Var -> Var | Let -> Let | Const -> Const
and
  map_fun_ { f_props = v_f_props; f_params = v_f_params; f_body = v_f_body }
           =
  let v_f_body = map_stmt v_f_body in
  let v_f_params = map_of_list map_parameter_binding v_f_params in
  let v_f_props = map_of_list (map_wrap map_fun_prop) v_f_props in 
  { f_props = v_f_props; f_params = v_f_params; f_body = v_f_body }

and map_parameter_binding =
  function
  | ParamClassic v1 -> let v1 = map_parameter v1 in ParamClassic v1
  | ParamEllipsis v1 -> let v1 = map_tok v1 in ParamEllipsis v1

and
  map_parameter {
                  p_name = v_p_name;
                  p_default = v_p_default;
                  p_dots = v_p_dots
                } =
  let v_p_dots = map_of_option map_tok v_p_dots in
  let v_p_default = map_of_option map_expr v_p_default in
  let v_p_name = map_name v_p_name in 
  { p_name = v_p_name; p_default = v_p_default; p_dots = v_p_dots }
and map_fun_prop =
  function
  | Get -> Get
  | Set -> Set
  | Generator -> Generator
  | Async -> Async
and map_obj_ v = map_bracket (map_of_list map_property) v
and map_class_ { c_extends = v_c_extends; c_body = v_c_body } =
  let v_c_body = map_bracket (map_of_list map_property) v_c_body in
  let v_c_extends = map_of_option map_expr v_c_extends in 
  { c_extends = v_c_extends; c_body = v_c_body }
and map_property =
  function
  | Field ((v1, v2, v3)) ->
      let v1 = map_property_name v1
      and v2 = map_of_list (map_wrap map_property_prop) v2
      and v3 = map_expr v3
      in Field ((v1, v2, v3))
  | FieldSpread (t, v1) -> 
      let t = map_tok t in let v1 = map_expr v1 in FieldSpread ((t, v1))
  | FieldEllipsis v1 ->
      let v1 = map_tok v1 in FieldEllipsis v1
      
and map_property_prop =
  function
  | Static -> Static
  | Public -> Public
  | Private -> Private
  | Protected -> Protected
  
and map_toplevel =
  function
  | V v1 -> let v1 = map_var v1 in V ((v1))
  | S ((v1, v2)) -> let v1 = map_tok v1 and v2 = map_stmt v2 in S ((v1, v2))
  | M v1 -> let v1 = map_module_directive v1 in M ((v1))

and map_module_directive =
  function 
  | Import ((t, v1, v2, v3)) ->
      let t = map_tok t in
      let v1 = map_name v1
      and v2 = map_of_option map_name v2
      and v3 = map_filename v3
      in Import ((t, v1, v2, v3))
  | ImportCss ((v1)) ->
      let v1 = map_name v1
      in ImportCss ((v1))
  | ImportEffect ((v0, v1)) ->
      let v0 = map_tok v0 in
      let v1 = map_name v1
      in ImportEffect ((v0, v1))
  | ModuleAlias ((t, v1, v2)) ->
      let t = map_tok t in
      let v1 = map_name v1
      and v2 = map_filename v2
      in ModuleAlias ((t, v1, v2))
  | Export v1 -> let v1 = map_name v1 in Export ((v1))
  
and map_program v = map_of_list map_toplevel v
  
and map_any =
  function
  | Expr v1 -> let v1 = map_expr v1 in Expr ((v1))
  | Stmt v1 -> let v1 = map_stmt v1 in Stmt ((v1))
  | Items v1 -> let v1 = map_of_list map_toplevel v1 in Items ((v1))
  | Item v1 -> let v1 = map_toplevel v1 in Item ((v1))
  | Program v1 -> let v1 = map_program v1 in Program ((v1))
  

 and all_functions =
    {
      vtop = map_toplevel;
      vprogram = map_program;
      vexpr = map_expr;
      vany = map_any;
    }
  in
  all_functions
