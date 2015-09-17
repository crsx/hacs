module org.crsx.hacs.samples.WordMap {

// Simple word map over list.
main sort Query | ⟦ ⟨Map⟩ in ⟨List⟩ ⟧ ;
sort List | ⟦ ⟨WORD⟩ ⟨List⟩ ⟧ | ⟦ ⟧ ;
sort Map | ⟦ ⟨WORD⟩ : ⟨WORD⟩ , ⟨Map⟩ ⟧ | ⟦ ⟨WORD⟩ : ⟨WORD⟩ ⟧ ;
token WORD | [A-Za-z0-9]+ ;

// Collect word mapping.
attribute ↑m{WORD:WORD} ;
sort Map | ↑m ;
⟦ ⟨WORD#key⟩ : ⟨WORD#value⟩, ⟨Map#map ↑m{:#ms}⟩ ⟧ ↑m{:#ms} ↑m{#key:#value} ;
⟦ ⟨WORD#key⟩ : ⟨WORD#value⟩ ⟧ ↑m{#key:#value} ;

// Main program takes a Query and gives a List.
sort List | scheme Substitute(Query) ;

// Environment for mappings during List processing.
attribute ↓e{WORD:WORD} ;
sort List | scheme ListE(List) ↓e ;

// The main program needs the synthesized map before it can substitute.
Substitute( ⟦ ⟨Map#map ↑m{:#ms}⟩ in ⟨List#list⟩ ⟧ ) → ListE( #list ) ↓e{:#ms} ;

// Replace any mapped words.
ListE( ⟦ ⟨WORD#word⟩ ⟨List#words⟩ ⟧ ↑#syn ) ↓e{#word : #replacement}
→ 
⟦ ⟨WORD#replacement⟩ ⟨List ListE(#words)⟩ ⟧↑#syn
;

ListE( ⟦ ⟨WORD#word⟩ ⟨List#words⟩ ⟧ ↑#syn ) ↓e{¬#word}
→ 
⟦ ⟨WORD#word⟩ ⟨List ListE(#words)⟩ ⟧↑#syn
;

ListE( ⟦ ⟧ ↑#syn ) → ⟦ ⟧ ↑#syn ;
}
