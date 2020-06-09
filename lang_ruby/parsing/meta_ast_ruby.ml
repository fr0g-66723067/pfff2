(* generated by ocamltarzan with: camlp4o -o /tmp/yyy.ml -I pa/ pa_type_conv.cmo pa_vof.cmo  pr_o.cmo /tmp/xxx.ml  *)

open Ast_ruby

let vof_tok v = Meta_parse_info.vof_info_adjustable_precision v

let vof_wrap _of_a (v1, v2) =
  let v1 = _of_a v1 and v2 = vof_tok v2 in OCaml.VTuple [ v1; v2 ]

let vof_ident x = vof_wrap OCaml.vof_string x

let vof_bracket of_a (_t1, x, _t2) =
  of_a x

let rec vof_expr =
  function
  | Literal ((v1, v2)) ->
      let v1 = vof_lit_kind v1
      and v2 = vof_tok v2
      in OCaml.VSum (("Literal", [ v1; v2 ]))
  | Id (v1, v2) ->
      let v1 = vof_ident v1
      and v2 = vof_id_kind v2
      in OCaml.VSum (("Id", [ v1; v2]))
  | Operator ((v1, v2)) ->
      let v1 = vof_binary_op v1
      and v2 = vof_tok v2
      in OCaml.VSum (("Operator", [ v1; v2 ]))
  | UOperator ((v1, v2)) ->
      let v1 = vof_unary_op v1
      and v2 = vof_tok v2
      in OCaml.VSum (("UOperator", [ v1; v2 ]))
  | Hash ((v1, v2)) ->
      let v1 = OCaml.vof_bool v1
      and v2 = vof_bracket (OCaml.vof_list vof_expr) v2
      in OCaml.VSum (("Hash", [ v1; v2 ]))
  | Array ((v1)) ->
      let v1 = vof_bracket (OCaml.vof_list vof_expr) v1
      in OCaml.VSum (("Array", [ v1 ]))
  | Tuple ((v1, v2)) ->
      let v1 = OCaml.vof_list vof_expr v1
      and v2 = vof_tok v2
      in OCaml.VSum (("Tuple", [ v1; v2 ]))
  | Unary ((v1, v2)) ->
      let v1 = vof_wrap vof_unary_op v1
      and v2 = vof_expr v2
      in OCaml.VSum (("Unary", [ v1; v2 ]))
  | Binop ((v1, v2, v3)) ->
      let v1 = vof_expr v1
      and v2 = vof_wrap vof_binary_op v2
      and v3 = vof_expr v3
      in OCaml.VSum (("Binop", [ v1; v2; v3 ]))
  | Ternary ((v1, v2, v3, v4, v5)) ->
      let v1 = vof_expr v1
      and v2 = vof_tok v2
      and v3 = vof_expr v3
      and v4 = vof_tok v4
      and v5 = vof_expr v5
      in OCaml.VSum (("Ternary", [ v1; v2; v3; v4; v5 ]))
  | Call ((v1, v2, v3, v4)) ->
      let v1 = vof_expr v1
      and v2 = OCaml.vof_list vof_expr v2
      and v3 = OCaml.vof_option vof_expr v3
      and v4 = vof_tok v4
      in OCaml.VSum (("Call", [ v1; v2; v3; v4 ]))
  | CodeBlock ((v1, v2, v3, v4)) ->
      let v1 = vof_bracket OCaml.vof_bool v1
      and v2 = OCaml.vof_option (OCaml.vof_list vof_formal_param) v2
      and v3 = OCaml.vof_list vof_expr v3
      and v4 = vof_tok v4
      in OCaml.VSum (("CodeBlock", [ v1; v2; v3; v4 ]))
  | S Empty -> OCaml.VSum (("Empty", []))
  | S Block ((v1, v2)) ->
      let v1 = OCaml.vof_list vof_expr v1
      and v2 = vof_tok v2
      in OCaml.VSum (("Block", [ v1; v2 ]))
  | S If ((v0, v1, v2, v3)) ->
      let v1 = vof_expr v1
      and v2 = OCaml.vof_list vof_expr v2
      and v3 = OCaml.vof_list vof_expr v3
      and v0 = vof_tok v0
      in OCaml.VSum (("If", [ v0; v1; v2; v3 ]))
  | S While ((v0, v1, v2, v3)) ->
      let v1 = OCaml.vof_bool v1
      and v2 = vof_expr v2
      and v3 = OCaml.vof_list vof_expr v3
      and v0 = vof_tok v0
      in OCaml.VSum (("While", [ v0; v1; v2; v3 ]))
  | S Until ((v0, v1, v2, v3)) ->
      let v1 = OCaml.vof_bool v1
      and v2 = vof_expr v2
      and v3 = OCaml.vof_list vof_expr v3
      and v0 = vof_tok v0
      in OCaml.VSum (("Until", [ v0; v1; v2; v3 ]))
  | S Unless ((v0, v1, v2, v3)) ->
      let v1 = vof_expr v1
      and v2 = OCaml.vof_list vof_expr v2
      and v3 = OCaml.vof_list vof_expr v3
      and v0 = vof_tok v0
      in OCaml.VSum (("Unless", [ v0; v1; v2; v3 ]))
  | S For ((v0, v1, v2, v3)) ->
      let v1 = OCaml.vof_list vof_formal_param v1
      and v2 = vof_expr v2
      and v3 = OCaml.vof_list vof_expr v3
      and v0 = vof_tok v0
      in OCaml.VSum (("For", [ v0; v1; v2; v3 ]))
  | S Return ((v2, v1)) ->
      let v1 = OCaml.vof_list vof_expr v1
      and v2 = vof_tok v2
      in OCaml.VSum (("Return", [ v2; v1 ]))
  | S Yield ((v2, v1)) ->
      let v1 = OCaml.vof_list vof_expr v1
      and v2 = vof_tok v2
      in OCaml.VSum (("Yield", [ v2; v1 ]))
  | S Case ((v2, v1)) ->
      let v1 = vof_case_block v1
      and v2 = vof_tok v2
      in OCaml.VSum (("Case", [ v2; v1 ]))
  | S ExnBlock ((v1, v2)) ->
      let v1 = vof_body_exn v1
      and v2 = vof_tok v2
      in OCaml.VSum (("ExnBlock", [ v1; v2 ]))
  | D ClassDef ((v0, v1, v2, v3)) ->
      let v1 = vof_expr v1
      and v2 = OCaml.vof_option vof_inheritance_kind v2
      and v3 = vof_body_exn v3
      and v0 = vof_tok v0
      in OCaml.VSum (("ClassDef", [ v0; v1; v2; v3 ]))
  | D MethodDef ((v0, v1, v2, v3)) ->
      let v1 = vof_expr v1
      and v2 = OCaml.vof_list vof_formal_param v2
      and v3 = vof_body_exn v3
      and v0 = vof_tok v0
      in OCaml.VSum (("MethodDef", [ v0; v1; v2; v3 ]))
  | D ModuleDef ((v0, v1, v2)) ->
      let v1 = vof_expr v1
      and v2 = vof_body_exn v2
      and v0 = vof_tok v0
      in OCaml.VSum (("ModuleDef", [ v0; v1; v2 ]))
  | D BeginBlock ((v2, v1)) ->
      let v1 = vof_bracket (OCaml.vof_list vof_expr) v1
      and v2 = vof_tok v2
      in OCaml.VSum (("BeginBlock", [ v2; v1 ]))
  | D EndBlock ((v2, v1)) ->
      let v1 = vof_bracket (OCaml.vof_list vof_expr) v1
      and v2 = vof_tok v2
      in OCaml.VSum (("EndBlock", [ v2; v1 ]))
  | D Alias ((v0, v1, v2)) ->
      let v1 = vof_expr v1
      and v2 = vof_expr v2
      and v0 = vof_tok v0
      in OCaml.VSum (("Alias", [ v0; v1; v2 ]))
  | D Undef ((v2, v1)) ->
      let v1 = OCaml.vof_list vof_expr v1
      and v2 = vof_tok v2
      in OCaml.VSum (("Undef", [ v2; v1 ]))

