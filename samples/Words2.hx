// SIMPLE LIST COLLECTION.

module org.crsx.hacs.samples.Words2 {

// Simple word membership query.
main sort Query | ⟦ ⟨Word⟩ in ⟨List⟩ ⟧ ;
sort List | ⟦ ⟨Word⟩, ⟨List⟩ ⟧ | ⟦ ⟨Word⟩ ⟧ ;
token Word | [A-Za-z0-9]+ ;

// Collect set of words in list.
attribute ↑z{Word} ;
sort List | ↑z ;
⟦ ⟨Word#w⟩, ⟨List#ws ↑z{:#zs}⟩ ⟧ ↑z{:#zs} ↑z{#w} ;
⟦ ⟨Word#w⟩ ⟧ ↑z{#w} ;

// We'll provide the answer in clear text.
sort Answer
| ⟦Yes, the list contains ⟨Word⟩.⟧
| ⟦No, the list does not contain ⟨Word⟩.⟧
;

// Main "program" takes a Query and gives an Answer.
sort Answer | scheme Check(Query) ;

// The main program needs the synthesized list before it can check membership.
Check( ⟦ ⟨Word#w⟩ in ⟨List#ws ↑z{#w}⟩ ⟧ ) → ⟦Yes, the list contains ⟨Word#w⟩.⟧ ;
Check( ⟦ ⟨Word#w⟩ in ⟨List#ws ↑z{¬#w}⟩ ⟧ ) → ⟦No, the list does not contain ⟨Word#w⟩.⟧ ;

}
