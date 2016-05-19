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
  Emit(⟦ ⟨UP#id⟩ ⟨L#⟩ ⟧) ↓ups{:#ups}↓ups{¬#id} ↓los{:#los}
    → ⟦ ⟨UP#id⟩ ⟨L Emit(#) ↓ups{:#ups}↓ups{#id : Two} ↓los{:#los}⟩ ⟧ ;
  Emit(⟦ ⟨UP#id⟩ ⟨L#⟩ ⟧) ↓ups{:#ups}↓ups{#id : #n} ↓los{:#los}
    → ⟦ ⟨UP#id⟩ ⟨INT#n⟩ ⟨L Emit(#) ↓ups{:#ups}↓ups{#id : ⟦ #n + 1 ⟧ ↓los{:#los}}⟩ ⟧ ;

  // Rule for symbols (not and already seen) - note how an exemplar symbol is used.
  Emit(⟦ s ⟨L#⟩ ⟧) ↓ups{:#ups}↓los{:#los}↓los{¬⟦s⟧} → ⟦ s ⟨L Emit(#) ↓ups{:#ups}↓los{:#los}↓los{⟦s⟧}⟩ ⟧ ;
  Emit(⟦ s ⟨L#⟩ ⟧) ↓ups{:#ups}↓los{:#los}↓los{⟦s⟧} → ⟦ s * ⟨L Emit(#) ↓ups{:#ups}↓los{:#los}⟩ ⟧ ;

  // Rule to generate a random symbol.
  Emit(⟦ * ⟨L#⟩ ⟧) ↓ups{:#ups}↓los{:#los} → ⟦ s ⟨L Emit(#)↓ups{:#ups}↓los{:#los}⟩ ⟧ ;

  // Rule to skip existing counts.
  Emit(⟦ ⟨INT#n⟩ ⟨L#⟩ ⟧) ↓ups{:#ups}↓los{:#los} → Emit(#) ↓ups{:#ups}↓los{:#los} ;

  // Rule to finish off with thrice END and a symbol.
  Emit(⟦⟧) → ⟦ END END END s s s ⟧ ;
}
