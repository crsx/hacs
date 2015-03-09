module org.crsx.hacs.samples.Deriv {

//// LEXICAL.
  
token VAR | [a-z] [A-Za-z0-9]* ;  
token INT | [0-9]+ ;
 
//// SYNTAX.

// Arithmetic and basic functions.

sort Exp | ⟦ ⟨Exp@1⟩ + ⟨Exp@2⟩ ⟧@1
         | ⟦ ⟨Exp@1⟩ - ⟨Exp@2⟩ ⟧@1
         | ⟦ ⟨Exp@2⟩ * ⟨Exp@3⟩ ⟧@2
         | ⟦ ⟨Exp@2⟩ / ⟨Exp@3⟩ ⟧@2
         | ⟦ ⟨Fun⟩ ⟨Exp@4⟩ ⟧@3
         | ⟦ ⟨INT⟩ ⟧@4
         | ⟦ ⟨Var⟩ ⟧@4

         | sugar ⟦ ( ⟨Exp#⟩ ) ⟧@4 → Exp#
  //         | sugar ⟦ + ⟨Exp#1@2⟩ ⟧@1 → ⟦ 0 + ⟨Exp#1⟩ ⟧ 
  //         | sugar ⟦ - ⟨Exp#1@2⟩ ⟧@1 → ⟦ 0 - ⟨Exp#1⟩ ⟧
         ;

// Functions. 
sort Fun | ⟦sin⟧@2 | ⟦cos⟧@2 | ⟦ln⟧@2 | ⟦exp⟧@2
	| ⟦ [ ⟨Var binds x⟩ ↦ ⟨Exp[x as Exp]⟩ ] ⟧@2 ;

sort Var | symbol ⟦⟨VAR⟩⟧ ;

//// SCHEMES.

sort Fun | scheme ⟦d⟨Fun@1⟩⟧@1 ;

⟦d sin⟧ → ⟦cos⟧ ;
⟦d cos⟧ → ⟦[a ↦ 0 - sin a]⟧ ;
⟦d ln⟧  → ⟦[z ↦ 1/z]⟧ ;
⟦d exp⟧ → ⟦exp⟧ ;

⟦d[x ↦ ⟨Exp#1[x]⟩]⟧ → ⟦[y ↦ D(y)[z↦⟨Exp#1[z]⟩]]⟧ ;

sort Exp | scheme ⟦ D ⟨Exp⟩ [⟨Var binds x⟩↦⟨Exp[x as Exp]⟩] ⟧@3 ;

⟦ D⟨Exp#1⟩[x↦⟨INT#2⟩] ⟧ → ⟦0⟧ ;

⟦ D⟨Exp#1⟩[x↦x] ⟧ → ⟦1⟧ ;
⟦ D⟨Exp#1⟩[x↦y] ⟧ → ⟦0⟧ ;

⟦ D⟨Exp#0⟩[x↦⟨Exp#1[x]⟩+⟨Exp#2[x]⟩] ⟧ → ⟦D⟨Exp#0⟩[y↦⟨Exp#1[y]⟩] + D⟨Exp#0⟩[z↦⟨Exp#2[z]⟩]⟧ ;
⟦ D⟨Exp#0⟩[x↦⟨Exp#1[x]⟩-⟨Exp#2[x]⟩] ⟧ → ⟦D⟨Exp#0⟩[y↦⟨Exp#1[y]⟩] - D⟨Exp#0⟩[z↦⟨Exp#2[z]⟩]⟧ ;

⟦ D⟨Exp#⟩[x↦⟨Exp#1[x]⟩ * ⟨Exp#2[x]⟩] ⟧
 → ⟦ D⟨Exp#⟩[x↦⟨Exp#1[x]⟩] * ⟨Exp#2[#]⟩ + ⟨Exp#1[#]⟩ * D⟨Exp#⟩[x↦⟨Exp#2[x]⟩] ⟧ ;

⟦ D⟨Exp#⟩[x↦⟨Exp#1[x]⟩ / ⟨Exp#2[x]⟩] ⟧
 → ⟦ ( D⟨Exp#⟩[x↦⟨Exp#1[x]⟩] * ⟨Exp#2[#]⟩ - ⟨Exp#1[#]⟩ * D⟨Exp#⟩[x↦⟨Exp#2[x]⟩] )
      / (⟨Exp#2[#]⟩ * ⟨Exp#2[#]⟩) ⟧ ;

⟦ D⟨Exp#⟩[x↦⟨Fun#f⟩⟨Exp#2[x]⟩] ⟧ → ⟦ d⟨Fun#f⟩ ⟨Exp#2[#]⟩ * D⟨Exp#⟩[x↦⟨Exp#2[x]⟩] ⟧ ;

//// STATIC REDUCTIONS.

sort Exp;

⟦ 0 + ⟨Exp#⟩ ⟧ → # ;
⟦ ⟨Exp#⟩ + 0 ⟧ → # ;
⟦ ⟨Exp#⟩ - 0 ⟧ → # ;
⟦ 1 * ⟨Exp#⟩ ⟧ → # ;
⟦ ⟨Exp#⟩ * 1 ⟧ → # ;

⟦ 0 * ⟨Exp#⟩ ⟧ → ⟦0⟧ ;
⟦ ⟨Exp#⟩ * 0 ⟧ → ⟦0⟧ ;

⟦ ⟨Exp#1⟩ * (1 / ⟨Exp#2⟩) ⟧ → ⟦ ⟨Exp#1⟩ / ⟨Exp#2⟩ ⟧ ;

⟦ [x ↦ ⟨Exp#[x]⟩] ⟨Exp#2⟩ ⟧ → #[#2] ;

//// MISCELLANEOUS

space [ \t\n\r] | "//" [^\n\r]* | nested "/*" "*/" ;

}
