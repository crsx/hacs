// SIMPLE WORD LISTS.

module org.crsx.hacs.samples.Words {

// Simple word membership query.
main sort Query | ⟦ ⟨WORD⟩ in ⟨List⟩ ⟧ ;
sort List | ⟦ ⟨WORD⟩, ⟨List⟩ ⟧ | ⟦ ⟨WORD⟩ ⟧ ;
token WORD | [A-Za-z0-9]+ ;

// Helper 'list' data structure sort to collect words.
sort Words | MoreWords(WORD, Words) | NoWords;

// Synthesize helper list that collects all the words in the list.
attribute ↑z(Words) ;
sort List | ↑z ;
⟦ ⟨WORD#w⟩, ⟨List#ws ↑z(#zs)⟩ ⟧ ↑z(MoreWords(#w, #zs)) ;
⟦ ⟨WORD#w⟩ ⟧ ↑z(MoreWords(#w, NoWords)) ;

// We'll provide the answer in clear text.
sort Answer
| ⟦Yes, the list contains ⟨WORD⟩.⟧
| ⟦No, the list does not contain ⟨WORD⟩.⟧
;

// Helper scheme to check if a word is in a (helper) list.
sort Answer | scheme CheckMember(WORD, Words) ;

// If the word and the first member of the list are the same, then we succeed!
CheckMember(#w, MoreWords(#w, #zs)) → ⟦Yes, the list contains ⟨WORD#w⟩.⟧ ;

// If the word was not the same, fall back to a default recursive case.
default CheckMember(#w, MoreWords(#z, #zs)) → CheckMember(#w, #zs) ;

// Once there is no more to search, then we failed...
CheckMember(#w, NoWords) → ⟦No, the list does not contain ⟨WORD#w⟩.⟧ ;

// Main program takes a Query and gives an Answer.
sort Answer | scheme Check(Query) ;

// The main program forces the synthesized list before it can check membership.
Check( ⟦ ⟨WORD#w⟩ in ⟨List#ws ↑z(#zs)⟩ ⟧ ) → CheckMember(#w, #zs) ;

}