and vof_lit_kind =
  function
  | Num v1 ->
      let v1 = OCaml.vof_string v1 in OCaml.VSum (("Num", [ v1 ]))
  | Float ((v1)) ->
      let v1 = OCaml.vof_string v1
      in OCaml.VSum (("Float", [ v1 ]))
  | String v1 ->
      let v1 = vof_string_kind v1 in OCaml.VSum (("String", [ v1 ]))
  | Atom v1 ->
      let v1 = vof_interp_string v1 in OCaml.VSum (("Atom", [ v1 ]))
  | Regexp ((v1, v2)) ->
      let v1 = vof_interp_string v1
      and v2 = OCaml.vof_string v2
      in OCaml.VSum (("Regexp", [ v1; v2 ]))
  | Nil -> OCaml.VSum (("Nil", []))
  | Self -> OCaml.VSum (("Self", []))
  | True -> OCaml.VSum (("True", []))
  | False -> OCaml.VSum (("False", []))
and vof_string_kind =
  function
  | Single v1 ->
      let v1 = OCaml.vof_string v1 in OCaml.VSum (("Single", [ v1 ]))
  | Double v1 ->
      let v1 = vof_interp_string v1 in OCaml.VSum (("Double", [ v1 ]))
  | Tick v1 ->
      let v1 = vof_interp_string v1 in OCaml.VSum (("Tick", [ v1 ]))
