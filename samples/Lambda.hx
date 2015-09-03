module org.crsx.hacs.samples.Lambda {
  space [ \t\n] ;
  token ID | [a-z] [_0-9]* ;

  main sort T
  | ⟦λ ⟨ID binds x⟩ . ⟨T[x as T]⟩⟧		    // abstraction
  | scheme ⟦⟨T@1⟩ ⟨T@2⟩⟧@1			// application
  | symbol ⟦⟨ID⟩⟧@2				       // variable occurrence
  | sugar ⟦(⟨T#⟩)⟧@2 →  # ;

  ⟦(λx.⟨T#1[x]⟩) ⟨T#2⟩⟧ →  #1[T#2] ;
}
