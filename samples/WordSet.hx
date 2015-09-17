module org.crsx.hacs.samples.WordSet {

// Simple word membership query.
main sort Query | ⟦ ⟨WORD⟩ in ⟨List⟩ ⟧ ;
sort List | ⟦ ⟨WORD⟩, ⟨List⟩ ⟧ | ⟦ ⟨WORD⟩ ⟧ ;
token WORD | [A-Za-z0-9]+ ;

// Collect set of words.
attribute ↑z{WORD} ;
sort List | ↑z ;
⟦ ⟨WORD#w⟩, ⟨List#rest ↑z{:#ws}⟩ ⟧ ↑z{:#ws} ↑z{#w} ;
⟦ ⟨WORD#w⟩ ⟧ ↑z{#w} ;

// We'll provide the answer in clear text.
sort Answer
| ⟦Yes, the list contains ⟨WORD⟩.⟧
| ⟦No, the list does not contain ⟨WORD⟩.⟧
;

// Check is main query scheme, which gives an Answer.
sort Answer | scheme Check(Query) ;

// The main program needs the synthesized list before it can check membership.
Check( ⟦ ⟨WORD#w⟩ in ⟨List#rest ↑z{#w}⟩ ⟧ ) → ⟦Yes, the list contains ⟨WORD#w⟩.⟧ ;
Check( ⟦ ⟨WORD#w⟩ in ⟨List#rest ↑z{¬#w}⟩ ⟧ )
   → ⟦No, the list does not contain ⟨WORD#w⟩.⟧ ;
}
