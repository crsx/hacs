module org.crsx.hacs.samples.IfCat {

sort Name | ⟦⟨ID⟩⟧ ;

token ID | [A-Za-z0-9]+ ;

sort Boolean | ⟦True⟧ | ⟦False⟧;

sort Boolean | scheme IsCat(Name);
IsCat(#name) → IsCatHelper(#name, ⟦cat⟧);

sort Boolean | scheme IsCatHelper(Name, Name);
IsCatHelper(#,#) → ⟦True⟧;
default IsCatHelper(#1, #2) → ⟦False⟧;

}
