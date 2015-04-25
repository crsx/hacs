module org.crsx.hacs.tests.Comp {
space [ \t\n];
token NUM | [0-9]+;

sort Number | ⟦⟨NUM⟩⟧;

sort Computed ;
| scheme Increment(Number) ;
Increment(⟦ ⟨NUM#n⟩ ⟧) → ⟦$#n+1⟧ ;

}