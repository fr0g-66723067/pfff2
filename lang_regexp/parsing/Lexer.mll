(*
   Lexer for the regexp parser.

   See Parse.mli for a list of to-dos.
*)
{
open AST
open Conf
open Parser

let loc lexbuf : loc =
  let tok = Parse_info.tokinfo lexbuf in
  (tok, tok)

let int = int_of_string

(*
   Decode a well-formed UTF-8 string into a Unicode code point.
*)
let decode s =
  let len = String.length s in
  if len <= 0 then
    assert false
  else
    let a = Char.code s.[0] in
    if len = 1 then
      a
    else
      let b = (Char.code s.[1]) land 0b0011_1111 in
      if len = 2 then
        ((a land 0b0001_1111) lsl 6)
        lor b
      else
        let c = (Char.code s.[2]) land 0b0011_1111 in
        if len = 3 then
          ((a land 0b0000_1111) lsl 12)
          lor (b lsl 6)
          lor c
        else
          if len = 4 then
            let d = (Char.code s.[3]) land 0b0011_1111 in
            ((a land 0b0000_0111) lsl 18)
            lor (b lsl 12)
            lor (c lsl 6)
            lor d
          else
            assert false
}

let line = [^'\n']* '\n'?
let alnum = ['A'-'Z' 'a'-'z' '0'-'9']
let digit = ['0'-'9']
let xdigit = ['A'-'F' 'a'-'f' '0'-'9']
let nonneg = ['0'-'9']+
let capture_name = ['A'-'Z' 'a'-'z' '_'] ['A'-'Z' 'a'-'z' '_' '0'-'9']*

let ascii = ['\000'-'\127']

(* 110xxxxx *)
let utf8_head_byte1 = ['\192'-'\223']

(* 1110xxxx *)
let utf8_head_byte2 = ['\224'-'\239']

(* 11110xxx *)
let utf8_head_byte3 = ['\240'-'\247']

(* 10xxxxxx *)
let utf8_tail_byte = ['\128'-'\191']

let utf8 = ascii
         | utf8_head_byte1 utf8_tail_byte
         | utf8_head_byte2 utf8_tail_byte utf8_tail_byte
         | utf8_head_byte3 utf8_tail_byte utf8_tail_byte utf8_tail_byte

let unicode_character_property = ['A'-'Z'] alnum*

(* This is for the extended mode, which ignores whitespace like in usual
   programming languages.
   TODO: check if non-ascii whitespace should also be ignored in that mode
   (it would be annoying to implement but doable).
*)
let ascii_whitespace =  ['\t' '\n' '\011' '\012' '\r' ' ']

let btk_name = [^')']*

