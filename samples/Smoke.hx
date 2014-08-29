/* This is a SMOKE TEST for HACS. */

module "org.crsx.hacs.samples.Smoke" {

token NAME | LETTER [a-z0-9_]* ;

fragment LETTER | [a-z] ;

sort V | symbol ⟦⟨NAME⟩⟧ ;

main
sort E
| ⟦ λ ⟨V binds x⟩ . ⟨E[x as E]⟩ ⟧
| ⟦ ⟨E@1⟩ ⟨E@2⟩ ⟧@1
| ⟦ ⟨V⟩ ⟧@2
| sugar ⟦ ( ⟨E#⟩ ) ⟧@2 → E#
;

[Beta] ⟦ (λ x . ⟨E#1[x]⟩) ⟨E#2⟩ ⟧ → ⟦⟨E#1[E#2]⟩⟧ ;
[Eta]  ⟦ λ x . ⟨E#1⟩ x ⟧ → ⟦⟨E#1⟩⟧ ;

| ↑count( $Numeric )
}
