module org.crsx.hacs.samples.LetrecMap {
  // Syntax.
  token ID | [a-z][a-z0-9_]* ;
  sort V | symbol ⟦⟨ID⟩⟧ ;
  sort B | ⟦ ⟨V⟩ : ⟨V⟩ ⟨B⟩ ⟧ | ⟦⟧ ;
  main sort P | ⟦ ⟨B⟩ in ⟨V⟩ ⟧ ;

  // Synthesize environment.
  attribute ↑b{V:V} ;
  sort B | ↑b ;
  ⟦ v1 : v2 ⟨B#B ↑b{:#b}⟩ ⟧ ↑b{:#b} ↑b{⟦v1⟧ : ⟦v2⟧} ;
  ⟦ ⟧ ↑b{} ;

  // Environment and application on variable.
  attribute ↓e{V:V} ;
  sort V | scheme Apply(V) ↓e ;
  Apply(⟦v⟧)  ↓e{⟦v⟧ : ⟦v2⟧}	→  Apply(⟦v2⟧) ;
  Apply(⟦v⟧)  ↓e{¬⟦v⟧}	→  ⟦v⟧ ;

  // Main makes sure list is synthesized and passes control to conversion.
  sort V | scheme Reduce(P) ;
  Reduce(⟦ ⟨B#B ↑b{:#b}⟩ in v ⟧) → Apply(⟦v⟧) ↓e{:#b} ;
}