rule token conf = parse
  (* Some of these are only allowed at the beginning of the input.
     For now, we allow them everywhere and ignore them if possible. *)
  | "(*LIMIT_MATCH=" digit+ ")" { token conf lexbuf }
  | "(*LIMIT_RECURSION=" digit+ ")" { token conf lexbuf }
  | "(*NO_AUTO_POSSESS)" { token conf lexbuf }
  | "(*NO_START_OPT)" { token conf lexbuf }
  | "(*UTF8)" { token conf lexbuf }
  | "(*UTF16)" { (* unsupported; should fail? *) token conf lexbuf }
  | "(*UTF32)" { (* unsupported; should fail? *) token conf lexbuf }
  | "(*UTF)" { token conf lexbuf }
  | "(*UCP)" { token { conf with pcre_ucp = true } lexbuf }
  | "(*CR)" { token conf lexbuf }
  | "(*LF)" { token conf lexbuf }
  | "(*CRLF)" { token conf lexbuf }
  | "(*ANYCRLF)" { token conf lexbuf }
  | "(*ANY)" { token conf lexbuf }
  | "(*BSR_ANYCRLF)" { token conf lexbuf }
  | "(*BSR_UNICODE)" { token conf lexbuf }
  | "(*ACCEPT)" { token conf lexbuf }
  | "(*FAIL)" { token conf lexbuf }
  | "(*MARK:" btk_name ")" { token conf lexbuf }
  | "(*COMMIT)" { token conf lexbuf }
  | "(*PRUNE)" { token conf lexbuf }
  | "(*PRUNE:" btk_name ")" { token conf lexbuf }
  | "(*SKIP)" { token conf lexbuf }
  | "(*SKIP:" btk_name ")" { token conf lexbuf }
  | "(*MARK:" btk_name ")" { token conf lexbuf }
  | "(*THEN)" { token conf lexbuf }
  | "(*THEN:" btk_name ")" { token conf lexbuf }

  | "\\Q" {
      let start = loc lexbuf in
      let chars = literal_chars lexbuf in
      let end_ = loc lexbuf in
      STRING (range start end_, chars)
    }

  | '#' {
      if conf.ignore_hash_comments then
        comment_in_token conf lexbuf
      else
        CHAR (loc lexbuf, Singleton (Char.code '#'))
    }
  | ascii_whitespace as c {
      if conf.ignore_whitespace then
        token conf lexbuf
      else
        CHAR (loc lexbuf, Singleton (Char.code c))
    }
  | "(?#" [^')'] ')' as s { COMMENT (loc lexbuf, s) }
  | "(?" {
      let start = loc lexbuf in
      open_group conf start lexbuf
  }
  | '(' { OPEN_GROUP (loc lexbuf, Capturing) }
  | ')' { CLOSE_GROUP (loc lexbuf) }
  | '|' { BAR (loc lexbuf) }

  | '.' {
      CHAR (loc lexbuf, Abstract Dot)
    }

  | '^' {
      if conf.pcre_multiline then
        SPECIAL (loc lexbuf, Beginning_of_input)
      else
        SPECIAL (loc lexbuf, Beginning_of_line)
    }

  | '$' {
      if conf.pcre_multiline then
        SPECIAL (loc lexbuf, End_of_input)
      else
        SPECIAL (loc lexbuf, End_of_line)
    }

  | '[' ('^'? as compl) {
      let start = loc lexbuf in
      let set = char_class conf lexbuf in
      let end_ = loc lexbuf in
      let loc = range start end_ in
      let set =
        match compl with
        | "" -> set
        | _ -> Complement set
      in
      CHAR (loc, set)
    }

  | "(?i)" { SPECIAL (loc lexbuf, Set_option Caseless) }
  | "(?J)" { SPECIAL (loc lexbuf, Set_option Allow_duplicate_names) }
  | "(?m)" { SPECIAL (loc lexbuf, Set_option Multiline) }
  | "(?s)" { SPECIAL (loc lexbuf, Set_option Dotall) }
  | "(?U)" { SPECIAL (loc lexbuf, Set_option Default_lazy) }
  | "(?x)" { SPECIAL (loc lexbuf, Set_option Ignore_whitespace) }

  | "(?-i)" { SPECIAL (loc lexbuf, Clear_option Caseless) }
  | "(?-J)" { SPECIAL (loc lexbuf, Clear_option Allow_duplicate_names) }
  | "(?-m)" { SPECIAL (loc lexbuf, Clear_option Multiline) }
  | "(?-s)" { SPECIAL (loc lexbuf, Clear_option Dotall) }
  | "(?-U)" { SPECIAL (loc lexbuf, Clear_option Default_lazy) }
  | "(?-x)" { SPECIAL (loc lexbuf, Clear_option Ignore_whitespace) }

  | "(?C)" { SPECIAL (loc lexbuf, Callout 0) }
  | "(?C" (digit+ as n) ")" { SPECIAL (loc lexbuf, Callout (int_of_string n)) }

(***************************************************************************)
(* '\' sequences that aren't allowed in character classes *)
(***************************************************************************)
  | '\\' ('-'? ['1'-'9']['0'-'9']* as n)
  | "\\g" ('-'? ['0'-'9']+ as n)
  | "\\g{" ('-'? ['0'-'9']+ as n) "}" {
      SPECIAL (loc lexbuf, Numeric_back_reference (int_of_string n))
    }

  | "\\k{" (capture_name as name) "}" (* pcre, .NET *)
  | "\\k<" (capture_name as name) ">" (* pcre, perl *)
  | "\\k'" (capture_name as name) "'" (* pcre, perl *)
  | "(?P=" (capture_name as name) ")" (* pcre, python *)
  | "\\g{" (capture_name as name) "}" (* pcre, perl *) {
      SPECIAL (loc lexbuf, Named_back_reference name)
    }

  | "\\A" { SPECIAL (loc lexbuf, Beginning_of_input) }
  | "\\Z" { SPECIAL (loc lexbuf, End_of_last_line) }
  | "\\z" { SPECIAL (loc lexbuf, End_of_input) }
  | "\\b" { SPECIAL (loc lexbuf, Word_boundary) }
  | "\\B" { SPECIAL (loc lexbuf, Not_word_boundary) }
  | "\\G" { SPECIAL (loc lexbuf, Beginning_of_match) }
  | "\\K" { SPECIAL (loc lexbuf, Match_point_reset) }

