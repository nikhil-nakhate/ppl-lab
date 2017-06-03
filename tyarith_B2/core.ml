open Format
open Syntax
open Support.Error
open Support.Pervasive

(* ------------------------   EVALUATION  ------------------------ *)

exception NoRuleApplies

let rec isnumericval t = match t with
    TmZero(_) -> true
  | TmSucc(_,t1) -> isnumericval t1
  | _ -> false

let rec isval t = match t with
    TmTrue(_)  -> true
  | TmFalse(_) -> true
  | t when isnumericval t  -> true
  | _ -> false

let rec eval1 t = match t with
    TmIf(_,TmTrue(_),t2,t3) ->
      t2
  | TmIf(_,TmFalse(_),t2,t3) ->
      t3
  | TmIf(fi,t1,t2,t3) ->
      let t1' = eval1 t1 in
      TmIf(fi, t1', t2, t3)
  | TmSucc(fi,t1) ->
      let t1' = eval1 t1 in
      TmSucc(fi, t1')
  | TmPred(_,TmZero(_)) ->
      TmZero(dummyinfo)
  | TmPred(_,TmSucc(_,nv1)) when (isnumericval nv1) ->
      nv1
  | TmPred(fi,t1) ->
      let t1' = eval1 t1 in
      TmPred(fi, t1')
  | TmIsZero(_,TmZero(_)) ->
      TmTrue(dummyinfo)
  | TmIsZero(_,TmSucc(_,nv1)) when (isnumericval nv1) ->
      TmFalse(dummyinfo)
  | TmIsZero(fi,t1) ->
      let t1' = eval1 t1 in
      TmIsZero(fi, t1')
  | TmIsWeekday(_,TmSaturday(_)) -> TmFalse(dummyinfo)
  | TmIsWeekday(_,TmSunday(_)) -> TmFalse(dummyinfo)
  | TmIsWeekday(_,TmMonday(_)) -> TmTrue(dummyinfo)
  | TmIsWeekday(_,TmTuesday(_)) -> TmTrue(dummyinfo)
  | TmIsWeekday(_,TmWednesday(_)) -> TmTrue(dummyinfo)
  | TmIsWeekday(_,TmThursday(_)) -> TmTrue(dummyinfo)
  | TmIsWeekday(_,TmFriday(_)) -> TmTrue(dummyinfo)




  | TmNextWeekday(_,TmMonday(_)) -> TmTuesday(dummyinfo)
  | TmNextWeekday(_,TmTuesday(_)) -> TmWednesday(dummyinfo)
  | TmNextWeekday(_,TmWednesday(_)) -> TmThursday(dummyinfo)
  | TmNextWeekday(_,TmThursday(_)) -> TmFriday(dummyinfo)
  | TmNextWeekday(_,TmFriday(_)) -> TmMonday(dummyinfo)
  | TmNextWeekday(_,TmSaturday(_)) -> TmMonday(dummyinfo)
  | TmNextWeekday(_,TmSunday(_)) -> TmMonday(dummyinfo)

  | TmIsWeekday(fi,t1) ->
      let t1' = eval1 t1 in
      TmIsWeekday(fi, t1')
  | _ -> 
      raise NoRuleApplies

let rec eval t =
  try let t' = eval1 t
      in eval t'
  with NoRuleApplies -> t

(* ------------------------   TYPING  ------------------------ *)

let rec typeof t =
  match t with
    TmTrue(fi) -> 
      TyBool
  | TmFalse(fi) -> 
      TyBool
  | TmSaturday(fi) -> 
      TyWeekend
  | TmSunday(fi) -> 
      TyWeekend
  | TmMonday(fi) -> 
      TyWeekday
  | TmTuesday(fi) -> 
      TyWeekday
  | TmWednesday(fi) -> 
      TyWeekday
  | TmThursday(fi) -> 
      TyWeekday
  | TmFriday(fi) -> 
      TyWeekday

  | TmIsWeekday(fi,t1) ->
      if (=) (typeof t1) TyWeekday then TyBool
      else if  (=) (typeof t1) TyWeekend then TyBool
           else error fi "argument of isweekday is not a day"


  | TmNextWeekday(fi,t1) ->
      if (=) (typeof t1) TyWeekday then TyWeekday
      else if (=) (typeof t1) TyWeekend then TyWeekday
           else  error fi "argument of nextweekday is not a day" 

  
  | TmIf(fi,t1,t2,t3) ->
     if (=) (typeof t1) TyBool then
       let tyT2 = typeof t2 in
       if (=) tyT2 (typeof t3) then tyT2
       else error fi "arms of conditional have different types"
     else error fi "guard of conditional not a boolean"
  | TmZero(fi) ->
      TyNat
  | TmSucc(fi,t1) ->
      if (=) (typeof t1) TyNat then TyNat
      else error fi "argument of succ is not a number"
  | TmPred(fi,t1) ->
      if (=) (typeof t1) TyNat then TyNat
      else error fi "argument of pred is not a number"
  | TmIsZero(fi,t1) ->
      if (=) (typeof t1) TyNat then TyBool
      else error fi "argument of iszero is not a number"
