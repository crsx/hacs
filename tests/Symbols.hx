module org.crsx.hacs.tests.Symbols { //-*-hacs-*-

  // Usual tokens.
  token ID | [A-Za-z0-9_]+ ;

  // Symbol sort based on a token.
  sort S | symbol ⟦⟨ID⟩⟧ ;

  // A word of the input or output.
  sort W
    | ⟦⟨ID⟩⟧	// literal token
    | ⟦?⟨S⟩⟧	// specific symbol
    | ⟦*⟧		// random symbol
    ;

  // Input and output is list of words.
  main sort L | ⟦⟨W⟩ ⟨L⟩⟧ | ⟦⟧ ;

  // Main scheme, passing list of tokens and symbols!
  sort L | scheme Test(L) ;

  // Rule for tokens.
  Test(⟦ ⟨ID#id⟩ ⟨L#⟩⟧) → ⟦ ⟨ID#id⟩ ⟨L Test(#)⟩⟧ ;

  // Rule for symbols.
  Test(⟦ ?s ⟨L#⟩⟧) → ⟦ ?s ⟨L Test(#)⟩⟧ ;

  // Rule to generate a random symbol!
  Test(⟦ * ⟨L#⟩⟧) → ⟦ ?s ⟨L Test(#)⟩⟧ ;

  // Rule to finish off with thrice End and a symbol.
  Test(⟦⟧) → ⟦ End End End ?s ?s ?s ⟧ ;

/*
  Try to run as follows:
  $ ./Symbols.run --scheme=Test --term="A A * * ?a ?a"

  You get:
  A A ?s ?s_59 ?a ?a End End End ?s_51 ?s_51 ?s_51 
  Notice:
  - input tokens and symbols passed through(A, a),
  - rule symbols generated fresh for each replacement (s, s_59),
  - generated symbols consistent within each replacement (s_51).
*/
}

  
