module edu.nyu.csci.cc.fall14.SchemeFails {

  sort Prog  | ⟦ ⟨OneorTwo⟩ ⟧;
  sort OneorTwo  | ⟦ ⟨Word⟩ ⟧@1 | ⟦ ⟨OneorTwo@1⟩, ⟨Word⟩ ⟧;
  token Word | [a-zA-Z]+;


  sort Prog | scheme Fail(Prog);
  Fail(⟦⟨OneorTwo#⟩⟧) → ⟦⟨OneorTwo#⟩⟧;


}
