module org.crsx.hacs.samples.WordSubst {

// Spacing rules.
space [\ \t\n\r] ;

// Tokens.
token ID | [A-Za-z]+ ;
token NAT | [0-9]+ ;

// Grammar.
sort Units | ⟦ ⟨Unit⟩ ⟨Units⟩ ⟧ | ⟦⟧ ;
sort Unit | ⟦⟨Variable⟩=⟨NAT⟩⟧ | ⟦⟨Variable⟩⟧ | ⟦⟨NAT⟩⟧ | ⟦ { ⟨Units⟩ } ⟧ ;
sort Variable | symbol ⟦⟨ID⟩⟧ ;

// Helper Subst structure: lists of variable and NAT pairs.
sort Subst | MoreSubst(Variable, NAT, Subst) | NoSubst ;

// Append operation for Subst structures.
| scheme SubstAppend(Subst, Subst) ;
SubstAppend(MoreSubst(#variable, #nat, #subst1), #subst2) → MoreSubst(#variable, #nat, SubstAppend(#subst1, #subst2)) ;
SubstAppend(NoSubst, #subst2) → #subst2 ;

// Attributes.
attribute ↑subst(Subst) ;        // collected Subst structure
attribute ↓env{Variable:NAT} ;   // mappings to apply

// Top scheme.
main sort Units | scheme Run(Units) ;
Run(#units) → Run1(#units, #subst) ;

// Strategy: two passes.
// 1. force synthesis of subst attribute.
// 2. convert subst attribute to inherited environment (which forces replacement).

| scheme Run1(Units) ;
Run1(#units ↑subst(#subst)) → Run2(#units, #subst) ;

| scheme Run2(Units, Subst) ↓env ;
Run2(#units, MoreSubst(#variable, #nat, #subst)) → Run2(#units, #subst) ↓env{#variable : #nat} ;
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

// Inheritance of env.

sort Units | scheme Unitsenv(Units) ↓env ;
Unitsenv( ⟦ ⟨Unit#1⟩ ⟨Units#2⟩ ⟧ →  ⟦ ⟨Unit Unitenv(#1)⟩ ⟨Units Unitsenv(#2)⟩ ⟧ ;
Unitsenv( ⟦ ⟧ ) → ⟦ ⟧ ;

sort Unit | scheme Unitenv(Unit) ↓env ;
Unitenv( ⟦v=⟨NAT#n⟩⟧ ) → ⟦v=⟨NAT#n⟩⟧ ;
Unitenv( ⟦v⟧ ) ↓env{⟦v⟧:#n} → ⟦⟨NAT#n⟩⟧ ;
Unitenv( ⟦v⟧ ) ↓env{¬⟦v⟧} → ⟦v⟧ ;
Unitenv( ⟦⟨NAT#n⟩⟧ ) → ⟦⟨NAT#n⟩⟧ ;
Unitenv( ⟦ { ⟨Units#units⟩ } ⟧ ) → ⟦ { ⟨Units Unitsenv(#units)⟩ } ⟧ ;

}
