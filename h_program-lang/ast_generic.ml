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

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)
(* A generic AST, to be used by a generic visitor to factorize
 * similar analysis in different programming languages
 * (e.g., checked_return). 
 *
 * rational: In the end, programming languages have a lot in common.
 * Even though most interesting analysis are probably better done on a
 * per-language basis, many useful analysis are trivial and require just an
 * AST and a visitor. One could duplicate those analysis for each language
 * or design a generic AST (this file) to be generic enough to
 * factorize all those analysis (e.g., checked_return), while still remaining
 * as precise as possible (not as generic as ast_fuzzy.ml for example or a
 * very general but imprecise tree of nodes).
 * 
 * TODO:
 *  - initial goal: factorize Python, Javascript
 *  - later: add Go, Java.
 *  - later: add Ruby, Rust, Scala.
 *  - later: add C++, C.
 *  - dogfooding: add OCaml!
 *  - see ast_fuzzy.ml TODOs for ideas to use ast_generic for sgrep.
 *
 * related work:
 *  - ast_fuzzy.ml (in this directory)
 *  - github semantic
 *    https://github.com/github/semantic
 *  - Coverity common program representation?
 *  - Semmle internal common representation?
 *  - Infer SIL (for C++, Java, Objective-C)
 *  - Dawson Engler and Fraser Brown micro-checkers for multiple languages
 *  - https://tabnine.com/ which supports multiple languages
 *  - Lightweight Multi-language syntax transformation paper 
 *
 * design choices to have a generic data structure:
 *  - add some 'a, 'b, 'c around expr/stmt/...
 *  - functorize and add some type hole (type tstmt; type texpr; ...)
 *  - data-type a la carte like in github-semantic? Seems too high-level,
 *    astronaut-style architecture (too abstract, too advanced features).
 *)

(*****************************************************************************)
(* Types *)
(*****************************************************************************)

(* ------------------------------------------------------------------------- *)
(* Token/info *)
(* ------------------------------------------------------------------------- *)

(* Contains among other things the position of the token through
 * the Parse_info.token_location embedded inside it, as well as the
 * transformation field that makes possible spatch on the code.
 *)
type tok = Parse_info.info
 (* with tarzan *)

(* a shortcut to annotate some information with token/position information *)
type 'a wrap = 'a * tok
 (* with tarzan *)

(* ------------------------------------------------------------------------- *)
(* Name *)
(* ------------------------------------------------------------------------- *)

type name = string wrap
 (* with tarzan *)

type dotted_name = name list
 (* with tarzan *)

type module_name =
  | FileName of string wrap (* ex: Javascript *)
  | DottedName of dotted_name (* ex: Python *)
 (* with tarzan *)

(* todo? module_name * name? *)
type qualified_name = dotted_name
 (* with tarzan *)

(* todo: see also scope_code.ml *)
type resolved_name =
  | Local
  | Param
  | Global of qualified_name
  | NotResolved
  | OtherResolved of other_resolved_name

  and other_resolved_name = string
 (* with tarzan *)

(* ------------------------------------------------------------------------- *)
(* Expression *)
(* ------------------------------------------------------------------------- *)
(* big mutually recursive types because of the use of 'any' in OtherXxx *)

type expr = 
  (* basic values (literals) *)
  | Bool of bool wrap
  | Int of string wrap
  | Float of string wrap
  | String of string wrap
  | Regexp of string wrap
  | Null of string wrap | Undefined of string wrap

  (* composite values *)
  | Tuple (* special case of Container *)
  | Container of container_operator * expr list
  (* And type *)
  | Record of field list
  (* Or type (could be used instead of Container, Cons, Nil, etc.) *)
  | Constructor of name * expr list

  (* very special value *)
  (* less: reuse function_definition? *)
  | Lambda of parameters * stmt

  | Nop

  | Id of name * resolved_name ref
  | IdSpecial of special
  (* less: IdSpecial *)

  (* operators and function application *)
  | BinaryOp of expr * binary_operator wrap * expr
  | UnaryOp of unary_operator * expr
  | Call of expr * arguments
  (* advanced "calls" *)
  | New of name * arguments

  (* should be in statement, but many languages allow this at expr level *)
  | Assign of expr * expr
  | AssignOp of expr * binary_operator * expr

  | ObjAccess of expr * name
  (* less: slice *)
  | ArrayAccess of expr * expr

  | Conditional of expr * expr * expr
  | Yield of expr

  | OtherExpr of other_expr_operator * any list

  and binary_operator = 
    | Add | Sub | Mult | Div | Mod | Pow
    (* less:  FloorDiv *)
    | LShift | RShift 
    | BitOr | BitXor | BitAnd 
    | And | Or
    | Eq | NotEq 
    | PhysEq | NotPhysEq
    | Lt | LtE | Gt | GtE 
  
  and unary_operator =
    | UPlus | USub | UNot 
    | Incr of bool | Decr of bool (* true = prefix, false = postfix *)

  and container_operator = 
    (* Tuple is lift up *)
    | Array | List
    | Dict | Set

  and arguments = argument list * other_arguments
    and argument =
      | Arg of expr
      | ArgKwd of name * expr

     and other_arguments = (other_argument_operator * any list) list
       and other_argument_operator =
        (* Python *)
        | OA_ArgStar | OA_ArgPow

  and other_expr_operator = 
    | OE_Exports | OE_Module | OE_Define | OE_Arguments | OE_NewTarget
    | OE_Seq | OE_Void
    | OE_Delete | OE_Spread | OE_YieldStar | OE_Await
    | OE_Require | OE_UseStrict
    | OE_ObjAccess_PN_Computed
    | OE_Obj_FieldSpread | OE_Obj_FieldProps
    (* Python *)
    | OE_Imag | OE_FloorDiv 
    | OE_Is | OE_IsNot | OE_In | OE_NotIn
    | OE_Ellipsis | OE_Slice | OE_ExtSlice
    | OE_ListComp | OE_GeneratorExpr 
    | OE_Repr

  and special = 
   (* special vars *)
   | This | Super
   (* special apply *)
   | Eval
   | Typeof | Instanceof 

