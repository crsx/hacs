module org.crsx.hacs.samples.SZ { //-*-hacs-*-

  // Input syntax.
  token ID | [a-z]+ [0-9]* ;
  main sort Exp
    | ⟦ ⟨Exp@1⟩ : ⟨Exp@2⟩ ⟧@1
    | ⟦ ⟨Exp@2⟩ + ⟨Exp@3⟩ ⟧@2
    | ⟦ ⟨ID⟩ ⟧@3
    | ⟦ 0 ⟧@3
    | ⟦ s ⟨Exp@3⟩ ⟧@3
    | sugar ⟦ (⟨Exp#⟩) ⟧@3  →  #
    ;
	 
  // Semantic Values.
  sort Value | Pair(Value, Value) | Plus(Value, Value) | Ref(ID) | Zero | Succ(Value) ;

  // Semantic Operations 
  | scheme Add(Value, Value) ;
  Add(Ref(#id), #2) →    Plus(Ref(#id), #2) ;
  Add(Zero, #2) →   #2 ;
  Add(Succ(#1), #2) →    Succ(Add(#1, #2)) ;
  Add(Pair(#11, #12), Pair(#21, #22)) →    Pair(Add(#11, #21), Add(#12, #22)) ;
  Add(Plus(#11, #12), #2) →    Plus(#11, Add(#11, #2)) ;
 
  // Loading input into internal form.
  | scheme Load(Exp) ;
  Load(⟦ ⟨Exp#1⟩ : ⟨Exp#2⟩ ⟧) →    Pair(Load(#1), Load(#2)) ;
  Load(⟦ ⟨Exp#1⟩ + ⟨Exp#2⟩ ⟧) →    Add(Load(#1), Load(#2)) ;
  Load(⟦ s ⟨Exp#⟩ ⟧) →  Succ(Load(#)) ;
  Load(⟦ 0 ⟧) → Zero ;
  Load(⟦ ⟨ID#id⟩ ⟧) →  Ref(#id) ;

  // External translation.
  sort Exp | scheme Calc(Exp) ;
  Calc(#) → Unload(Load(#)) ;
  | scheme Unload(Value) ;
  Unload(Zero) →  ⟦ 0 ⟧ ;
  Unload(Succ(#)) →  ⟦ s ⟨Exp Unload(#)⟩ ⟧ ;
  Unload(Plus(#1, #2)) →  ⟦ ⟨Exp Unload(#1)⟩ + ⟨Exp Unload(#2)⟩ ⟧ ;
  Unload(Pair(#1, #2)) →  ⟦ ⟨Exp Unload(#1)⟩ : ⟨Exp Unload(#2)⟩ ⟧ ;
  Unload(Ref(#)) →  ⟦ ⟨ID#⟩ ⟧ ;
  Unload(Succ(#)) →  ⟦ s ⟨Exp Unload(#)⟩ ⟧ ;
}
