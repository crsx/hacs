module org.crsx.hacs.samples.Lambda {

// Variables and type variables.

token NAME | [a-z] [a-z0-9_]* ;
sort V | symbol ⟦⟨NAME⟩⟧ ;
sort TV | symbol ⟦⟨NAME⟩⟧ ;

// Simple types.

sort T
| ⟦ ⟨T@2⟩ → ⟨T@1⟩ ⟧@1
| ⟦ ⟨TV⟩ ⟧@2
| sugar ⟦ (⟨T#⟩) ⟧@2 → T#
;

// Lambda expressions.

main sort E
| ⟦ λ ⟨V binds x⟩ : ⟨T⟩ . ⟨E[x as E]@1⟩ ⟧@1
| ⟦ ⟨E@2⟩ ⟨E@3⟩ ⟧@2
| ⟦ ⟨V⟩ ⟧@3
| sugar ⟦ ( ⟨E#⟩ ) ⟧@3 → E#
;

// Reduction rules.

[Beta] ⟦ (λ x : ⟨T#t⟩ . ⟨E#b[x]⟩) ⟨E#a⟩ ⟧ → E#b[E#a] ;
[Eta]  ⟦ λ x : ⟨T#t⟩ . ⟨E#e⟩ x ⟧ → ⟦⟨E#e⟩⟧ ;

// Type analysis.

// Spread variable types throughout term.

attribute ↑t(T);
attribute ↓te{TV : T};

sort E;
| scheme ⟦ TE1 ⟨E⟩ ⟧ ↓te ;
⟦ TE1 (λ x : ⟨T#tx⟩ . ⟨E#e[x]⟩) ⟧ → ⟦ λ x : ⟨T#tx⟩ . ⟨ E ⟦TE1 ⟨E#e[x]⟩⟧ ↓te{x : #tx} ⟩ ⟧ ;
⟦ TE1 (⟨E#f⟩ ⟨E#a⟩) ⟧ → ⟦ (TE1 ⟨E#f⟩) (TE1 ⟨E#a⟩) ⟧ ;
⟦ TE1 (x) ⟧ ↓te{x : #tx} → ⟦ x ⟧ ↑t(#tx) ;

sort E;
| scheme TE2(E) ↓te ;
TE2(⟦ λ x : ⟨T#tx⟩ . ⟨E#e[x]⟩ ⟧) → ⟦ λ x : ⟨T#tx⟩ . ⟨E TE2(E#e[x]) ↓te{x:#tx} ⟩ ⟧ ;
TE2(⟦ ⟨E#f⟩ ⟨E#a⟩ ⟧) → ⟦ ⟨E TE2(E#f)⟩ ⟨E TE2(E#a)⟩ ⟧ ;
TE2(⟦ x ⟧) ↓te{x : #t} → ⟦ x ⟧ ↑t(#tx) ;

sort E;
⟦ λ x : ⟨T#tx⟩ . ⟨E#e[x] ↑t(#te)⟩ ⟧ ↑t(⟦ ⟨T#tx⟩ → ⟨T#te⟩ ⟧) ;
⟦ ⟨E#f ↑t(#tf)⟩ ⟨E#a ↑t(#ta)⟩ ⟧ ↑t(Unify(#tf, ⟦a→b⟧, Unify(#ta, ⟦a⟧, ⟦b⟧))) ;

}
