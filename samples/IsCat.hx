module org.crsx.hacs.samples.IsCat {

token WORD | [A-Za-z]+ ;

sort Boolean | ⟦True⟧ | ⟦False⟧ ;

sort Boolean | scheme IsCat(WORD) ;
IsCat(#word) → IsSameWord(#word, ⟦cat⟧) ;

sort Boolean | scheme IsSameWord(WORD, WORD) ;
IsSameWord(#, #) → ⟦True⟧ ;
default IsSameWord(#1, #2) → ⟦False⟧ ;

}