(***************************************************************************)

  | "[:" {
      match posix_char_class conf (loc lexbuf) lexbuf with
      | Ok (loc, x) -> CHAR (loc, x)
      | Error (loc, s) -> STRING (loc, s)
    }

  | '\\' { let loc, x = backslash_escape conf (loc lexbuf) lexbuf in
           CHAR (loc, x) }

  | '?' { QUANTIFIER (loc lexbuf, (0, Some 1), Default) }
  | '*' { QUANTIFIER (loc lexbuf, (0, None), Default) }
  | '+' { QUANTIFIER (loc lexbuf, (1, None), Default) }
  | "??" { QUANTIFIER (loc lexbuf, (0, Some 1), Lazy) }
  | "*?" { QUANTIFIER (loc lexbuf, (0, None), Lazy) }
  | "+?" { QUANTIFIER (loc lexbuf, (1, None), Lazy) }
  | "?+" { QUANTIFIER (loc lexbuf, (0, Some 1), Possessive) }
  | "*+" { QUANTIFIER (loc lexbuf, (0, None), Possessive) }
  | "++" { QUANTIFIER (loc lexbuf, (1, None), Possessive) }

  | '{' (nonneg as a) '}' {
      QUANTIFIER (loc lexbuf, (int a, Some (int a)), Default)
    }
  | '{' (nonneg as a) ',' (nonneg as b) '}' {
      QUANTIFIER (loc lexbuf, (int a, Some (int b)), Default)
    }
  | '{' ',' (nonneg as b) '}' {
      QUANTIFIER (loc lexbuf, (0, Some (int b)), Default)
    }
  | '{' (nonneg as a) ',' '}' {
      QUANTIFIER (loc lexbuf, (int a, None), Default)
    }

  | '{' (nonneg as a) "}?" {
      QUANTIFIER (loc lexbuf, (int a, Some (int a)), Lazy)
    }
  | '{' (nonneg as a) ',' (nonneg as b) "}?" {
      QUANTIFIER (loc lexbuf, (int a, Some (int b)), Lazy)
    }
  | '{' ',' (nonneg as b) "}?" {
      QUANTIFIER (loc lexbuf, (0, Some (int b)), Lazy)
    }
  | '{' (nonneg as a) ',' "}?" {
      QUANTIFIER (loc lexbuf, (int a, None), Lazy)
    }

  | '{' (nonneg as a) "}+" {
      QUANTIFIER (loc lexbuf, (int a, Some (int a)), Possessive)
    }
  | '{' (nonneg as a) ',' (nonneg as b) "}+" {
      QUANTIFIER (loc lexbuf, (int a, Some (int b)), Possessive)
    }
  | '{' ',' (nonneg as b) "}+" {
      QUANTIFIER (loc lexbuf, (0, Some (int b)), Possessive)
    }
  | '{' (nonneg as a) ',' "}+" {
      QUANTIFIER (loc lexbuf, (int a, None), Possessive)
    }

  | utf8 as s { CHAR (loc lexbuf, Singleton (decode s)) }
  | _ as c {
      (* malformed UTF-8 *)
      CHAR (loc lexbuf, Singleton (Char.code c))
    }

  | eof { END (loc lexbuf) }

and literal_chars = parse
  | "\\E" { [] }
  | utf8 as c {
      let loc = loc lexbuf in
      let code = decode c in
      (loc, code) :: literal_chars lexbuf
    }