and vof_interp_string v = OCaml.vof_list vof_string_contents v
and vof_string_contents =
  function
  | StrChars v1 ->
      let v1 = OCaml.vof_string v1 in OCaml.VSum (("StrChars", [ v1 ]))
  | StrExpr v1 -> let v1 = vof_expr v1 in OCaml.VSum (("StrExpr", [ v1 ]))
and vof_id_kind =
  function
  | ID_Lowercase -> OCaml.VSum (("ID_Lowercase", []))
  | ID_Instance -> OCaml.VSum (("ID_Instance", []))
  | ID_Class -> OCaml.VSum (("ID_Class", []))
  | ID_Global -> OCaml.VSum (("ID_Global", []))
  | ID_Uppercase -> OCaml.VSum (("ID_Uppercase", []))
  | ID_Builtin -> OCaml.VSum (("ID_Builtin", []))
  | ID_Assign v1 ->
      let v1 = vof_id_kind v1 in OCaml.VSum (("ID_Assign", [ v1 ]))
and vof_unary_op =
  function
  | Op_UMinus -> OCaml.VSum (("Op_UMinus", []))
  | Op_UPlus -> OCaml.VSum (("Op_UPlus", []))
  | Op_UBang -> OCaml.VSum (("Op_UBang", []))
  | Op_UTilde -> OCaml.VSum (("Op_UTilde", []))
  | Op_UNot -> OCaml.VSum (("Op_UNot", []))
  | Op_UAmper -> OCaml.VSum (("Op_UAmper", []))
  | Op_UStar -> OCaml.VSum (("Op_UStar", []))
  | Op_UScope -> OCaml.VSum (("Op_UScope", []))
and vof_binary_op =
  function
  | Op_ASSIGN -> OCaml.VSum (("Op_ASSIGN", []))
  | Op_PLUS -> OCaml.VSum (("Op_PLUS", []))
  | Op_MINUS -> OCaml.VSum (("Op_MINUS", []))
  | Op_TIMES -> OCaml.VSum (("Op_TIMES", []))
  | Op_REM -> OCaml.VSum (("Op_REM", []))
  | Op_DIV -> OCaml.VSum (("Op_DIV", []))
  | Op_CMP -> OCaml.VSum (("Op_CMP", []))
  | Op_EQ -> OCaml.VSum (("Op_EQ", []))
  | Op_EQQ -> OCaml.VSum (("Op_EQQ", []))
  | Op_NEQ -> OCaml.VSum (("Op_NEQ", []))
  | Op_GEQ -> OCaml.VSum (("Op_GEQ", []))
  | Op_LEQ -> OCaml.VSum (("Op_LEQ", []))
  | Op_LT -> OCaml.VSum (("Op_LT", []))
  | Op_GT -> OCaml.VSum (("Op_GT", []))
  | Op_AND -> OCaml.VSum (("Op_AND", []))
  | Op_OR -> OCaml.VSum (("Op_OR", []))
  | Op_BAND -> OCaml.VSum (("Op_BAND", []))
  | Op_BOR -> OCaml.VSum (("Op_BOR", []))
  | Op_MATCH -> OCaml.VSum (("Op_MATCH", []))
  | Op_NMATCH -> OCaml.VSum (("Op_NMATCH", []))
  | Op_XOR -> OCaml.VSum (("Op_XOR", []))
  | Op_POW -> OCaml.VSum (("Op_POW", []))
  | Op_kAND -> OCaml.VSum (("Op_kAND", []))
  | Op_kOR -> OCaml.VSum (("Op_kOR", []))
  | Op_ASSOC -> OCaml.VSum (("Op_ASSOC", []))
  | Op_DOT -> OCaml.VSum (("Op_DOT", []))
  | Op_SCOPE -> OCaml.VSum (("Op_SCOPE", []))
  | Op_AREF -> OCaml.VSum (("Op_AREF", []))
  | Op_ASET -> OCaml.VSum (("Op_ASET", []))
  | Op_LSHIFT -> OCaml.VSum (("Op_LSHIFT", []))
  | Op_RSHIFT -> OCaml.VSum (("Op_RSHIFT", []))
  | Op_OP_ASGN v1 ->
      let v1 = vof_binary_op v1 in OCaml.VSum (("Op_OP_ASGN", [ v1 ]))
  | Op_DOT2 -> OCaml.VSum (("Op_DOT2", []))
  | Op_DOT3 -> OCaml.VSum (("Op_DOT3", []))
