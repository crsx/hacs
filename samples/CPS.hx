// samples/CPS.hx: Continuation-passing for 2-level λ-calculus in -*-hacs-*-
module org.crsx.hacs.samples.CPS {

  // Tokens.
  space [ \t\n] ;
  token ID | [a-z] [_0-9]* ;  // single-letter identifiers

  // λ Calculus Grammar.
  main sort E
  |  ⟦  λ ⟨ID binds x⟩ . ⟨E[x as E]⟩ ⟧ | ⟦ ⟨E@1⟩ ⟨E@2⟩ ⟧@1
  |  symbol ⟦ ⟨ID⟩ ⟧@2 | sugar ⟦ ( ⟨E#⟩ ) ⟧@2→# ;

  // One-pass CBV CPS.
  | scheme CPS(E) ;
  CPS(#) → ⟦ λk.{⟨E#⟩ | m.k m} ⟧ ;
  | scheme ⟦ {⟨E⟩ | ⟨ID binds m⟩ . ⟨E[m as E]⟩} ⟧@2 ;
  ⟦ {v | m.⟨E#F[m]⟩} ⟧ →  #F[v] ;
  ⟦ {λx.⟨E#[x]⟩ | m.⟨E#F[m]⟩} ⟧→#F[E⟦ λx.λk.{⟨E#[x]⟩ | m.k m} ⟧] ;
  ⟦ {⟨E#0⟩ ⟨E#1⟩ | m.⟨E#F[m]⟩} ⟧→⟦{⟨E#0⟩ | m.{⟨E#1⟩ | n.m n (λa.⟨E#F[a]⟩)}}⟧;
}
