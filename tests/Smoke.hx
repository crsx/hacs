module org.crsx.hacs.tests.smoke.Smoke {

// Variables and type variables.

token NAME | [a-z] [a-z0-9_]* ;

// Simple types.

sort T
| ⟦ ⟨T@2⟩ → ⟨T@1⟩ ⟧@1
| symbol ⟦ ⟨NAME⟩ ⟧@2
| sugar ⟦ (⟨T#⟩) ⟧@2 → T#
;

// Lambda expressions.

sort E
| ⟦ ⟨E⟩ :: ⟨T⟩ ⟧
| ⟦ λ ⟨NAME binds x⟩ : ⟨T⟩ . ⟨E[x as E]@1⟩ ⟧@1
| ⟦ ⟨E@2⟩ $ ⟨E@1⟩ ⟧@1
| ⟦ ⟨E@2⟩ ⟨E@3⟩ ⟧@2
| symbol ⟦ ⟨NAME⟩ ⟧@3
| sugar ⟦ ( ⟨E#⟩ ) ⟧@3 → E#
| ⟦⟨INT⟩⟧@3
;

token INT | [0-9]+ ;

// Reduction rules.

sort E;
⟦ (λ x : ⟨T#t⟩ . ⟨E#b[x]⟩) ⟨E#a⟩ ⟧ → E#b[E#a] ;
⟦ λ x : ⟨T#t⟩ . ⟨E#e⟩ x ⟧ → E#e ;

// Type analysis.

attribute ↑t(T);
attribute ↓te{T : T};

sort E;
| scheme ⟦ TE1 ⟨E⟩ ⟧ ↓te ;
⟦ TE1 (λ x : ⟨T#tx⟩ . ⟨E#e[x]⟩) ⟧ → ⟦ λ x : ⟨T#tx⟩ . ⟨ E ⟦TE1 ⟨E#e[x]⟩⟧ ↓te{x : #tx} ⟩ ⟧ ;
⟦ TE1 (⟨E#f⟩ ⟨E#a⟩) ⟧ → ⟦ (TE1 ⟨E#f⟩) (TE1 ⟨E#a⟩) ⟧ ;

⟦ TE1 (x) ⟧ ↓te{x : #tx} → ⟦ x ⟧ ↑t(#tx) ;
⟦ TE1 (x) ⟧ ↓te{¬ x} → error⟦Undefined variable.⟧ ;

| scheme TE2(E) ↓te ;
TE2(⟦ λ x : ⟨T#tx⟩ . ⟨E#e[x]⟩ ⟧) → ⟦ λ x : ⟨T#tx⟩ . ⟨E TE2(E#e[x]) ↓te{x:#tx} ⟩ ⟧ ;
TE2(⟦ ⟨E#f⟩ ⟨E#a⟩ ⟧) → ⟦ ⟨E TE2(E#f)⟩ ⟨E TE2(E#a)⟩ ⟧ ;
TE2(⟦ x ⟧) ↓te{x : #t} → ⟦ x ⟧ ↑t(#t) ;
TE2(⟦ x ⟧) ↓te{¬x} → error⟦Undefined variable.⟧ ;
TE2(⟦ ⟨INT#i⟩ ⟧) → ⟦ ⟨INT#i⟩ ⟧ ;

| ↑t ;
⟦ λ x : ⟨T#tx⟩ . ⟨E#e[x] ↑t(#te)⟩ ⟧ ↑t(⟦ ⟨T#tx⟩ → ⟨T#te⟩ ⟧) ;
⟦ ⟨E#f ↑t(#tf)⟩ ⟨E#a ↑t(#ta)⟩ ⟧ ↑t(Unify(#tf, ⟦a→b⟧, Unify(#ta, ⟦a⟧, ⟦b⟧))) ;
⟦⟨INT#⟩⟧ ↑t(⟦int⟧) ;

sort T;
| scheme Unify(T,T,T);

// Type unification: test that #1 and #2 unify, and then return #3.
Unify(#1,#2,#3) → #3 ;

main sort E | scheme Main(E) ;
Main(#) → AddType(TE2(#)) ;

| scheme AddType(E) ;
AddType(#e↑t(#t)) → ⟦ ⟨E#e⟩ :: ⟨T#t⟩ ⟧ ;

}
