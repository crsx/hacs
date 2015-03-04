module edu.nyu.cs.cc.Desk {

  // Syntax.

  token NUM | [0-9]+ ;

  sort E
    | ⟦ ⟨NUM⟩ ⟧@5
    | sugar ⟦ ( ⟨E#⟩ ) ⟧@5 → #

    | ⟦ ⟨E@2⟩ / ⟨E@3⟩ ⟧@2
    | ⟦ ⟨E@2⟩ * ⟨E@3⟩ ⟧@2

    | ⟦ ⟨E@1⟩ - ⟨E@2⟩ ⟧@1
    | ⟦ ⟨E@1⟩ + ⟨E@2⟩ ⟧@1
    ;

  // Evaluation.

  sort Computed | scheme Eval(E) ;
  Eval(⟦ ⟨NUM#⟩ ⟧) → ⟦ $# ⟧ ;

  Eval(⟦ ⟨E#1⟩ + ⟨E#2⟩ ⟧) →  Plus(Eval(#1), Eval(#2)) ;
  | scheme Plus(Computed, Computed) ;
  Plus(#1, #2) → ⟦ #1 + #2 ⟧ ;

  Eval(⟦ ⟨E#1⟩ - ⟨E#2⟩ ⟧) →  Minus(Eval(#1), Eval(#2)) ;
  | scheme Minus(Computed, Computed) ;
  Minus(#1, #2) → ⟦ #1 - #2 ⟧ ;
  
  Eval(⟦ ⟨E#1⟩ * ⟨E#2⟩ ⟧) →  Times(Eval(#1), Eval(#2)) ;
  | scheme Times(Computed, Computed) ;
  Times(#1, #2) → ⟦ #1 * #2 ⟧ ;

  Eval(⟦ ⟨E#1⟩ / ⟨E#2⟩ ⟧) →  Divide(Eval(#1), Eval(#2)) ;
  | scheme Divide(Computed, Computed) ;
  Divide(#1, #2) → ⟦ #1 / #2 ⟧ ;
}
