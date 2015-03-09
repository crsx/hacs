// Simply typed lambda caculus to Java compiler in -*-hacs-*-.
module org.crsx.hacs.samples.LambdaJava {

  // INPUT LANGUAGE.
		       
  // Tokens.
  token ID | [a-z] [a-z0-9_]*  ;
  token NUM | [-+]? [0-9]+ ([.] [0-9]+)? ([Ee] [-+]? [0-9]+) ;
  token ADDOP | [-+] ;
  token MULTOP | [*/] ;

  // Variables and type variables.
  sort V  | symbol ⟦⟨ID⟩⟧ ;
  
  // Simple types.
  sort T  | ⟦⟨T@1⟩ → ⟨T⟩⟧  | ⟦num⟧@1   | sugar ⟦(⟨T#⟩)⟧@1 →   T# ;

  // Lambda terms.
  main sort L
    | ⟦ λ ⟨V binds x⟩ : ⟨T⟩ . ⟨L[x as L]⟩ ⟧
    | ⟦ ⟨L@1⟩ ⟨ADDOP⟩ ⟨L@2⟩ ⟧@1
    | ⟦ ⟨L@2⟩ ⟨MULTOP⟩ ⟨L@3⟩ ⟧@2
    | ⟦ ⟨L@3⟩ ⟨L@4⟩ ⟧@3
    | ⟦ ⟨V⟩ ⟧@4
    | ⟦ ⟨NUM⟩ ⟧@4
    | sugar ⟦ ( ⟨L#⟩ ) ⟧@2  →  L#
    ;

  // TYPE CHECKER.
  
  attribute ↑t(T); // assigned type
  sort L | ↑t ; // type assigned to every lambda (sub)term

  // Scheme to assign types.
  sort L | TypeCheck(L) ;
  {
    TypeCheck(#L) → WaitForType(TE(#L)) ;
    sort L | scheme WaitForType(L) ;
    WaitForType(#L ↑t(#t)) →   #L ;

    // Distribute declared types to all variables.
    attribute ↓te{V:T}; // type environment
    sort L | scheme TE(L) ↓te ; // carrier scheme
    TE(⟦ λ x : ⟨T#tx⟩ . ⟨L#L[x]⟩ ⟧) →   ⟦ λ x : ⟨T#tx⟩ . ⟨L #L[x] ↓te{⟦x⟧ : #tx}⟩ ⟧ ;
    TE(⟦ ⟨L#1⟩ ⟨ADDOP#op⟩ ⟨L#2⟩ ⟧) →   ⟦ ⟨L TE(#1)⟩ ⟨ADDOP#op⟩ ⟨L TE(#2)⟩ ⟧ ;
    TE(⟦ ⟨L#1⟩ ⟨MULTOP#op⟩ ⟨L#2⟩ ⟧) →   ⟦ ⟨L TE(#1)⟩ ⟨MULTOP#op⟩ ⟨L TE(#2)⟩ ⟧ ;
    TE(⟦ ⟨L#1⟩ ⟨L#2⟩ ⟧) →   ⟦ ⟨L TE(#1)⟩ ⟨L TE(#2)⟩ ⟧ ;
    TE(⟦ v ⟧) ↓te{⟦v⟧ : #t}  →  ⟦ v ⟧ ↑te(⟦v⟧) ;
    TE(⟦ v ⟧) ↓te{¬⟦v⟧}  →  error⟦Undeclared variable ⟨v⟩.⟧ ;
    TE(⟦ ⟨NUM#n⟩ ⟧) → ⟦ ⟨NUM#n⟩ ⟧ ;

    // Rules to synthesize ↑t (after variables have been assigned).
    ⟦ λ x : ⟨T#tx⟩ . ⟨L#L[x] ↑t(#tL)⟩ ⟧ ↑t(⟦ ⟨T#tx⟩ → ⟨T#tL⟩ ⟧) ;
    ⟦ ⟨L#1 ↑t(#t1)⟩ ⟨ADDOP#op⟩ ⟨L#2 ↑t(#t2)⟩ ⟧ ↑t(OpType(#t1, #t2)) ;
    ⟦ ⟨L#1 ↑t(#t1)⟩ ⟨MULTOP#op⟩ ⟨L#2 ↑t(#t2)⟩ ⟧ ↑t(OpType(#t1, #t2)) ;
    ⟦ ⟨L#1 ↑t(#t1)⟩ ⟨L#2 ↑t(#t2)⟩ ⟧ ↑t(AppType(#t1, #t2)) ;
    ⟦ ⟨NUM#n⟩ ⟧ ↑t(⟦num⟧) ;

    sort T | OpType(T, T) ;
    OpType(⟦num⟧, ⟦num⟧) →  ⟦num⟧ ;
    default OpType(#t1, #t2) →  error⟦Numeric operator on non-numeric types⟧ ;

    sort T | AppType(T, T) ;
    AppType(⟦ ⟨T#ta⟩ → ⟨T#tr⟩ ⟧, #ta) →  #tb ;
    default AppType(#t1, #t2) →  error⟦Application does not apply function to proper argument⟧ ;
  }

  // TARGET JAVA SUBSET TEMPLATES.

  // Java output program.

  sort JClass | ⟦
      package org.crsx.hacs.samples;
      public class Sample { public static void main ( String [ ] args ) { ⟨J⟩. print ( System . out ) ; } }
    ⟧
    | scheme EmitJClass(J) ;
  EmitJClass(#J) →  ⟦
    package org.crsx.hacs.samples;
    public class Sample { public static void main ( String [ ] args ) { ⟨J#J⟩. print ( System . out ) ; } }
  ⟧ ;

  // Java expressions.

  sort J | ⟦ ⟨V⟩ ⟧ | scheme EmitJRef(V) ;
  EmitJRef(⟦v⟧) → ⟦ v ⟧ ;

  sort J | ⟦ Num.mk(⟨NUM⟩) ⟧ | scheme EmitJNum(NUM) ;
  EmitJNum(#n) → ⟦ Num.mk(⟨NUM#n⟩) ⟧ ;

  sort J | ⟦ new Fun( ) { public Val apply(Val ⟨V binds a⟩) { return ⟨J[a as J]⟩; } } ⟧ | scheme EmitJFun([a]J[a as J]) ;
  EmitJFun(a.#J[a]) → ⟦ new Fun( ) { public Val apply(Val arg) { return ⟨J#J[⟦arg⟧]⟩;¶ } } ⟧ ;

  sort J | ⟦ ⟨J⟩.apply(⟨J⟩); ⟧ | scheme EmitJApp(J, J) ;
  EmitJApp(#J1, #J2) → ⟦ ⟨J#J1⟩¶.apply(⟨J#J2⟩) ⟧ ;
  
  sort JOp | ⟦⟨ADDOP⟩⟧ | ⟦⟨MULTOP⟩⟧ ;
  sort J | ⟦ ⟨J⟩ ⟨JOp⟩ ⟨J⟩ ⟧ | scheme EmitJOp(JOp, J, J) ;
  EmitJOp(#op, #J1, #J2) →  ⟦ ⟨J#J1⟩ ⟨JOp#op⟩ ⟨J#J1⟩ ⟧ ;

  // COMPILER.

  sort J | scheme L2J(L) ;

  L2J(⟦ λ x : ⟨T#tx⟩ . ⟨L#L[x]⟩ ⟧) →   EmitJFun(⟦a⟧, L2J(#L[⟦a⟧])) ;
  L2J(⟦ ⟨L#1⟩ ⟨ADDOP#op⟩ ⟨L#2⟩ ⟧) →   EmitJOp(⟦⟨ADDOP#op⟩⟧, L2J(#1), L2J(#2)) ;
  L2J(⟦ ⟨L#1⟩ ⟨MULTOP#op⟩ ⟨L#2⟩ ⟧) →   EmitJOp(⟦⟨MULTOP#op⟩⟧, L2J(#1), L2J(#2)) ;
  L2J(⟦ ⟨L#1⟩ ⟨L#2⟩ ⟧) →   EmitJApp(L2J(#1), L2J(#2)) ;
  L2J(⟦ v ⟧) →  EmitJRef(⟦v⟧) ;
  L2J(⟦ ⟨NUM#n⟩ ⟧) → EmitJNum(#n) ;

  // MAIN.

  sort JClass | Compile(L) ;
  Compile(#L) →  EmitJClass(L2J(TypeCheck(#L))) ;
}
