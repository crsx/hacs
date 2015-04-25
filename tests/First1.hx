// First HACS sample compiler (inspired by Dragonbook Fig.7).
//
module org.crsx.hacs.tests.first1.First1 {


/* 1. LEXICAL ANALYSIS. */

space [ \t\n] ;                                 // white space convention

token Int    | ⟨Digit⟩+ ;                       // tokens
token Float  | ⟨Int⟩ "." ⟨Int⟩ ;
token Id     | ⟨Lower⟩+ ('_'? ⟨Int⟩)? ;

token fragment Digit  | [0-9] ;
token fragment Lower  | [a-z] ;


/* 2. SYNTAX ANALYSIS. */

sort Exp   | ⟦ ⟨Exp@1⟩ + ⟨Exp@2⟩ ⟧@1            // addition
           | ⟦ ⟨Exp@2⟩ * ⟨Exp@3⟩ ⟧@2            // multiplication
           | ⟦ ⟨Int⟩ ⟧@3                        // integer
           | ⟦ ⟨Float⟩ ⟧@3                      // floating point number
           | ⟦ ⟨Name⟩ ⟧@3                       // assigned value
           | sugar ⟦ (⟨Exp#⟩) ⟧@3 → #           // parenthesis
           ;

sort Name  | symbol ⟦ ⟨Id⟩ ⟧ ;                  // assigned symbols

main
sort Stat  | ⟦ ⟨Name⟩ := ⟨Exp⟩ ; ⟧		// assignment statement (with newline)
           | ⟦ { ⟨Stats⟩ } ⟧                    // block statement
           ;

sort Stats | ⟦ ⟨Stat⟩ ⟨Stats⟩ ⟧ | ⟦⟧ ;

sort Stat;
| scheme Compile(Stat);
Compile(#) → # ;

}
