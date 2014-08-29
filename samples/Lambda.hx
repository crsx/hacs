module org.crsx.hacs.samples.Lambda {

token NAME | [a-z] [a-z0-9_]* ;

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

}
