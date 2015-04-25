module edu.nyu.cc.pr2.Sym {
  token ID | [a-zA-Z] [0-9a-zA-Z_]* ;
  sort Name | symbol ⟦⟨ID⟩⟧ ; 
  main sort Top | ⟦ ⟨Name⟩ ⟧ | ⟦.⟧ ;
 
  attribute ↑n(Name);
  sort Top | ↑n;

  sort Name | scheme Get(Top);
  Get(#top ↑n(#n)) → #n ;

  sort Top;
  [global z, global xx] ⟦z⟧ ↑n(⟦xx⟧) ;
  [global Name⟦Foobar⟧] ⟦ . ⟧ ↑n(⟦Foobar⟧) ;
  default ⟦ x ⟧ ↑n(⟦x⟧) ;
}
