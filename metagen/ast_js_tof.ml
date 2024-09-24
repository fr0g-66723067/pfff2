(* generated by ocamltarzan with: camlp4o -o /tmp/yyy.ml -I pa/ pa_type_conv.cmo pa_tof.cmo  pr_o.cmo /tmp/xxx.ml  *)

let tof_wrap =
  OCaml.add_new_type "wrap" (OCaml.Tuple [ OCaml.Poly "a"; OCaml.Var "tok" ])
and tof_tok = OCaml.add_new_type "tok" (OCaml.TTODO "")

let tof_name =
  OCaml.add_new_type "name" (OCaml.Apply ("wrap", OCaml.String))

let tof_qualified_name = OCaml.add_new_type "qualified_name" OCaml.String

let tof_resolved_name =
  OCaml.add_new_type "resolved_name"
    (OCaml.Sum
       [ ("Local", []); ("Param", []);
         ("Global", [ OCaml.Var "qualified_name" ]); ("NotResolved", []) ])

let tof_special =
  OCaml.add_new_type "special"
    (OCaml.Sum
       [ ("Null", []); ("Undefined", []); ("This", []); ("Super", []);
         ("Exports", []); ("Module", []); ("New", []); ("NewTarget", []);
         ("Eval", []); ("Require", []); ("Seq", []); ("Void", []);
         ("Typeof", []); ("Instanceof", []); ("In", []); ("Delete", []);
         ("Spread", []); ("Yield", []); ("YieldStar", []); ("Await", []);
         ("Encaps", [ OCaml.Option (OCaml.Var "name") ]); ("UseStrict", []);
         ("And", []); ("Or", []); ("Not", []); ("Xor", []); ("BitNot", []);
         ("BitAnd", []); ("BitOr", []); ("BitXor", []); ("Lsr", []);
         ("Asr", []); ("Lsl", []); ("Equal", []); ("PhysEqual", []);
         ("Lower", []); ("Greater", []); ("Plus", []); ("Minus", []);
         ("Mul", []); ("Div", []); ("Mod", []); ("Expo", []);
         ("Incr", [ OCaml.Bool ]); ("Decr", [ OCaml.Bool ]) ])

let tof_label =
  OCaml.add_new_type "label" (OCaml.Apply ("wrap", OCaml.String))

let tof_filename =
  OCaml.add_new_type "filename" (OCaml.Apply ("wrap", OCaml.String))

let tof_property_prop =
  OCaml.add_new_type "property_prop"
    (OCaml.Sum
       [ ("Static", []); ("Public", []); ("Private", []); ("Protected", []) ])
and tof_property =
  OCaml.add_new_type "property"
    (OCaml.Sum
       [ ("Field",
          [ OCaml.Var "property_name";
            OCaml.List (OCaml.Var "property_prop"); OCaml.Var "expr" ]);
         ("FieldSpread", [ OCaml.Var "expr" ]) ])
and tof_class_ =
  OCaml.add_new_type "class_"
    (OCaml.Dict
       [ ("c_extends", `RO, (OCaml.Option (OCaml.Var "expr")));
         ("c_body", `RO, (OCaml.List (OCaml.Var "property"))) ])
and tof_obj_ = OCaml.add_new_type "obj_" (OCaml.List (OCaml.Var "property"))
and tof_fun_prop =
  OCaml.add_new_type "fun_prop"
    (OCaml.Sum [ ("Get", []); ("Set", []); ("Generator", []); ("Async", []) ])
and tof_parameter =
  OCaml.add_new_type "parameter"
    (OCaml.Dict
       [ ("p_name", `RO, (OCaml.Var "name"));
         ("p_default", `RO, (OCaml.Option (OCaml.Var "expr")));
         ("p_dots", `RO, OCaml.Bool) ])
and tof_fun_ =
  OCaml.add_new_type "fun_"
    (OCaml.Dict
       [ ("f_props", `RO, (OCaml.List (OCaml.Var "fun_prop")));
         ("f_params", `RO, (OCaml.List (OCaml.Var "parameter")));
         ("f_body", `RO, (OCaml.Var "stmt")) ])
and tof_var_kind =
  OCaml.add_new_type "var_kind"
    (OCaml.Sum [ ("Var", []); ("Let", []); ("Const", []) ])
and tof_var =
  OCaml.add_new_type "var"
    (OCaml.Dict
       [ ("v_name", `RO, (OCaml.Var "name"));
         ("v_kind", `RO, (OCaml.Var "var_kind"));
         ("v_init", `RO, (OCaml.Var "expr"));
         ("v_resolved", `RO,
          (OCaml.Apply (("ref", (OCaml.Var "resolved_name"))))) ])
