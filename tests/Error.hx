module org.crsx.hacs.tests.Error {
  token WORD | [A-Za-z.!?]+ ;
  main sort Word | ⟦⟨WORD⟩⟧ ;
  | scheme Test(Word) ;
  Test(⟦ ⟨WORD#w⟩ ⟧) → Test2(#w, ⟦a⟧);
  | scheme Test2(WORD, WORD);
  Test2(#w, #w) → error⟦Bad.⟧;
 default Test2(#w1, #w2) → error⟦Bad and not a.⟧;
}
