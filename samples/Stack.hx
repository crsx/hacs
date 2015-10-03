module org.crsx.hacs.samples.Stack {

// Grammar. \label{code:stack:gram1}
space [ \t\n] ;
token INT    | [0-9]+ ;
token ID     | [a-z] [a-z0-9_]* ;

main sort Exp
  | ⟦ ⟨Exp@1⟩ + ⟨Exp@2⟩ ⟧@1
  | ⟦ ⟨Exp@2⟩ * ⟨Exp@3⟩ ⟧@2
  | ⟦ ⟨INT⟩ ⟧@3
  | sugar ⟦ (⟨Exp#⟩) ⟧@3 → Exp#
  ;  //\label{code:stack:gram2}

// Stack code. \label{code:stack:code1}
sort Code
  |  ⟦ ⟨Instruction⟩ ⟨Code⟩ ⟧
  |  ⟦ ⟧
  ;
sort Instruction
  |  ⟦ PUSH ⟨INT⟩ ¶ ⟧
  |  ⟦ ADD ¶ ⟧
  |  ⟦ MULT ¶ ⟧
  ; //\label{code:stack:code2}
 
// Flattening helper. \label{code:stack:flat1}
 sort Code | scheme ⟦ { ⟨Code⟩ } ⟨Code⟩ ⟧ | scheme Append(Code, Code);
⟦ { ⟨Instruction#1⟩ ⟨Code#2⟩ } ⟨Code#3⟩ ⟧
  →  ⟦ ⟨Instruction#1⟩ { ⟨Code#2⟩ } ⟨Code#3⟩ ⟧  ;
 Append(⟦ ⟨Instruction#1⟩ ⟨Code#2⟩ ⟧, #3) → ⟦ ⟨Instruction#1⟩ ⟨Code Append(#2,#3)⟩ ⟧ ;
⟦ { } ⟨Code#⟩ ⟧ →   Code# ; //\label{code:stack:flat2}
 Append(⟦⟧, #2) → #2;
 
// Compiler. \label{code:stack:comp1}
sort Code | scheme Compile(Exp) ;
Compile(⟦⟨Exp#1⟩ + ⟨Exp#2⟩⟧)
  →  ⟦ { ⟨Code Compile(#1)⟩ } { ⟨Code Compile(#2)⟩ } ADD ⟧ ;
Compile(⟦⟨Exp#1⟩ * ⟨Exp#2⟩⟧)
  →  ⟦ { ⟨Code Compile(#1)⟩ } { ⟨Code Compile(#2)⟩ } MULT ⟧ ;
Compile(⟦⟨INT#⟩⟧) →    ⟦PUSH ⟨INT#⟩⟧ ; //\label{code:stack:comp2}

}