and tof_var_or_expr = OCaml.add_new_type "var_or_expr" (OCaml.TTODO "")
and tof_vars_or_expr = OCaml.add_new_type "vars_or_expr" (OCaml.TTODO "")
and tof_case =
  OCaml.add_new_type "case"
    (OCaml.Sum
       [ ("Case", [ OCaml.Var "expr"; OCaml.Var "stmt" ]);
         ("Default", [ OCaml.Var "stmt" ]) ])
and tof_for_header =
  OCaml.add_new_type "for_header"
    (OCaml.Sum
       [ ("ForClassic",
          [ OCaml.Var "vars_or_expr"; OCaml.Var "expr"; OCaml.Var "expr" ]);
         ("ForIn", [ OCaml.Var "var_or_expr"; OCaml.Var "expr" ]);
         ("ForOf", [ OCaml.Var "var_or_expr"; OCaml.Var "expr" ]) ])
and tof_catch =
  OCaml.add_new_type "catch"
    (OCaml.Tuple [ OCaml.Var "name"; OCaml.Var "stmt" ])
and tof_stmt =
  OCaml.add_new_type "stmt"
    (OCaml.Sum
       [ ("VarDecl", [ OCaml.Var "var" ]);
         ("Block", [ OCaml.List (OCaml.Var "stmt") ]);
         ("ExprStmt", [ OCaml.Var "expr" ]);
         ("If", [ OCaml.Var "expr"; OCaml.Var "stmt"; OCaml.Var "stmt" ]);
         ("Do", [ OCaml.Var "stmt"; OCaml.Var "expr" ]);
         ("While", [ OCaml.Var "expr"; OCaml.Var "stmt" ]);
         ("For", [ OCaml.Var "for_header"; OCaml.Var "stmt" ]);
         ("Switch", [ OCaml.Var "expr"; OCaml.List (OCaml.Var "case") ]);
         ("Continue", [ OCaml.Option (OCaml.Var "label") ]);
         ("Break", [ OCaml.Option (OCaml.Var "label") ]);
         ("Return", [ OCaml.Var "expr" ]);
         ("Label", [ OCaml.Var "label"; OCaml.Var "stmt" ]);
         ("Throw", [ OCaml.Var "expr" ]);
         ("Try",
          [ OCaml.Var "stmt"; OCaml.Option (OCaml.Var "catch");
            OCaml.Option (OCaml.Var "stmt") ]) ])
and tof_expr =
  OCaml.add_new_type "expr"
    (OCaml.Sum
       [ ("Bool", [ OCaml.Apply ("wrap", OCaml.Bool) ]);
         ("Num", [ OCaml.Apply ("wrap", OCaml.String) ]);
         ("String", [ OCaml.Apply ("wrap", OCaml.String) ]);
         ("Regexp", [ OCaml.Apply ("wrap", OCaml.String) ]);
         ("Id",
          [ OCaml.Var "name";
            OCaml.Apply (("ref", (OCaml.Var "resolved_name"))) ]);
         ("IdSpecial", [ OCaml.Apply (("wrap", (OCaml.Var "special"))) ]);
         ("Nop", []); ("Assign", [ OCaml.Var "expr"; OCaml.Var "expr" ]);
         ("Obj", [ OCaml.Var "obj_" ]); ("Class", [ OCaml.Var "class_" ]);
         ("ObjAccess", [ OCaml.Var "expr"; OCaml.Var "property_name" ]);
         ("Arr", [ OCaml.List (OCaml.Var "expr") ]);
         ("ArrAccess", [ OCaml.Var "expr"; OCaml.Var "expr" ]);
         ("Fun", [ OCaml.Var "fun_"; OCaml.Option (OCaml.Var "name") ]);
         ("Apply", [ OCaml.Var "expr"; OCaml.List (OCaml.Var "expr") ]);
         ("Conditional",
          [ OCaml.Var "expr"; OCaml.Var "expr"; OCaml.Var "expr" ]) ])
and tof_property_name =
  OCaml.add_new_type "property_name"
    (OCaml.Sum
       [ ("PN", [ OCaml.Var "name" ]); ("PN_Computed", [ OCaml.Var "expr" ]) ])

let tof_toplevel =
  OCaml.add_new_type "toplevel"
    (OCaml.Sum
       [ ("V", [ OCaml.Var "var" ]);
         ("S", [ OCaml.Var "tok"; OCaml.Var "stmt" ]);
         ("Import",
          [ OCaml.Var "name"; OCaml.Var "name"; OCaml.Var "filename" ]);
         ("Export", [ OCaml.Var "name" ]) ])

let tof_program =
  OCaml.add_new_type "program" (OCaml.List (OCaml.Var "toplevel"))

let tof_any =
  OCaml.add_new_type "any"
    (OCaml.Sum
       [ ("Expr", [ OCaml.Var "expr" ]); ("Stmt", [ OCaml.Var "stmt" ]);
         ("Top", [ OCaml.Var "toplevel" ]);
         ("Program", [ OCaml.Var "program" ]) ])
