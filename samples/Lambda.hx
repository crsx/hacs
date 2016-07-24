module org.crsx.hacs.samples.Lambda {

  token ID | [a-z] [_0-9]* ;

  main sort T
  | ⟦λ ⟨ID binds x⟩ . ⟨T[x as T]⟩⟧		   // abstraction is data
  | scheme ⟦⟨T@1⟩ ⟨T@2⟩⟧@1			// application is executable
  | sugar ⟦(⟨T#⟩)⟧@2 →  # ;

  ⟦(λ x . ⟨T#1[T⟦x⟧]⟩) ⟨T#2⟩⟧ →  #1[T#2] ;
}
