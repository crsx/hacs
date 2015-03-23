module org.crsx.hacs.samples.WordMap {

// Simple word map over sentence.
main sort Query | ⟦ ⟨Map⟩ in ⟨Sentence⟩ ⟧ ;
sort Sentence | ⟦ ⟨WORD⟩ ⟨Sentence⟩ ⟧ | ⟦ ⟧ ;
sort Map | ⟦ ⟨WORD⟩ : ⟨WORD⟩ , ⟨Map⟩ ⟧ | ⟦ ⟨WORD⟩ : ⟨WORD⟩ ⟧ ;
token WORD | [A-Za-z0-9]+ ;

// Collect word mapping.
attribute ↑m{WORD:WORD} ;
sort Map | ↑m ;
⟦ ⟨WORD#key⟩ : ⟨WORD#value⟩, ⟨Map#map ↑m{:#ms}⟩ ⟧ ↑m{:#ms} ↑m{#key:#value} ;
⟦ ⟨WORD#key⟩ : ⟨WORD#value⟩ ⟧ ↑m{#key:#value} ;

// Main "program" takes a Query and gives a Sentence.
sort Sentence | scheme Substitute(Query) ;

// Environment for mappings during Sentence processing.
attribute ↓e{WORD:WORD} ;
sort Sentence | scheme SentenceE(Sentence) ↓e ;

// The main program needs the synthesized map before it can substitute.
Substitute( ⟦ ⟨Map#map ↑m{:#ms}⟩ in ⟨Sentence#sentence⟩ ⟧ ) → SentenceE( #sentence ) ↓e{:#ms} ;

// Replace any mapped words.
SentenceE( ⟦ ⟨WORD#word⟩ ⟨Sentence#words⟩ ⟧ ↑#syn ) ↓e{#word : #replacement}
→ 
⟦ ⟨WORD#replacement⟩ ⟨Sentence SentenceE(#words)⟩ ⟧↑#syn
;

SentenceE( ⟦ ⟨WORD#word⟩ ⟨Sentence#words⟩ ⟧ ↑#syn ) ↓e{¬#word}
→ 
⟦ ⟨WORD#word⟩ ⟨Sentence SentenceE(#words)⟩ ⟧↑#syn
;

SentenceE( ⟦ ⟧ ↑#syn ) → ⟦ ⟧ ↑#syn ;
}
