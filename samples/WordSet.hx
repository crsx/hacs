module org.crsx.hacs.samples.WordSet {

// Simple word membership query.
main sort Query | ⟦ ⟨WORD⟩ in ⟨Sentence⟩ ⟧ ;
sort Sentence | ⟦ ⟨WORD⟩ ⟨Sentence⟩ ⟧ | ⟦ ⟨WORD⟩ ⟧ ;
token WORD | [A-Za-z0-9]+ ;

// Collect set of words in sentence.
attribute ↑z{WORD} ;
sort Sentence | ↑z ;
⟦ ⟨WORD#w⟩ ⟨Sentence#ws ↑z{:#zs}⟩ ⟧ ↑z{:#zs} ↑z{#w} ;
⟦ ⟨WORD#w⟩ ⟧ ↑z{#w} ;

// We'll provide the answer in clear text.
sort Answer
| ⟦Yes, the sentence contains ⟨WORD⟩.⟧
| ⟦No, the sentence does not contain ⟨WORD⟩.⟧
;

// Main "program" takes a Query and gives an Answer.
sort Answer | scheme Check(Query) ;

// The main program needs the synthesized sentence before it can check membership.
Check( ⟦ ⟨WORD#w⟩ in ⟨Sentence#ws ↑z{#w}⟩ ⟧ ) → ⟦Yes, the sentence contains ⟨WORD#w⟩.⟧ ;
Check( ⟦ ⟨WORD#w⟩ in ⟨Sentence#ws ↑z{¬#w}⟩ ⟧ ) → ⟦No, the sentence does not contain ⟨WORD#w⟩.⟧ ;

}
