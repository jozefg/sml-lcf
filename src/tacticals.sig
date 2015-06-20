(* A collection of common, system agnostic tactics. This is the
 * payoff for structures implementing LCF. These tactics can be used
 * to compositionally build up sophisticated logic programs from
 * collection of small, system-dependent tactics.
 *)
signature TACTICALS =
sig
  type tactic

  (* The identity tactic. This produces one subgoal: the
   * original goal. It will always succeed but never
   * do anything.
   *)
  val ID : tactic

  (* Given a two tactics THEN (t1, t2) will run t1 and
   * use t2 to further compute information about the subgoals
   * it leaves behind. This is similar to the [;] operation
   * in Coq's Ltac.
   *
   * The ID tactic acts as an identity for THEN so
   *    THEN (id, t) = t = THEN (t, id)
   *)
  val THEN : tactic * tactic -> tactic

  (* THENL (t1, t2s) runs t1 and runs the first element of t2s
   * on the first subgoal produced, the second element on the second
   * subgoal, and so on and so on and so on.
   *
   * If there is a mismatch between the number of tactics supplied and
   * the number of subgoals created, the tactic will fail.
   *)
  val THENL : tactic * tactic list -> tactic

  (* THEN_LAZY behaves as THEN does but will only evaluate the
   * second tactic (the one used on subgoals) if/when the first
   * tactic generates them.
   *)
  val THEN_LAZY : tactic * (unit -> tactic) -> tactic

  (* THENL_LAZY behaves THENL but only evaluates the list of
   * tactics if and when it is needed.
   *)
  val THENL_LAZY : tactic * (unit -> tactic list) -> tactic

  (* REPEAT t will run a tactic over and over again. It can be thought
   * of THEN (t, THEN (t, (Then t, ...))).
   *
   * It will halt either when t fails or when it has run out of subgoals
   * to continue to do work on. This tactic can never fail; if the tactic
   * ever fails it will merely revert the goal to the state it was in
   * before REPEAT t was run, behaving as ID.
   *)
  val REPEAT : tactic -> tactic

  (* The Eeyore of tactics. This always fails, no matter what
   * the goal.
   *)
  val FAIL : tactic

  (* ORELSE lets a script handling a tactic fail. It will run the first
   *  tactic and it if fails, it will revert to the original goal and
   * run the second tactic as if the first had never run.
   *
   * In particular this means that if both fail the user will only
   * see the error message from the second tactic.
   *)
  val ORELSE : tactic * tactic -> tactic

  (* ORELSE_LAZY behaves as ORELSE does but avoids evaluating
   * the second tactic unless it is needed (unless the first one
   * fails)
   *)
  val ORELSE_LAZY : tactic * (unit -> tactic) -> tactic

  (* TRY t will attempt to run the tactic t and if it fails it will
   * simply leave the goal alone. This tactic is idempotent.
   *)
  val TRY : tactic -> tactic

  (* TRACE s will print out s to the console when run and then behave
   * like ID
   *)
  val TRACE : string -> tactic
end

signature PROGRESS_TACTICALS =
sig
  include TACTICALS

  (* PROGRESS t runs t on the goal. If t produces some change*
   * in the goal or fails it behaves exactly as t. If t "succeeds"
   * but does nothing PROGRESS t will fail.
   *
   * *what change means is system dependent. The default implementation
   * of this tactic in ProgressTacticals relies on the notion of apartness
   * given by a structure implementing the LCF_APART signature.
   *)
  val PROGRESS : tactic -> tactic

  (* LIMIT t is a better behaved version of REPEAT. In particular it
   * will stop if t ever stops affecting the goal. This means that
   * REPEAT ID will loop but LIMIT ID will stop immediately.
   *)
  val LIMIT : tactic -> tactic
end
