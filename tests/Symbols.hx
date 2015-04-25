module org.crsx.hacs.tests.Symbols { //-*-hacs-*-

  // Upper case words are tokens.
  token UP | [A-Z]+ ;

  // Symbol sort based on a (lower case) token (with required index).
  token LO | [a-z]+ [0-9_]* ;
  sort S | symbol ⟦⟨LO⟩⟧ ;

  // Integers and Counts.
  token INT | [0-9]+ ;
  
  // A word of the input or output.
  sort W
    | ⟦⟨UP⟩⟧	// literal token
    | ⟦⟨S⟩⟧		// specific symbol
    | ⟦*⟧		// random symbol
    | ⟦⟨INT⟩⟧	// count
    ;

  // Input and output is list of words.
  main sort L | ⟦⟨W⟩ ⟨L⟩⟧ | ⟦⟧ ;
  
  // Main scheme!
  sort L | scheme Test(L) ;
  Test(#) → Emit(#) ;

  // Inherited attribute to pass token counts.
  attribute ↓ups{UP : Computed} ;

  // How to initialie counters.
  sort Computed | scheme Two ; Two → ⟦2⟧ ;

  // Inerited attribute with symbol membership.
  attribute ↓syms{S} ;

  // Helper scheme, passing counts of tokens and symbols!
  sort L | scheme Emit(L) ↓ups ↓syms ;

  // Rule for tokens not seen before.
  Emit(⟦ ⟨UP#id⟩ ⟨L#⟩ ⟧) ↓ups{¬#id} → ⟦ ⟨UP#id⟩ ⟨L Emit(#) ↓ups{#id : Two}⟩ ⟧ ;

  // Rule for tokens already seen - add count!
  Emit(⟦ ⟨UP#id⟩ ⟨L#⟩ ⟧) ↓ups{#id : #n} → ⟦ ⟨UP#id⟩ ⟨INT#n⟩ ⟨L Emit(#) ↓ups{#id : ⟦ #n + 1 ⟧}⟩ ⟧ ;

  // Rule for symbols not seen before - note how an exemplar symbol is used.
  Emit(⟦ s ⟨L#⟩ ⟧) ↓syms{¬⟦s⟧} → ⟦ s ⟨L Emit(#) ↓syms{⟦s⟧}⟩ ⟧ ;

  // Rule for symbols already seen - add *!
  Emit(⟦ s ⟨L#⟩ ⟧) ↓syms{⟦s⟧} → ⟦ s * ⟨L Emit(#)⟩ ⟧ ;

  // Rule to generate a random symbol.
  Emit(⟦ * ⟨L#⟩ ⟧) → ⟦ s ⟨L Emit(#)⟩ ⟧ ;

  // Rule to skip existing counts.
  Emit(⟦ ⟨INT#n⟩ ⟨L#⟩ ⟧) → Emit(#) ;

  // Rule to finish off with thrice END and a symbol.
  Emit(⟦⟧) → ⟦ END END END s s s ⟧ ;

/*
  Try to run as follows:
  $ ./Symbols.run --scheme=Test --term="A A a a * A * a"

  You get:
  A A 2 a a * s A 3 s_39 a * END END END s_46 s_46 s_46 
  Notice:
  - input tokens and symbols passed through(A, a),
  - repeated input tokens followed by count (A 2, A 3),
  - repeated input symbols followed by star (a *),
  - rule symbols generated fresh for each replacement (s ≠ s_30 ≠ s_46),
  - generated symbols consistent within each replacement (s_46).
*/
}
