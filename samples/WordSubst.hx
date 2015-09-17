module org.crsx.hacs.samples.WordSubst {

// Grammar.
sort Units | ⟦ ⟨Unit⟩ ⟨Units⟩ ⟧ | ⟦⟧ ;
sort Unit | ⟦⟨Variable⟩=⟨NAT⟩⟧ | ⟦⟨Variable⟩⟧ | ⟦⟨NAT⟩⟧ | ⟦ { ⟨Units⟩ } ⟧ ;
sort Variable | symbol ⟦⟨ID⟩⟧ ;

token ID | [A-Za-z]+ ;
token NAT | [0-9]+ ;
space [\ \t\n\r] ;

// Helper Subst structure: lists of variable-NAT pairs.
sort Subst | MoreSubst(Variable, NAT, Subst) | NoSubst ;

// Append operation for Subst structures.
| scheme SubstAppend(Subst, Subst) ;
SubstAppend(MoreSubst(#var, #nat, #subst1), #subst2) → MoreSubst(#var, #nat, SubstAppend(#subst1, #subst2)) ;
SubstAppend(NoSubst, #subst2) → #subst2 ;

// Attributes.
attribute ↑subst(Subst) ;        // collected Subst structure
attribute ↓env{Variable:NAT} ;   // mappings to apply

// Top scheme.
main sort Units | scheme Run(Units) ;
Run(#units) → Run1(#units) ;

// Strategy: two passes.
// 1. force synthesis of subst attribute.
// 2. convert subst attribute to inherited environment (which forces replacement).

| scheme Run1(Units) ;
Run1(#units ↑subst(#subst)) → Run2(#units, #subst) ;

| scheme Run2(Units, Subst) ↓env ;
Run2(#units, MoreSubst(#var, #nat, #subst)) → Run2(#units, #subst) ↓env{#var : #nat} ;
Run2(#units, NoSubst) → Unitsenv(#units) ;

// Synthesis of subst.

sort Units | ↑subst ;
⟦ ⟨Unit #1 ↑subst(#subst1) ⟩ ⟨Units #2 ↑subst(#subst2)⟩ ⟧ ↑subst(SubstAppend(#subst1, #subst2)) ;
⟦ ⟧ ↑subst(NoSubst) ;

sort Unit | ↑subst ;
⟦v=⟨NAT#n⟩⟧ ↑subst(MoreSubst(⟦v⟧, #n, NoSubst)) ;
⟦v⟧ ↑subst(NoSubst) ;
⟦⟨NAT#n⟩⟧ ↑subst(NoSubst) ;
⟦ { ⟨Units#units ↑subst(#subst)⟩ } ⟧ ↑subst(#subst) ;

// Inheritance of env combined with substitution.

sort Units | scheme Unitsenv(Units) ↓env ;
Unitsenv( ⟦ ⟨Unit#1⟩ ⟨Units#2⟩ ⟧↑#s ) →  ⟦ ⟨Unit Unitenv(#1)⟩ ⟨Units Unitsenv(#2)⟩ ⟧↑#s ;
Unitsenv( ⟦ ⟧↑#s ) → ⟦ ⟧↑#s ;

sort Unit | scheme Unitenv(Unit) ↓env ;
Unitenv( ⟦v=⟨NAT#n⟩ ⟧↑#s) → ⟦v=⟨NAT#n⟩⟧↑#s ;
Unitenv( ⟦v⟧ ) ↓env{⟦v⟧:#n} → ⟦⟨NAT#n⟩⟧ ;
Unitenv( ⟦v⟧↑#s ) ↓env{¬⟦v⟧} → ⟦v⟧↑#s ;
Unitenv( ⟦⟨NAT#n⟩⟧↑#s ) → ⟦⟨NAT#n⟩⟧↑#s ;
Unitenv( ⟦ { ⟨Units#units⟩ } ⟧↑#s ) → ⟦ { ⟨Units Unitsenv(#units)⟩ } ⟧↑#s ;
}