and backslash_escape conf start = parse
  | '\\' { (range start (loc lexbuf), Singleton (Char.code '\\')) }
  | 'a' { (range start (loc lexbuf), Singleton 0x7) }
  | 'c' (ascii as c) { (range start (loc lexbuf), Singleton (Char.code c)) }
  | 'e' { (range start (loc lexbuf), Singleton 0x1B) }
  | 'f' { (range start (loc lexbuf), Singleton 0x1C) }
  | 'n' { (range start (loc lexbuf), Singleton 0x0A) }
  | 'r' { (range start (loc lexbuf), Singleton 0x0D) }
  | 't' { (range start (loc lexbuf), Singleton 0x09) }

  | (['0'-'9']+ as n)
  | "o{" (['0'-'9']+ as n) "}" {
      (range start (loc lexbuf), Singleton (int_of_string ("0o" ^ n)))
    }

  | "x" (xdigit+ as n) {
      (range start (loc lexbuf), Singleton (int_of_string ("0x" ^ n)))
    }

  | "x{" (xdigit+ as n) "}" {
      let loc = range start (loc lexbuf) in
      (* TODO: conf.pcre_javascript_compat should not allow this syntax.
         It should treat \x{42} as x{42} ('x' repeated 42 times)
         and \x{0A} as x\{0A\} (literal 'x{0A}').
         This is very complicated to implemented without rolling back the
         lexbuf and calling another lexer to the rescue.
         Sedlex offers such functionality for sure. Otherwise it might
         be possible to tweak the lexbuf to achieve this as well,
         see https://sympa.inria.fr/sympa/arc/caml-list/2006-07/msg00133.html
      *)
      (loc, Singleton (int_of_string ("0x" ^ n)))
    }

  | "u" (xdigit+ as n) {
      let loc = range start (loc lexbuf) in
      (* TODO: only conf.pcre_javascript_compat should allow this syntax.
         See remark above about the need to roll back. *)
      (loc, Singleton (int_of_string ("0x" ^ n)))
    }

  | 'p' (['A'-'Z' 'a'-'z' '_'] as c) {
      let name = String.make 1 c in
      (range start (loc lexbuf), Abstract (Unicode_character_property name))
    }
  | 'P' (['A'-'Z' 'a'-'z' '_'] as c) {
      let name = String.make 1 c in
      (
        range start (loc lexbuf),
        Complement (Abstract (Unicode_character_property name))
      )
    }
  | "p{" ('^'? as compl) (unicode_character_property as name) "}" {
      let set =
        Abstract (Unicode_character_property name)
      in
      let set =
        match compl with
        | "" -> set
        | _ -> Complement set
      in
      (range start (loc lexbuf), set)
    }
  | "P{" ('^'? as compl) (unicode_character_property as name) "}" {
      let set =
        Abstract (Unicode_character_property name)
      in
      let set =
        match compl with
        | "" -> Complement set
        | _ -> (* double complement cancels out *) set
      in
      (range start (loc lexbuf), set)
    }

  | (['A'-'Z''a'-'z'] as c) {
      let loc = range start (loc lexbuf) in
      let ucp = conf.pcre_ucp in
      let set =
        match c with
        | 'd' when ucp -> Char_class.unicode_digit
        | 'd' -> Char_class.posix_digit
        | 'D' when ucp -> Complement Char_class.unicode_digit
        | 'D' -> Complement Char_class.posix_digit
        | 'h' -> Char_class.unicode_horizontal_whitespace
        | 'H' -> Complement (Char_class.unicode_horizontal_whitespace)
        | 's' when ucp -> Char_class.unicode_whitespace
        | 's' -> Char_class.perl_whitespace
        | 'S' when ucp -> Complement (Char_class.unicode_whitespace)
        | 'S' -> Complement (Char_class.perl_whitespace)
        | 'v' -> Char_class.unicode_vertical_whitespace
        | 'V' -> Complement (Char_class.unicode_vertical_whitespace)
        | 'w' when ucp -> Char_class.unicode_word
        | 'w' -> Char_class.perl_word
        | 'W' when ucp -> Complement Char_class.unicode_word
        | 'W' -> Complement Char_class.perl_word
        | c -> Singleton (Char.code c)
      in
      (loc, set)
    }
  | utf8 as s {
        (* just ignore the backslash *)
        (loc lexbuf, Singleton (decode s))
      }
  | _ as c {
        (* malformed UTF-8 *)
        (loc lexbuf, Singleton (Char.code c))
      }
  | eof {
      (* truncated input *)
      (loc lexbuf, Empty)
    }

