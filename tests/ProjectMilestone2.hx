// [NYU Courant Institute] Compiler Construction/Fall 2014/Project Milestone 2
//
// Base parser.
//
// All references are to the problem text,
// http://cs.nyu.edu/courses/fall14/CSCI-GA.2130-001/pr2/pr2.pdf

module "edu.nyu.csci.cc.fall14.ProjectMilestone2" {

// PROGRAM

main sort Program  |  ⟦ ⟨Declarations⟩ ⟧ ;

// DECLARATIONS

sort Declarations | ⟦ ⟨Declaration⟩ ⟨Declarations⟩ ⟧ | ⟦⟧ ;

sort Declaration
|  ⟦ class ⟨Identifier⟩ { ⟨Members⟩ } ⟧
|  ⟦ function ⟨Type⟩ ⟨Identifier⟩ ⟨ArgumentSignature⟩ { ⟨Statements⟩ } ⟧
;

sort Members | ⟦ ⟨Member⟩ ⟨Members⟩ ⟧ | ⟦⟧ ;

sort Member
|  ⟦ ⟨Type⟩ ⟨Identifier⟩ ; ⟧
|  ⟦ ⟨Type⟩ ⟨Identifier⟩ ⟨ArgumentSignature⟩ { ⟨Statements⟩ } ⟧
;

sort ArgumentSignature
|  ⟦ ( ) ⟧
|  ⟦ ( ⟨Type⟩ ⟨Identifier⟩ ⟨TypeIdentifierTail⟩ ) ⟧
;
sort TypeIdentifierTail |  ⟦ , ⟨Type⟩ ⟨Identifier⟩ ⟨TypeIdentifierTail⟩ ⟧  |  ⟦ ⟧ ;  // For each comma\label{TypeIdentifierTail}

// STATEMENTS

sort Statements | ⟦ ⟨Statement⟩ ⟨Statements⟩ ⟧ | ⟦⟧ ;

sort Statement
|  ⟦ { ⟨Statements⟩ } ⟧
|  ⟦ var ⟨Type⟩ ⟨Identifier⟩ ; ⟧
|  ⟦ ; ⟧
|  ⟦ ⟨Expression⟩ ; ⟧
|  ⟦ if ( ⟨Expression⟩ ) ⟨IfTail⟩ ⟧
|  ⟦ while ( ⟨Expression⟩ ) ⟨Statement⟩ ⟧
|  ⟦ return ⟨Expression⟩ ; ⟧
|  ⟦ return ; ⟧
;

sort IfTail | ⟦ ⟨Statement⟩ else ⟨Statement⟩ ⟧ | ⟦ ⟨Statement⟩ ⟧ ;  // Eagerly consume elses\label{IfTail}

// TYPES

sort Type
|  ⟦ boolean ⟧
|  ⟦ int ⟧
|  ⟦ string ⟧
|  ⟦ void ⟧
|  ⟦ ⟨Identifier⟩ ⟧
;

// EXPRESSIONS

sort Expression

|  sugar ⟦ ( ⟨Expression#e⟩ ) ⟧@9 → #e

|  ⟦ ⟨SimpleLiteral⟩ ⟧@9
|  ⟦ ⟨Identifier⟩ ⟧@9
|  ⟦ this ⟧@9
|  ⟦ ⟨Expression@9⟩ ( ⟨Expression⟩ ) ⟧@9
|  ⟦ ⟨Expression@9⟩ ( ) ⟧@9
|  ⟦ ⟨Expression@9⟩ . ⟨Identifier⟩ ⟧@9

|  ⟦ ! ⟨Expression@8⟩ ⟧@8
|  ⟦ - ⟨Expression@8⟩ ⟧@8
|  ⟦ + ⟨Expression@8⟩ ⟧@8

|  ⟦ ⟨Expression@7⟩ * ⟨Expression@8⟩ ⟧@7
|  ⟦ ⟨Expression@7⟩ / ⟨Expression@8⟩ ⟧@7
|  ⟦ ⟨Expression@7⟩ % ⟨Expression@8⟩ ⟧@7

|  ⟦ ⟨Expression@6⟩ + ⟨Expression@7⟩ ⟧@6
|  ⟦ ⟨Expression@6⟩ - ⟨Expression@7⟩ ⟧@6

|  ⟦ ⟨Expression@6⟩ < ⟨Expression@6⟩ ⟧@5
|  ⟦ ⟨Expression@6⟩ > ⟨Expression@6⟩ ⟧@5
|  ⟦ ⟨Expression@6⟩ <= ⟨Expression@6⟩ ⟧@5
|  ⟦ ⟨Expression@6⟩ >= ⟨Expression@6⟩ ⟧@5

|  ⟦ ⟨Expression@5⟩ == ⟨Expression@5⟩ ⟧@4
|  ⟦ ⟨Expression@5⟩ != ⟨Expression@5⟩ ⟧@4

|  ⟦ ⟨Expression@3⟩ && ⟨Expression@4⟩ ⟧@3

|  ⟦ ⟨Expression@2⟩ || ⟨Expression@3⟩ ⟧@2

|  ⟦ ⟨Expression@2⟩ = ⟨Expression@1⟩ ⟧@1
|  ⟦ ⟨Expression@2⟩ = ⟨ObjectLiteral⟩ ⟧@1 // \nt{ObjectLiteral} treated separately \label{ObjectLiteral}
|  ⟦ ⟨Expression@2⟩ += ⟨Expression@1⟩ ⟧@1

|  ⟦ ⟨Expression@1⟩ , ⟨Expression⟩ ⟧
;

sort Literal        |  ⟦ ⟨SimpleLiteral⟩ ⟧  |  ⟦ ⟨ObjectLiteral⟩ ⟧ ; // Not used from \nt{Expression}.
sort SimpleLiteral  |  ⟦ ⟨String⟩ ⟧  |  ⟦ ⟨Integer⟩ ⟧ ;
sort ObjectLiteral  |  ⟦ { } ⟧  |  ⟦ { ⟨KeyValue⟩ ⟨KeyValueTail⟩ } ⟧ ;
sort KeyValueTail   |  ⟦ , ⟨KeyValue⟩ ⟨KeyValueTail⟩ ⟧  |  ⟦ ⟧ ;
sort KeyValue       |  ⟦ ⟨Identifier⟩ : ⟨Literal⟩ ⟧ ;

// LEXICAL CONVENTIONS

space [ \t\n\r] | '//' [^\n]* | '/*' ( [^*] | '*' [^/] )* '*/'  ; // Inner /* ignored

token Identifier  | ⟨LetterEtc⟩ (⟨LetterEtc⟩ | ⟨Digit⟩)* ;

token Integer     | ⟨Digit⟩+ ;

token String      | \' ( [^''\\\n] | \\ ⟨Escape⟩ )* \'
                  | \" ( [^""\\\n] | \\ ⟨Escape⟩ )* \"
                  ;

token fragment Letter     | [A-Za-z] ;
token fragment LetterEtc  | ⟨Letter⟩ | [$_] ;
token fragment Digit      | [0-9] ;

token fragment Escape  | "\n" | [''""\\] | [nt] | 'x' ⟨Hex⟩ ⟨Hex⟩ ;
token fragment Hex     | [0-9A-Fa-f] ;

}
