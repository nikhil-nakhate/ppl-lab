open Format
open Support.Error
open Support.Pervasive

(* ---------------------------------------------------------------------- *)
(* Datatypes *)

type ty =
    TyBool  
  | TyNat
  | TyNatPair
  | TyBoolPair


type term =
    TmTrue of info
  | TmFalse of info
  | TmIf of info * term * term * term
  | TmZero of info
  | TmSucc of info * term
  | TmPred of info * term
  | TmIsZero of info * term
  | TmPair of info * term * term
  | TmFirst of info * term * term
  | TmSecond of info * term * term

type command =
  | Eval of info * term

(* ---------------------------------------------------------------------- *)
(* Extracting file info *)

let tmInfo t = match t with
    TmTrue(fi) -> fi
  | TmFalse(fi) -> fi
  | TmIf(fi,_,_,_) -> fi
  | TmZero(fi) -> fi
  | TmSucc(fi,_) -> fi
  | TmPred(fi,_) -> fi
  | TmIsZero(fi,_) -> fi
  | TmPair(fi,_,_) -> fi
  | TmFirst(fi,_,_) -> fi
  | TmSecond(fi,_,_) -> fi 

(* ---------------------------------------------------------------------- *)
(* Printing *)

(* The printing functions call these utility functions to insert grouping
  information and line-breaking hints for the pretty-printing library:
     obox   Open a "box" whose contents will be indented by two spaces if
            the whole box cannot fit on the current line
     obox0  Same but indent continuation lines to the same column as the
            beginning of the box rather than 2 more columns to the right
     cbox   Close the current box
     break  Insert a breakpoint indicating where the line maybe broken if
            necessary.
  See the documentation for the Format module in the OCaml library for
  more details. 
*)

let obox0() = open_hvbox 0
let obox() = open_hvbox 2
let cbox() = close_box()
let break() = print_break 0 0

let rec printty_Type outer tyT = match tyT with
      tyT -> printty_AType outer tyT

and printty_AType outer tyT = match tyT with
    TyBool -> pr "Bool"
  | TyNat -> pr "Nat"
  | TyNatPair -> pr "natpair"
  | TyBoolPair -> pr "boolpair"
  | tyT -> pr "("; printty_Type outer tyT; pr ")"

let printty tyT = printty_Type true tyT 

let rec printtm_Term outer t = match t with
    TmIf(fi, t1, t2, t3) ->
       obox0();
       pr "if ";
       printtm_Term false t1;
       print_space();
       pr "then ";
       printtm_Term false t2;
       print_space();
       pr "else ";
       printtm_Term false t3;
       cbox();
  |  TmFirst(fi, t1, t2) ->
       obox0();
       pr "first";
       print_space();
       pr "(";
       printtm_Term false t1;
       pr ",";
       print_space();
       printtm_Term false t2;
       pr ")";
       cbox();
  |  TmSecond(fi, t1, t2) ->
       obox0();
       pr "second";
       print_space();
       pr "(";
       printtm_Term false t1;
       pr ",";
       print_space();
       printtm_Term false t2;
       pr ")";
       cbox();
  |  TmPair(fi, t1, t2) ->
       obox0();
      (* pr "pair";
       print_space();*)
       pr "(";
       printtm_Term false t1;
       pr ",";
       print_space();
       printtm_Term false t2;
       pr ")";
       cbox();
  | t -> printtm_AppTerm outer t

and printtm_AppTerm outer t = match t with
    TmPred(_,t1) ->
       pr "pred "; printtm_ATerm false t1
  | TmIsZero(_,t1) ->
       pr "iszero "; printtm_ATerm false t1
  | t -> printtm_ATerm outer t

and printtm_ATerm outer t = match t with
    TmTrue(_) -> pr "true"
  | TmFalse(_) -> pr "false"
  | TmZero(fi) ->
       pr "0"
  | TmSucc(_,t1) ->
     let rec f n t = match t with
         TmZero(_) -> pr (string_of_int n)
       | TmSucc(_,s) -> f (n+1) s
       | _ -> (pr "(succ "; printtm_ATerm false t1; pr ")")
     in f 1 t1
  | TmPred(_,t1) ->
     let rec f n t = match t with
         TmZero(_) -> pr (string_of_int n)
       | TmPred(_,s) -> f (n-1) s
       | _ -> (pr "(pred "; printtm_ATerm false t1; pr ")")
     in f (-1) t1
  | t -> pr "("; printtm_Term outer t; pr ")"

let printtm t = printtm_Term true t 