and open_group conf start = parse
  | '#' {
      (* In extended mode, PCRE allows comments here but not whitespace.
         Not sure why. We do the same. *)
      if conf.ignore_hash_comments then
        comment_in_open_group conf start lexbuf
      else
        let loc = range start (loc lexbuf) in
        OPEN_GROUP (loc, Other (Char.code '#'))
    }
  | ':' {
      let loc = range start (loc lexbuf) in
      OPEN_GROUP (loc, Non_capturing)
  }
  | '=' {
      let loc = range start (loc lexbuf) in
      OPEN_GROUP (loc, Lookahead)
  }
  | '!' {
      let loc = range start (loc lexbuf) in
      OPEN_GROUP (loc, Neg_lookahead)
    }
  | "<=" {
      let loc = range start (loc lexbuf) in
      OPEN_GROUP (loc, Lookbehind)
    }
  | "<!" {
      let loc = range start (loc lexbuf) in
      OPEN_GROUP (loc, Neg_lookbehind)
    }
  | ">" {
      let loc = range start (loc lexbuf) in
      OPEN_GROUP (loc, Atomic)
    }

  | "<" (capture_name as name) ">" {
      (* pcre, perl *)
      let loc = range start (loc lexbuf) in
      OPEN_GROUP (loc, Named_capture name)
    }

  | "'" (capture_name as name) "'" {
      (* pcre, python *)
      let loc = range start (loc lexbuf) in
      OPEN_GROUP (loc, Named_capture name)
    }

  | "|" {
      let loc = range start (loc lexbuf) in
      OPEN_GROUP (loc, Non_capturing_reset)
    }

  | utf8 as other {
      let loc = range start (loc lexbuf) in
      OPEN_GROUP (loc, Other (decode other))
    }
  | _ as c {
      (* malformed UTF-8 *)
      let loc = range start (loc lexbuf) in
      OPEN_GROUP (loc, Other (Char.code c))
    }
  | eof { END (loc lexbuf) }

and posix_char_class conf start = parse
  | ('^'? as compl) (['a'-'z']+ as name) ":]" {
      let loc = range start (loc lexbuf) in
      let compl x =
        match compl with
        | "" -> x
        | _ -> Complement x
      in
      let ascii char_class =
        Ok (loc, compl char_class)
      in
      let unicode prop_name =
        Ok (loc, compl (Abstract (Unicode_character_property prop_name)))
      in
      let ucp = conf.pcre_ucp in
      match name with
      | "alnum" when ucp -> unicode "Xan"
      | "alnum" -> ascii Char_class.posix_alnum
      | "alpha" when ucp -> unicode "L"
      | "alpha" -> ascii Char_class.posix_alpha
      | "ascii" -> ascii Char_class.posix_ascii
      | "blank" when ucp -> unicode "h"
      | "blank" -> ascii Char_class.perl_blank
      | "cntrl" -> ascii Char_class.posix_cntrl
      | "digit" when ucp -> unicode "Nd"
      | "digit" -> ascii Char_class.posix_digit
      | "graph" -> ascii Char_class.posix_graph
      | "lower" when ucp -> unicode "Ll"
      | "lower" -> ascii Char_class.posix_lower
      | "print" -> ascii Char_class.posix_print
      | "punct" -> ascii Char_class.posix_punct
      | "space" when ucp -> unicode "Xps"
      | "space" -> ascii Char_class.posix_space
      | "upper" when ucp -> unicode "Lu"
      | "upper" -> ascii Char_class.posix_upper
      | "word" when ucp -> unicode "Xwd"
      | "word" -> ascii Char_class.perl_word
      | "xdigit" -> ascii Char_class.posix_xdigit
      | _ ->
          Error (
            loc,
            AST.code_points_of_ascii_string_loc loc
              ("[:" ^ Lexing.lexeme lexbuf)
          )
}

and char_class conf = parse
  | '#' {
      if conf.ignore_hash_comments then
        comment_in_char_class conf lexbuf
      else
        Singleton (Char.code '#')
    }
  | ascii_whitespace as c {
      if conf.ignore_whitespace_in_char_classes then
        char_class conf lexbuf
      else
        Singleton (Char.code c)
    }
  | ']' {
      Empty
    }
  | (utf8 as a) '-' (utf8 as b) {
      let range = Range (decode a, decode b) in
      union range (char_class conf lexbuf)
    }
  | "[:" {
      match posix_char_class conf (loc lexbuf) lexbuf with
      | Ok (_loc, x) ->
          union x (char_class conf lexbuf)
      | Error (_loc, chars) ->
          union (Char_class.of_list_pos chars) (char_class conf lexbuf)
    }
  | '\\' {
      let _loc, x = backslash_escape conf (loc lexbuf) lexbuf in
      union x (char_class conf lexbuf)
    }
  | utf8 as s {
      union (Singleton (decode s)) (char_class conf lexbuf)
    }
  | _ as c {
      (* malformed UTF-8 *)
      union (Singleton (Char.code c)) (char_class conf lexbuf)
    }
  | eof {
      (* truncated input, should be an error *)
      Empty
    }

and comment_in_token conf = parse
  | line { token conf lexbuf }

and comment_in_open_group conf start = parse
  | line { open_group conf start lexbuf }

and comment_in_char_class conf = parse
  | line { char_class conf lexbuf }
