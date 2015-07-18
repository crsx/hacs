// samples/CPS.hx: Continuation-passing for 2-level λ-calculus in -*-hacs-*-
module org.crsx.hacs.samples.V {
  main sort E;

  // Tokens.
  space [ \t\n] ;
  token ID | [a-z] [_0-9]* ;  // single-letter identifiers

  sort V | symbol ⟦⟨ID⟩⟧ ;

  sort E  |  ⟦ ⟨V⟩ ⟧ ;
}
