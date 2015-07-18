// samples/CPS.hx: Continuation-passing for 2-level λ-calculus in -*-hacs-*-
module org.crsx.hacs.samples.Beta {
  main sort E;
  
  // Tokens.
  space [ \t\n] ;
  token ID | [a-z] [_0-9]* ;  // single-letter identifiers

  // λ Calculus Grammar.
  sort V | symbol ⟦⟨ID⟩⟧ ;
  sort E
  |  ⟦  λ ⟨V binds x⟩ . ⟨E[x as E]⟩ ⟧
  |  ⟦ ⟨V⟩ ⟧@2 | sugar ⟦ ( ⟨E#⟩ ) ⟧@2→# ;

  // Applications can reduce.
  | scheme ⟦ ⟨E@1⟩ ⟨E@2⟩ ⟧@1 ;
  ⟦ (λx.⟨E#1[x]⟩) ⟨E#2⟩ ⟧ → #1[E#2] ;
}
