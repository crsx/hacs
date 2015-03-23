// SIMPLE WORD SENTENCES.

module org.crsx.hacs.samples.Words {

// Simple word membership query.
main sort Query | ⟦ ⟨WORD⟩ in ⟨Sentence⟩ ⟧ ;
sort Sentence | ⟦ ⟨WORD⟩ ⟨Sentence⟩ ⟧ | ⟦ ⟨WORD⟩ ⟧ ;
token WORD | [A-Za-z0-9]+ ;

// Helper 'sentence' data structure sort to collect words.
sort Words | MoreWords(WORD, Words) | NoWords;

// Synthesize helper sentence that collects all the words in the sentence.
attribute ↑z(Words) ;
sort Sentence | ↑z ;
⟦ ⟨WORD#w⟩ ⟨Sentence#ws ↑z(#zs)⟩ ⟧ ↑z(MoreWords(#w, #zs)) ;
⟦ ⟨WORD#w⟩ ⟧ ↑z(MoreWords(#w, NoWords)) ;

// We'll provide the answer in clear text.
sort Answer
| ⟦Yes, the sentence contains ⟨WORD⟩.⟧
| ⟦No, the sentence does not contain ⟨WORD⟩.⟧
;

// Helper scheme to check if a word is in a (helper) sentence.
sort Answer | scheme CheckMember(WORD, Words) ;

// If the word and the first member of the sentence are the same, then we succeed!
CheckMember(#w, MoreWords(#w, #zs)) → ⟦Yes, the sentence contains ⟨WORD#w⟩.⟧ ;

// If the word was not the same, fall back to a default recursive case.
default CheckMember(#w, MoreWords(#z, #zs)) → CheckMember(#w, #zs) ;

// Once there is no more to search, then we failed...
CheckMember(#w, NoWords) → ⟦No, the sentence does not contain ⟨WORD#w⟩.⟧ ;

// Main program takes a Query and gives an Answer.
sort Answer | scheme Check(Query) ;

// The main program forces the synthesized sentence before it can check membership.
Check( ⟦ ⟨WORD#w⟩ in ⟨Sentence#ws ↑z(#zs)⟩ ⟧ ) → CheckMember(#w, #zs) ;

}
