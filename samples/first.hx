// $Id: first.hx,v 1.16 2014/01/06 03:11:28 krisrose Exp $
// First HACS sample compiler (inspired by Dragonbook Fig.7).
//
module "net.sf.crsx.samples.gentle.First" {


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

main sort Stat  | ⟦ ⟨Name⟩ := ⟨Exp⟩ ; ⟧		// assignment statement (with newline)
           | ⟦ { ⟨Stat*⟩ } ⟧                    // block statement
           ;


/* 3. SEMANTIC SORTS & SCHEMES. */

sort Type | Int | Float ;

| scheme Unif(Type,Type) ;
Unif(Int, Int) → Int;
Unif(#t1, Float) → Float;
Unif(Float, #t2) → Float;


/* 4. SEMANTIC ANALYSIS. */

attribute ↑t(Type);  // synthesized expression type
sort Exp | ↑t;

⟦ (⟨Exp#1 ↑t(#t1)⟩ + ⟨Exp#2 ↑t(#t2)⟩) ⟧ ↑t(Unif(#t1,#t2));
⟦ (⟨Exp#1 ↑t(#t1)⟩ * ⟨Exp#2 ↑t(#t2)⟩) ⟧ ↑t(Unif(#t1,#t2));
⟦ ⟨Int#⟩ ⟧ ↑t(Int);
⟦ ⟨Float#⟩ ⟧ ↑t(Float);

attribute ↓e{Name:Type};  // inherited type environment

// TA: Type Analysis scheme.

sort Stat | scheme ⟦ TA ⟨Stat⟩ ⟧ ↓e ;

⟦ TA ⟨Name id⟩ := ⟨Exp#2⟩; ⟧ → ⟦ ⟨Name id⟩ := TA ⟨Exp#2⟩; ⟧;

⟦ TA {} ⟧ → ⟦{}⟧;

⟦ TA { ⟨Name id⟩ := ⟨Exp#2⟩; ⟨Stat*#3⟩ } ⟧ → ⟦ TA2 { ⟨Name id⟩ := TA ⟨Exp#2⟩; ⟨Stat*#3⟩ } ⟧;
{
  | scheme ⟦ TA2 ⟨Stat⟩ ⟧ ↓e;
  ⟦ TA2 { ⟨Name id⟩ := ⟨Exp#2 ↑t(#t2)⟩; ⟨Stat*#3⟩ } ⟧ →
    ⟦ { ⟨Name id⟩ := ⟨Exp#2⟩; ⟨Stat ⟦TA {⟨Stat*#3⟩}⟧ ↓e{⟦id⟧:#t2}⟩ } ⟧;
}
⟦ TA { {⟨Stat*#1⟩} ⟨Stat*#2⟩ } ⟧ → ⟦ { TA {⟨Stat*#1⟩} TA {⟨Stat*#2⟩} } ⟧;

sort Exp | scheme ⟦ TA ⟨Exp⟩ ⟧ ↓e ;

⟦ TA id ⟧ ↓e{⟦id⟧ : #t} → ⟦ id ⟧ ↑t(#t);
⟦ TA id ⟧ ↓e{¬⟦id⟧} → error⟦Undefined identifier ⟨id⟩⟧;

⟦ TA ⟨Int#⟩ ⟧ → ⟦ ⟨Int#⟩ ⟧;
⟦ TA ⟨Float#⟩ ⟧ → ⟦ ⟨Float#⟩ ⟧;
⟦ TA (⟨Exp#1⟩ + ⟨Exp#2⟩) ⟧ → ⟦ (TA ⟨Exp#1⟩) + (TA ⟨Exp#2⟩) ⟧;
⟦ TA (⟨Exp#1⟩ * ⟨Exp#2⟩) ⟧ → ⟦ (TA ⟨Exp#1⟩) * (TA ⟨Exp#2⟩) ⟧;


/* 5. INTERMEDIATE CODE GENERATION. */

token T | T ('_' ⟨Int⟩)? ; // temporary

// Concrete syntax & abstract syntax sorts.

sort I_Progr | ⟦⟨I_Instr⟩ ⟨I_Progr⟩⟧ | ⟦⟧ ;

sort I_Instr | ⟦⟨Tmp⟩ = ⟨I_Arg⟩ + ⟨I_Arg⟩;¶⟧
   	     | ⟦⟨Tmp⟩ = ⟨I_Arg⟩ * ⟨I_Arg⟩;¶⟧
     	     | ⟦⟨Tmp⟩ = ⟨I_Arg⟩;¶⟧
     	     | ⟦⟨Name⟩ = ⟨Tmp⟩;¶⟧
	     ;

sort I_Arg | ⟦⟨Name⟩⟧
     	   | ⟦⟨Float⟩⟧
     	   | ⟦⟨Int⟩⟧
	   | ⟦⟨Tmp⟩⟧
	   ;

sort Tmp | symbol ⟦ ⟨T⟩ ⟧ ;

// Translation scheme.

attribute ↓TmpType{Tmp:Type} ;

sort I_Progr ;

| scheme ⟦ ICG ⟨Stat⟩ ⟧ ↓TmpType ;
⟦ ICG id := ⟨Exp#2 ↑t(#t2)⟩; ⟧ → ⟦ { ⟨I_Progr ⟦ICGExp T ⟨Exp#2⟩⟧ ↓TmpType{⟦T⟧:#t2}⟩ } id = T; ⟧ ;
⟦ ICG { } ⟧ → ⟦ ⟧;
⟦ ICG { ⟨Stat#s⟩ ⟨Stat*#ss⟩ } ⟧ → ⟦ { ICG ⟨Stat#s⟩ } ICG { ⟨Stat*#ss⟩ } ⟧ ;

| scheme ⟦ ICGExp ⟨Tmp⟩ ⟨Exp⟩ ⟧ ;

⟦ ICGExp T ⟨Int#1⟩ ⟧ → ⟦ T = ⟨Int#1⟩; ⟧ ;
⟦ ICGExp T ⟨Float#1⟩ ⟧ → ⟦ T = ⟨Float#1⟩; ⟧ ;
⟦ ICGExp T id ⟧ → ⟦ T = id; ⟧ ;

⟦ ICGExp T ⟨Exp#1⟩ + ⟨Exp#2⟩ ⟧
  → ⟦ {ICGExp T_1 ⟨Exp#1⟩} {ICGExp T_2 ⟨Exp#2⟩} T = T_1 + T_2; ⟧ ;

⟦ ICGExp T ⟨Exp#1⟩ * ⟨Exp#2⟩ ⟧
  → ⟦ {ICGExp T_1 ⟨Exp#1⟩} {ICGExp T_2 ⟨Exp#2⟩} T = T_1 * T_2; ⟧ ;

// Helper to flatten code sequence.
| scheme ⟦ {⟨I_Progr⟩} ⟨I_Progr⟩ ⟧;
⟦ {} ⟨I_Progr#3⟩ ⟧ → #3 ;
⟦ {⟨I_Instr#1⟩ ⟨I_Progr#2⟩} ⟨I_Progr#3⟩ ⟧ → ⟦ ⟨I_Instr#1⟩ {⟨I_Progr#2⟩} ⟨I_Progr#3⟩ ⟧;


/* 6. CODE GENERATOR. */

// Concrete syntax & abstract syntax sorts.

sort A_Progr | ⟦ ⟨A_Instr⟩ ⟨A_Progr⟩ ⟧ | ⟦⟧ ;

sort A_Instr | ⟦ LDF ⟨Tmp⟩, ⟨A_Arg⟩¶⟧
     	     | ⟦ STF ⟨Name⟩, ⟨Tmp⟩¶⟧
     	     | ⟦ ADDF ⟨A_Arg⟩, ⟨A_Arg⟩, ⟨A_Arg⟩¶⟧
     	     | ⟦ MULF ⟨A_Arg⟩, ⟨A_Arg⟩, ⟨A_Arg⟩¶⟧
	     ;

sort A_Arg | ⟦ #⟨Float⟩ ⟧ | ⟦ #⟨Int⟩ ⟧ | ⟦ ⟨Name⟩ ⟧ | ⟦ ⟨Tmp⟩ ⟧ ;

// Schemes.

sort A_Progr | scheme ⟦ CG ⟨I_Progr⟩ ⟧ ;

⟦ CG ⟧ → ⟦⟧ ;

⟦ CG T = ⟨I_Arg#1⟩ + ⟨I_Arg#2⟩ ; ⟨I_Progr#⟩ ⟧
  → ⟦ ADDF T, [⟨I_Arg#1⟩], [⟨I_Arg#2⟩] CG ⟨I_Progr#⟩ ⟧ ;

⟦ CG T = ⟨I_Arg#1⟩ * ⟨I_Arg#2⟩ ; ⟨I_Progr#⟩ ⟧
  → ⟦ MULF T, [⟨I_Arg#1⟩], [⟨I_Arg#2⟩] CG ⟨I_Progr#⟩ ⟧ ;
  
⟦ CG T = ⟨I_Arg#1⟩ ; ⟨I_Progr#⟩ ⟧
  → ⟦ LDF T, [⟨I_Arg#1⟩] CG ⟨I_Progr#⟩ ⟧ ;

⟦ CG name = T ; ⟨I_Progr#⟩ ⟧
  → ⟦ STF name, T CG ⟨I_Progr#⟩ ⟧ ;

sort A_Arg ;

| scheme ⟦ [⟨I_Arg⟩] ⟧ ;
⟦ [T] ⟧ → ⟦ T ⟧ ;
⟦ [name] ⟧ → ⟦ name ⟧ ;
⟦ [⟨Float#1⟩] ⟧ → ⟦ #⟨Float#1⟩ ⟧ ;
⟦ [⟨Int#1⟩] ⟧ → ⟦ #⟨Int#1⟩ ⟧ ;


/* 7. MAIN. */

sort A_Progr | scheme ⟦ Compile ⟨Stat⟩ ⟧ ;
⟦ Compile ⟨Stat#1⟩ ⟧ → ⟦ CG ICG TA ⟨Stat#1⟩ ⟧ ;

| scheme Compile(Stat);
Compile(#) → ⟦ Compile ⟨Stat#⟩ ⟧ ;

}
