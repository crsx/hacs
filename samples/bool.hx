module "org.crsx.hacs.samples.Bool" {

// Boolean sort.
start sort B
| ⟦ t ⟧@4 | ⟦ f ⟧@4                 // constants
| sugar ⟦ ( ⟨B#⟩ ) ⟧@4 → ⟦⟨B#⟩⟧    // parenthesis
;

// Disjunction.
| scheme ⟦ ⟨B@2⟩ ∨ ⟨B@1⟩ ⟧@1 ;
⟦t∨⟨B#⟩⟧ → ⟦t⟧ ;
⟦f∨⟨B#⟩⟧ → B# ;

// Conjunction.
| scheme ⟦ ⟨B@3⟩ ∧ ⟨B@2⟩ ⟧@2 ;
⟦t∧⟨B#⟩⟧ → B# ;
⟦f∧⟨B#⟩⟧ → ⟦f⟧ ;

// Negation.
| scheme ⟦ ¬⟨B@3⟩ ⟧@3 ;
⟦¬t⟧ → ⟦f⟧ ;
⟦¬f⟧ → ⟦t⟧ ;

}
