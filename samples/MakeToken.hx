module org.crsx.hacs.tests.MakeToken {
  // Input grammar.
  token WORD | [A-Za-z.!?_]+ ;
  sort Word | ⟦⟨WORD⟩⟧ ;
  main sort Words | ⟦⟨Word⟩ ⟨Words⟩⟧ | ⟦⟧;

  // Main scheme: concatenate words but replace repetitions with "x".
  sort Word | scheme Test(Words) ;
  Test(#ws) → Test2(#ws, ⟦X⟧);

  // Map encountered words to "x".
  attribute ↓dup{WORD : WORD};

  // The aggregator.
  sort Word | scheme Test2(Words, Word) ↓dup ;
  
  Test2(⟦ ⟨WORD#w1⟩ ⟨Words#ws⟩ ⟧, ⟦⟨WORD#w⟩⟧) ↓dup{:#dup}↓dup{¬#w1}
  → Test2(#ws, ⟦⟨WORD Concat(#w, #w1)⟩⟧) ↓dup{:#dup}↓dup{#w1 : ⟦x⟧} ;
  
  Test2(⟦ ⟨WORD#w1⟩ ⟨Words#ws⟩ ⟧, ⟦⟨WORD#w⟩⟧) ↓dup{:#dup}↓dup{#w1 : #w2}
  → Test2(#ws, ⟦⟨WORD Concat(#w, #w2)⟩⟧) ↓dup{:#dup} ;
  
  Test2(⟦ ⟧, #w) →  #w ;

  // Helper to concatenate two words.
  sort Computed | scheme Concat(WORD, WORD) ;
  Concat(#w1, #w2) → ⟦ #w1 @ "_" @ #w2 ⟧ ;
}
