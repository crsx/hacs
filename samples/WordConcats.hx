// SELECT JUST WORDS THAT CONCATENATE PREVIOUS PAIRS.

module org.crsx.hacs.samples.WordConcats {

  // Words.
  main sort Words | ⟦ ⟨WORD⟩ ⟨Words⟩ ⟧ | ⟦⟧ ;
  token WORD | [A-Za-z]+ ;

  // Main scheme.
  sort Words | scheme Process(Words) ;
  Process(#S) → Filter1(#S) ↓last(⟦xyzzy⟧) ;

  // State.
  attribute ↓pairs{WORD};  // set of previous word pairs
  attribute ↓last(WORD);  // last seen word

  // 1. Echo only words that are the same as previous pairs.
  sort Words | scheme Filter1(Words) ↓pairs ↓last ;
  Filter1(⟦ ⟨WORD#w⟩ ⟨Words#ws⟩ ⟧) ↓pairs{#w} → ⟦ ⟨WORD#w⟩ ⟨Words Filter2(#w, #ws)⟩ ⟧ ;
  Filter1(⟦ ⟨WORD#w⟩ ⟨Words#ws⟩ ⟧) ↓pairs{¬#w} → Filter2(#w, #ws) ;
  Filter1(⟦⟧) → ⟦⟧ ;

  // 2. Compute concatenated pair and update last.
  | scheme Filter2(WORD, Words) ↓pairs ↓last ;
  Filter2(#w, #ws) ↓last(#last) → Filter3(⟦ #last @ #w ⟧, #ws) ↓last(#w) ;

  // 3. Dummy to trigger pair computing then pass it to next stage.
  | scheme Filter3(Computed, Words) ↓pairs ↓last ;
  Filter3(#pair, #ws) → Filter4(#pair, #ws) ;

  // 4. Repeat with updated list of pairs. Forced as data before insertion.
  | scheme Filter4(WORD, Words) ↓pairs ↓last ;
  [data #pair] Filter4(#pair, #ws) → Filter1(#ws) ↓pairs{#pair} ;

  // Dummy scheme that returns Computed (needed to triggger loading of feature).
  sort Computed | scheme Zero;  Zero → ⟦0⟧ ;
}
