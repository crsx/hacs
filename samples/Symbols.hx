module org.crsx.hacs.tests.Symbols { //-*-hacs-*-

  token UP | [A-Z]+ ;  // upper case words are tokens
  token LO | [a-z]+ [0-9_]* ;  // lower case words with optional index
  token INT | [0-9]+ ;  // integer

  sort S | symbol ⟦⟨LO⟩⟧ ;  // symbol sort

  // Input and output is list of words.
  sort W | ⟦⟨UP⟩⟧ | ⟦⟨S⟩⟧ | ⟦*⟧ | ⟦⟨INT⟩⟧ ;
  main sort L | ⟦⟨W⟩ ⟨L⟩⟧ | ⟦⟧ ;
  
  // Main scheme!
  sort L | scheme Test(L) ; Test(#) → Emit(#) ;

  // Inherited attribute to pass map of next token counts.
  attribute ↓ups{UP : Computed} ;

  // How to initialize counters.
  sort Computed | scheme Two ; Two → ⟦2⟧ ;

  // Inherited attribute with set of seen symbols.
  attribute ↓los{S} ;

  // Helper scheme, passing counts of tokens and symbols!
  sort L | scheme Emit(L) ↓ups ↓los ;

  // Rules for tokens (not seen before and already seen).
  Emit(⟦ ⟨UP#id⟩ ⟨L#⟩ ⟧) ↓ups{¬#id}
    → ⟦ ⟨UP#id⟩ ⟨L Emit(#) ↓ups{#id : Two}⟩ ⟧ ;
  Emit(⟦ ⟨UP#id⟩ ⟨L#⟩ ⟧) ↓ups{#id : #n}
    → ⟦ ⟨UP#id⟩ ⟨INT#n⟩ ⟨L Emit(#) ↓ups{#id : ⟦ #n + 1 ⟧}⟩ ⟧ ;

  // Rule for symbols (not and already seen) - note how an exemplar symbol is used.
  Emit(⟦ s ⟨L#⟩ ⟧) ↓los{¬⟦s⟧} → ⟦ s ⟨L Emit(#) ↓los{⟦s⟧}⟩ ⟧ ;
  Emit(⟦ s ⟨L#⟩ ⟧) ↓los{⟦s⟧} → ⟦ s * ⟨L Emit(#)⟩ ⟧ ;

  // Rule to generate a random symbol.
  Emit(⟦ * ⟨L#⟩ ⟧) → ⟦ s ⟨L Emit(#)⟩ ⟧ ;

  // Rule to skip existing counts.
  Emit(⟦ ⟨INT#n⟩ ⟨L#⟩ ⟧) → Emit(#) ;

  // Rule to finish off with thrice END and a symbol.
  Emit(⟦⟧) → ⟦ END END END s s s ⟧ ;
}
