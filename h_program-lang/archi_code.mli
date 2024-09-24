
type source_archi =
  | Main | Init
  | Interface
  | Test | Logging
  | Core  | Utils
  | Constants     | GetSet
  | Configuration | Building | Data
  | Doc

  | Ui | Storage | Parsing | Security | I18n
  | Architecture | OS | Network

  | Ffi | ThirdParty  | Legacy
  | AutoGenerated | BoilerPlate

  | Unittester  | Profiler
  | MiniLite | Intern
  | Script

  | Regular
val s_of_source_archi: source_archi -> string

val source_archi_list: source_archi list

type source_kind =
  | Header
  | Source

(* can tell you about architecture, and also about design pbs *)
val find_duplicate_dirname: Common.dirname -> unit