(* ------------------------------------------------------------------------- *)
(* Type *)
(* ------------------------------------------------------------------------- *)
and type_ =
  | TBuiltin of string wrap
  | OtherType of other_type_operator * any list

  and other_type_operator = 
  (* Python *)
  | OT_Expr

(* ------------------------------------------------------------------------- *)
(* Attribute *)
(* ------------------------------------------------------------------------- *)
(* a.k.a decorators, annotations *)
and attribute = 
  | Static
  (* for class fields *)
  | Public | Private | Protected
  (* for vars *)
  | Var | Let | Const
  (* for functions *)
  | Generator | Async
  (* for methods *)
  | Getter | Setter
  (* for general @annotations *)
  | NamedAttr of name * any list

  | OtherAttribute of other_attribute_operator * any list

  and other_attribute_operator = string

(* ------------------------------------------------------------------------- *)
(* Statement *)
(* ------------------------------------------------------------------------- *)
and stmt =
  (* later: lift Call and Assign here *)
  | ExprStmt of expr

  | Block of stmt list

  | If of expr * stmt * stmt
  | While of expr * stmt
  | DoWhile of stmt * expr
  | For of (expr * expr * expr) * stmt

  | Assert of expr
  | Return of expr
  | Continue of expr | Break of expr

  | Raise of expr
  | Try of stmt * catch list * finally option

  | OtherStmt of other_stmt_operator * any list

  and catch = parameter * stmt
  and finally = stmt

  and other_stmt_operator = 
    (* Python *)
    | OS_Delete | OS_Print
    | OS_ForOrElse | OS_WhileOrElse | OS_TryOrElse
    | OS_With | OsGlobal 
    | OS_Pass
  
(* ------------------------------------------------------------------------- *)
(* Function (or method) definition *)
(* ------------------------------------------------------------------------- *)
and function_definition = {
 fname: name; (* can be fake and gensymed for anonymous functions? *)
 fparams: parameters;
 ftype: type_ option; (* return type *)
 fbody: stmt;
 fattrs: attribute list;
}
  and parameters = parameter list * other_parameters

    and parameter = { 
     pname: name;
     pdefault: expr option;
     ptype: type_ option;
     pattrs: attribute list;
    }
  and other_parameters = (other_parameter_operator * any list) list
   and other_parameter_operator =
     | VarParam
     | KwdParam

(* ------------------------------------------------------------------------- *)
(* Variable definition *)
(* ------------------------------------------------------------------------- *)
and variable_definition = {
  vname: name;
  (* could remove function_definition as expr can be a Lambda but maybe
   * useful to explicitely makes the difference for now? *)
  vinit: expr option;
  vtype: type_ option;
  vattrs: attribute list;
}

(* ------------------------------------------------------------------------- *)
(* Type definition *)
(* ------------------------------------------------------------------------- *)
and type_definition = { 
  ttname: name;
  tattrs: attribute list;
}

(* ------------------------------------------------------------------------- *)
(* Field definition *)
(* ------------------------------------------------------------------------- *)
and field = {
  fldname: name;
  fldattrs: attribute list;
}
(* ------------------------------------------------------------------------- *)
(* Class definition *)
(* ------------------------------------------------------------------------- *)
and class_definition = {
  cname: name;
  cparents: expr list;
  cbody: stmt;
  cattrs: attribute list;
}

(* ------------------------------------------------------------------------- *)
(* Module import/export *)
(* ------------------------------------------------------------------------- *)
and import = 
  | Import of module_name * alias list
  | ImportAll of module_name * name option

  | OtherImport of other_import_operator * any list

  and alias = name * name option

  and other_import_operator = 
  | OI_Export | OI_ImportCss | OI_ImportEffect

(* ------------------------------------------------------------------------- *)
(* Toplevel *)
(* ------------------------------------------------------------------------- *)
and item = 
  | IStmt of stmt

  | IFuncDef of function_definition
  | IVarDef of variable_definition
  | IClassDef of class_definition
  | IImport of import

  | OtherItem of other_item_operator * any list
  and other_item_operator = XXX3

and program = item list

(* ------------------------------------------------------------------------- *)
(* Any *)
(* ------------------------------------------------------------------------- *)
and any =
  | N of name
  | E of expr
  | S of stmt
  | I of item

  | P of program
 (* with tarzan *)

(*****************************************************************************)
(* Wrappers *)
(*****************************************************************************)
let str_of_name = fst
