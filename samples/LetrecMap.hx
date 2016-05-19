module org.crsx.hacs.samples.LetrecMap {
  // Syntax.
  token ID | [a-z][a-z0-9_]* ;
  sort B | ⟦ ⟨ID⟩ : ⟨ID⟩ ⟨B⟩ ⟧ | ⟦⟧ ;
  main sort P | ⟦ ⟨B⟩ in ⟨ID⟩ ⟧ ;
  sort Out | ⟦⟨ID⟩⟧;

  // Synthesize environment.
  attribute ↑b{ID:ID} ;
  sort B | ↑b ;
  ⟦ ⟨ID#v1⟩ : ⟨ID#v2⟩ ⟨B#B ↑b{:#b}⟩ ⟧ ↑b{:#b} ↑b{#v1 : #v2} ;
  ⟦ ⟧ ↑b{} ;

  // Environment and application on variable.
  attribute ↓e{ID:ID} ;
  sort Out | scheme Apply(ID) ↓e ;
  Apply(#v) ↓e{:#e}↓e{#v : #v2}	→  Apply(#v2) ↓e{:#e};
  Apply(#v)  ↓e{¬#v}	→  ⟦ ⟨ID#v⟩ ⟧ ;

  // Main makes sure list is synthesized and passes control to conversion.
  sort Out | scheme Reduce(P) ;
  Reduce(⟦ ⟨B#B ↑b{:#b}⟩ in ⟨ID#v⟩ ⟧) → Apply(#v) ↓e{:#b} ;
}
