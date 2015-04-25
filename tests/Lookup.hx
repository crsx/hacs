module edu.nyu.csci.cc.fall14.Lookup {
space [ \t\n];
token ID | [a-zA-Z]+;
token NUM | [0-9]+;

sort Number | ⟦⟨NUM⟩⟧;
sort Word | symbol ⟦⟨ID⟩⟧;
sort Map | ⟦⟨Word⟩:⟨Number⟩⟧;

attribute ↑s{Word : Number};

sort Map | ↑s;
⟦id : ⟨Number#n⟩⟧↑s{⟦id⟧ : #n}; 

attribute ↓e{Word : Number};

sort Number | scheme LookUp(Map, Word) ↓e;
LookUp(#M, #w) ↓e{#w: #n} → ⟦⟨Number#n⟩⟧;
LookUp(#M, #w) ↓e{¬#w} → ⟦ 0 ⟧;

/* works returns 1000*/
sort Number | scheme Works(Map);
Works(#M ↑s{:#ms}) → Extend1(#M, ⟦THIS⟧, ⟦1000⟧) ↓e{:#ms};

sort Number | scheme Extend1(Map, Word, Number) ↓e;
Extend1(#M, #w, #n) → LookUp(#M, #w) ↓e{#w:#n};


/* fails returns 0 */
sort Number | scheme Fails(Map);
Fails(#M ↑s{:#ms}) → Extend2(#M, ⟦THIS⟧, ⟦1000⟧) ↓e{:#ms};

sort Number | scheme Extend2(Map, Word, Number) ↓e;
Extend2(#M, #w, #n) → LookUp(#M, ⟦THIS⟧) ↓e{#w:#n};


}