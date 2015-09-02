// samples/CPS.hx: Continuation-passing for 2-level λ-calculus in -*-hacs-*-
module org.crsx.hacs.samples.CPS {

  // Tokens.
  space [ \t\n] ;
  token ID | [a-z] [_0-9]* ;  // single-letter identifiers

  // λ Calculus Grammar.
  main sort E
  |  ⟦  λ ⟨ID binds x⟩ . ⟨E[x as E]⟩ ⟧ | ⟦ ⟨E@1⟩ ⟨E@2⟩ ⟧@1
  |  symbol ⟦ ⟨ID⟩ ⟧@2 | sugar ⟦ ( ⟨E#⟩ ) ⟧@2→# ;

  // Static (or ``administrative'') reduction support.
  |  ⟦  λ̅ ⟨ID binds x⟩ . ⟨E[x as E]⟩ ⟧ | scheme ⟦ ⟨E@1⟩‾⟨E@2⟩ ⟧@1 ;
  ⟦ (λ̅x.⟨E#1[x]⟩)‾⟨E#2⟩ ⟧ → #1[E#2] ;

  // Classic CBV CPS.
  | scheme CPS1(E) ;
  CPS1(#) → ⟦ λk.{⟨E#⟩}‾(λ̅m.k m) ⟧ ;
  | scheme ⟦ {⟨E⟩} ⟧@2 ;
  ⟦ {v} ⟧ → ⟦ λ̅k.k‾v ⟧ ;
  ⟦ {λx.⟨E#[x]⟩} ⟧ → ⟦ λ̅k.k‾(λx.λn.{⟨E#[x]⟩}‾(λ̅m.n m)) ⟧ ;
  ⟦ {⟨E#0⟩ ⟨E#1⟩} ⟧ → ⟦ λ̅k.{⟨E#0⟩}‾(λ̅m.{⟨E#1⟩}‾(λn.m n (λa.k‾a))) ⟧ ;

  // One-pass CBV CPS.
  | scheme CPS2(E) ;
  CPS2(#) → ⟦ λk.{⟨E#⟩ | m.k m} ⟧ ;
  | scheme ⟦ {⟨E⟩ | ⟨ID binds m⟩ . ⟨E[m as E]⟩} ⟧@2 ;
  ⟦ {v | m.⟨E#F[m]⟩} ⟧ →  #F[v] ;
  ⟦ {λx.⟨E#[x]⟩ | m.⟨E#F[m]⟩} ⟧→#F[E⟦ λx.λk.{⟨E#[x]⟩ | m.k m} ⟧] ;
  ⟦ {⟨E#0⟩ ⟨E#1⟩ | m.⟨E#F[m]⟩} ⟧→⟦{⟨E#0⟩ | m.{⟨E#1⟩ | n.m n (λa.⟨E#F[a]⟩)}}⟧;
}
