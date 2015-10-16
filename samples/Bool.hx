// Boolean algebra.
module org.crsx.hacs.samples.Bool {

  // Syntax.
  sort B
    | ⟦ t ⟧@4 | ⟦ f ⟧@4				// true and false constants
    | ⟦ ! ⟨B@3⟩ ⟧@3				// negation
    | ⟦ ⟨B@3⟩ & ⟨B@2⟩ ⟧@2			// conjunction
    | ⟦ ⟨B@2⟩ | ⟨B@1⟩ ⟧@1			// disjunction
    | sugar ⟦ ( ⟨B#⟩ ) ⟧@4 →   B#		// parenthesis
    ;

  // Main: evaluate Boolean expression.
  main sort B  | scheme Eval(B) ;
  Eval(# ↑b(#b)) →   #b ;

  // Actual evaluation is a synthesized attribute.
  attribute ↑b(B);
  sort B | ↑b ;

  // Constants.
  ⟦t⟧ ↑b(⟦t⟧) ;
  ⟦f⟧ ↑b(⟦f⟧) ;

  // Disjunction.
  ⟦ ⟨B#1 ↑b(#b1)⟩  | ⟨B#2 ↑b(#b2)⟩ ⟧    ↑b(Or(#b1, #b2)) ;
  | scheme Or(B, B) ;  Or(⟦t⟧, #2) →  ⟦t⟧ ; Or(⟦f⟧, #2) →  #2 ;

  // Conjunction.
  ⟦ ⟨B#1 ↑b(#b1)⟩  & ⟨B#2 ↑b(#b2)⟩ ⟧    ↑b(And(#b1, #b2)) ;
  | scheme And(B, B) ;  And(⟦t⟧, #2) →  #2 ; And(⟦f⟧, #2) →  ⟦f⟧ ;

  // Negation.
  ⟦ ! ⟨B# ↑b(#b)⟩ ⟧   ↑b(Not(#b)) ;
  | scheme Not(B) ;  Not(⟦t⟧) →  ⟦f⟧ ;  Not(⟦f⟧) →  ⟦t⟧ ;

}
