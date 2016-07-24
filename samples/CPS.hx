// Convert λ-calculus with Call-by-Value semantics to CPS in -*-hacs-*-
module org.crsx.hacs.samples.CPS {
  space [ \t\n] ;
  token ID | [a-z] [_0-9]* ;  // single-letter identifiers

  main sort E   // λ calculus grammar.
  |  ⟦  λ ⟨ID binds x⟩ . ⟨E[x as E]⟩ ⟧ | ⟦ ⟨E@1⟩ ⟨E@2⟩ ⟧@1
  |  symbol ⟦⟨ID⟩⟧@2  | sugar ⟦ ( ⟨E#⟩ ) ⟧@2→# ;

  | scheme CPS(E) ;   // one-pass Call-by-Value CPS.
  CPS(#) →  ⟦ λk.{⟨E#⟩ | m.k m} ⟧ ;
  | scheme ⟦ {⟨E⟩ | ⟨ID binds m⟩ . ⟨E[m as E]⟩} ⟧@2 ;
  ⟦ {v | m.⟨E#F[m]⟩} ⟧   →  #F[v] ;
  ⟦ {λx.⟨E#[x]⟩ | m.⟨E#F[m]⟩} ⟧   →  #F[E⟦ λx.λk.{⟨E#[x]⟩ | m.k m} ⟧] ;
  ⟦ {⟨E#0⟩ ⟨E#1⟩ | m.⟨E#F[m]⟩} ⟧   →  ⟦{⟨E#0⟩ | m.{⟨E#1⟩ | n.m n (λa.⟨E#F[a]⟩)}}⟧;
}
