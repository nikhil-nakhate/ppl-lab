(* module Syntax: syntax trees and associated support functions *)

open Support.Pervasive
open Support.Error

(* Data type definitions *)
type ty =
    TyBool
  | TyNat
  | TyWeekend
  | TyWeekday

type term =
    TmTrue of info
  | TmFalse of info
  | TmMonday of info
  | TmTuesday of info
  | TmWednesday of info
  | TmThursday of info
  | TmFriday of info
  | TmSaturday of info
  | TmSunday of info
  | TmIf of info * term * term * term
  | TmZero of info
  | TmSucc of info * term
  | TmPred of info * term
  | TmIsZero of info * term
  | TmIsWeekday of info * term
  | TmNextWeekday of info * term


type command =
  | Eval of info * term



(* Printing *)
val printtm: term -> unit
val printtm_ATerm: bool -> term -> unit
val printty : ty -> unit

(* Misc *)
val tmInfo: term -> info

