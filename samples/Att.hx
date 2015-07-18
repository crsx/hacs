module org.crsx.hacs.samples.Att { //-*-hacs-*-
  token T | Boo ;
  main sort S | ⟦⟨T⟩⟧ ;
  attribute ↓b(S);
  sort S | scheme Test2 ↓b | scheme Test3 ↓b ;
  Test2 ↓b(#) → Test3 ;
}