and vof_formal_param =
  function
  | Formal_id v1 ->
      let v1 = vof_expr v1 in OCaml.VSum (("Formal_id", [ v1 ]))
  | Formal_amp (v1, v2) ->
      let v1 = vof_tok v1 in
      let v2 = vof_ident v2 in 
      OCaml.VSum (("Formal_amp", [ v1; v2 ]))
  | Formal_star (v1, v2) ->
      let v1 = vof_tok v1 in
      let v2 = vof_ident v2 in 
      OCaml.VSum (("Formal_star", [ v1; v2 ]))
  | Formal_rest v1 -> let v1 = vof_tok v1 in OCaml.VSum (("Formal_rest", [v1]))
  | Formal_tuple v1 ->
      let v1 = vof_bracket (OCaml.vof_list vof_formal_param) v1
      in OCaml.VSum (("Formal_tuple", [ v1 ]))
  | Formal_default ((v1, v2, v3)) ->
      let v1 = vof_ident v1
      and v2 = vof_tok v2
      and v3 = vof_expr v3
      in OCaml.VSum (("Formal_default", [ v1; v2; v3 ]))
and vof_inheritance_kind =
  function
  | Class_Inherit v1 ->
      let v1 = vof_expr v1 in OCaml.VSum (("Class_Inherit", [ v1 ]))
  | Inst_Inherit v1 ->
      let v1 = vof_expr v1 in OCaml.VSum (("Inst_Inherit", [ v1 ]))
and
  vof_body_exn {
                 body_exprs = v_body_exprs;
                 rescue_exprs = v_rescue_exprs;
                 ensure_expr = v_ensure_expr;
                 else_expr = v_else_expr
               } =
  let bnds = [] in
  let arg = OCaml.vof_list vof_expr v_else_expr in
  let bnd = ("else_expr", arg) in
  let bnds = bnd :: bnds in
  let arg = OCaml.vof_list vof_expr v_ensure_expr in
  let bnd = ("ensure_expr", arg) in
  let bnds = bnd :: bnds in
  let arg =
    OCaml.vof_list
      (fun (v1, v2) ->
         let v1 = vof_expr v1 and v2 = vof_expr v2 in OCaml.VTuple [ v1; v2 ])
      v_rescue_exprs in
  let bnd = ("rescue_exprs", arg) in
  let bnds = bnd :: bnds in
  let arg = OCaml.vof_list vof_expr v_body_exprs in
  let bnd = ("body_exprs", arg) in let bnds = bnd :: bnds in OCaml.VDict bnds
and
  vof_case_block {
                   case_guard = v_case_guard;
                   case_whens = v_case_whens;
                   case_else = v_case_else
                 } =
  let bnds = [] in
  let arg = OCaml.vof_list vof_expr v_case_else in
  let bnd = ("case_else", arg) in
  let bnds = bnd :: bnds in
  let arg =
    OCaml.vof_list
      (fun (v1, v2) ->
         let v1 = OCaml.vof_list vof_expr v1
         and v2 = OCaml.vof_list vof_expr v2
         in OCaml.VTuple [ v1; v2 ])
      v_case_whens in
  let bnd = ("case_whens", arg) in
  let bnds = bnd :: bnds in
  let arg = vof_expr v_case_guard in
  let bnd = ("case_guard", arg) in let bnds = bnd :: bnds in OCaml.VDict bnds
  
let vof_program v = OCaml.vof_list vof_expr v
  
let _vof_pos v = vof_tok v
  

let string_of_expr e = 
  let v = vof_expr e in
  OCaml.string_of_v v

let string_of_program x =
  let v = vof_program x in
  OCaml.string_of_v v
