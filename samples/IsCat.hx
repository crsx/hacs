module org.crsx.hacs.samples.IsCat {

token WORD | [A-Za-z]+ ;
main sort Word | ⟦⟨WORD⟩⟧ ;
main sort Var | symbol ⟦⟨WORD⟩⟧ ;

sort Boolean | ⟦True⟧ | ⟦False⟧ ;

sort Boolean | scheme IsCat(Word) ;
IsCat(#word) →  IsSameWord(#word, ⟦cat⟧) ;

sort Boolean | scheme IsSameWord(Word, Word) ;
IsSameWord(#, #) →  ⟦True⟧ ;
default IsSameWord(#1, #2) →  ⟦False⟧ ;
}
