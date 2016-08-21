// -*-hacs-*- grammar.
// Copyright © 2016 Kristoffer H. Rose <krisrose@crsx.org>

module org.crsx.hacs2.Hx {

  space [ \t\n] | nested "/*" "*/" | "//" .* ;

  
  // Tokens.

  token QC | ( [A-Za-z] [A-Za-z0-9_$]* "." )* ( [A-Z] [A-Za-z0-9_$]* | \' ( [^\'\\] | ESCCHAR )* \' ) ;  // Constructor
  token QV | ( [A-Za-z] [A-Za-z0-9_$]* "." )* [a-z] [A-Za-z0-9_$]* ;   // variable
  token META | "#" [A-Za-z0-9_$]* ;  // #metavariable

  token INT | [0-9]+ ;
  token STR | \" ( [^\"\\] | ESCCHAR )* \" ;

  token ESCCHAR
    | \\ [^0-9u]
    | \\ [0-3]? [0-7]? [0-7]
    | \\ u ⟨HEX⟩? ⟨HEX⟩? ⟨HEX⟩? ⟨HEX⟩
    ;
  fragment HEX | [0-9A-Fa-f] ;

  token TOKENREF | \u27e8 ⟨QC⟩ \u27e9 ;  // ⟨…⟩
  token CHARCLASS | "[" "^"? "]"? ( [^\]\n\\] | ESCCHAR )+ "]" ;

  token SYNTAX | \u27e6 [^\u27e6\u27e7\u27e8\u27e9]* \u27e7 ;  // ⟦…⟧
  token SYNTAXOPEN | \u27e6 [^\u27e6\u27e7\u27e8\u27e9]* \u27e8 ;  // ⟦…⟨
  token SYNTAXCONT | \u27e9 [^\u27e6\u27e7\u27e8\u27e9]* \u27e8 ;  // ⟩…⟨
  token SYNTAXCLOSE | \u27e9 [^\u27e6\u27e7\u27e8\u27e9]* \u27e7 ;  // ⟩…⟧

  //token TOKENWORD | [^\\/()[]{}?*+:;,.\n\t\u27e6\u27e7\u27e8\u27e9]+ ;


  // Top grammar.

  sort Module | ⟦ module ⟨QC⟩ { ⟨Defs⟩ } ⟧ ;

  sort Defs | ⟦ ⟨Def⟩ ; ⟨Defs⟩ ⟧ | ⟦⟧ ;
  sort Def
    | ⟦ space ⟨RegExp⟩ ⟧
    | ⟦ token ⟨QC⟩ | ⟨RegExp⟩ ⟧
    | ⟦ fragment ⟨QC⟩ | ⟨RegExp⟩ ⟧
    | ⟦ ⟨OptionalMain⟩ sort ⟨QC⟩ ⟨SortMembers⟩ ⟧
    | ⟦ ⟨SortMember⟩ ⟧
    | ⟦ attribute ⟨UpOrDown⟩ ⟨QV⟩ ⟨AttributeForm⟩ ⟧
    | ⟦ ⟨RulePrefix⟩ ⟨Term⟩ → ⟨Term⟩ ⟧
    | ⟦ import ⟨QC⟩ ⟧
    ;
  sort OptionalMain | ⟦main⟧ | ⟦⟧;

  sort RegExp
    | ⟦ ⟨QC⟩ ⟧@2
    | ⟦ ⟨QV⟩ ⟧@2
    | ⟦ ⟨STR⟩ ⟧@2
    | ⟦ ⟨ESCCHAR⟩ ⟧@2
    | ⟦ ⟨TOKENREF⟩ ⟧@2
    | ⟦ ⟨CHARCLASS⟩ ⟧@2
    | ⟦ ( ⟨RegExp@0⟩ ) ⟧@2
    | ⟦ ⟨RegExp@2⟩ ? ⟧@2
    | ⟦ ⟨RegExp@2⟩ * ⟧@2
    | ⟦ ⟨RegExp@2⟩ + ⟧@2
    | ⟦ ⟨RegExp@2⟩ ⟨RegExp@1⟩ ⟧@1
    | ⟦ ⟨RegExp@1⟩ | ⟨RegExp@0⟩ ⟧@0
    ;
  
  sort SortMembers | ⟦ ⟨SortMember⟩ ⟨SortMembers⟩ ⟧ | ⟦⟧;
  sort SortMember
    | ⟦ | ⟨Form⟩ ⟧
    | ⟦ | scheme ⟨Form⟩ ⟨Inheriteds⟩ ⟧
    | ⟦ | ↑ ⟨QV⟩ ⟧
    | ⟦ | ↓ ⟨QV⟩ ⟧
    | ⟦ | sugar ⟨Form⟩ → ⟨Form⟩ ⟧
    ;

  sort Form
    | ⟦ ⟨QC⟩ ( ⟨ScopeForms⟩ ) ⟧
    | ⟦ ⟨SyntacticForm⟩ ⟧
    ;

  sort ScopeForm
    | ⟦ [ ⟨Sorts⟩ ] ⟨Sort⟩ ⟧
    | ⟦ ⟨QC#⟩ ⟧
    ;
  sort ScopeForms | ⟦ ⟨ScopeForm⟩ ⟨ScopeFormsTail⟩ ⟧ | ⟦⟧ ;
  sort ScopeFormsTail | ⟦ , ⟨ScopeForm⟩ ⟨ScopeFormsTail⟩ ⟧ | ⟦⟧ ;

  sort Sort
    | ⟦ ⟨QC⟩ ⟧
    // TODO: parametrised sorts q(...), repeated sorts s* s+ s?.
    ;
  sort Sorts | ⟦ ⟨Sort⟩ ⟨SortsTail⟩ ⟧ | ⟦⟧ ;
  sort SortsTail | ⟦ , ⟨Sort⟩ ⟨SortsTail⟩ ⟧ | ⟦⟧ ;
  
  sort SyntacticForm
    | ⟦ ⟨SYNTAX⟩ ⟨Precedence⟩ ⟧
    | ⟦ ⟨SYNTAXOPEN⟩ ⟨SyntacticRefForm⟩ ⟨SyntacticFormTail⟩ ⟨SYNTAXCLOSE⟩ ⟨Precedence⟩ ⟧
    ;
  sort SyntacticFormTail | ⟦ ⟨SYNTAXCONT⟩ ⟨SyntacticRefForm⟩ ⟨SyntacticFormTail⟩ ⟧ | ⟦⟧ ;

  sort SyntacticRefForm
    | ⟦ ⟨QC⟩ [ ⟨SyntacticScopes⟩ ] ⟨OptionalMeta⟩ ⟨Precedence⟩ ⟧
    | ⟦ ⟨QC⟩ ⟧
    | ⟦ ⟨QC⟩ [ ⟨SyntacticScopes⟩ ] binds ⟨QV⟩ ⟧
    | ⟦ ⟨QC⟩ binds ⟨QV⟩ ⟧
    | ⟦ ⟨ESCCHAR⟩ ⟧
    ;

  sort SyntacticScope
    | ⟦ ⟨QV⟩ as ⟨Sort⟩ ⟧
    ;
  sort SyntacticScopes | ⟦ ⟨SyntacticScope⟩ ⟨SyntacticScopesTail⟩ ⟧ | ⟦⟧ ;
  sort SyntacticScopesTail | ⟦ , ⟨SyntacticScope⟩ ⟨SyntacticScopesTail⟩ ⟧ | ⟦⟧ ;

  sort OptionalMeta | ⟦ ⟨Meta⟩ ⟧ | ⟦⟧ ;

  sort Precedence | ⟦ @ ⟨INT⟩ ⟧ | ⟦⟧ ;

		   
  
  sort UpOrDown | ⟦↑⟧ | ⟦↓⟧ ;
  
  sort AttributeForm
    | ⟦ ( ⟨Sort⟩ ) ⟧
    | ⟦ { ⟨Sort⟩ } ⟧
    | ⟦ { ⟨Sort⟩ : ⟨Sort⟩ } ⟧
    ;

  sort RulePrefix
    | ⟦ [ ⟨RuleOptions⟩ ] ⟨RulePrefix⟩ ⟧
    | ⟦ default ⟨RulePrefix⟩ ⟧
    | ⟦ prority ⟨RulePrefix⟩ ⟧
    | ⟦⟧
    ;

  sort RuleOption
    | ⟦ data ⟨Term⟩ ⟧
    // TODO: more options
    ;
  sort RuleOptions | ⟦ ⟨RuleOption⟩ ⟨RuleOptionsTail⟩ ⟧ | ⟦⟧ ;
  sort RuleOptionsTail | ⟦ , ⟨RuleOption⟩ ⟨RuleOptionsTail⟩ ⟧ | ⟦⟧ ;

  sort Term | ⟦ ⟨TermSortPrefix⟩ ⟨TermCore⟩ ⟨TermAttributes⟩ ⟧ ;
  sort Terms | ⟦ ⟨Term⟩ ⟨TermsTail⟩ ⟧ | ⟦⟧ ;
  sort TermsTail | ⟦ , ⟨Term⟩ ⟨TermsTail⟩ ⟧ | ⟦⟧ ;

  sort TermCore | ⟦ ⟨Meta⟩ ⟧ | ⟦ ⟨Cons⟩ ⟧ | ⟦ ⟨Use⟩ ⟧ | ⟦ ⟨Parsed⟩ ⟧ ;

  sort Meta  | ⟦ ⟨META⟩ [ ⟨Terms⟩ ] ⟧ | sugar ⟦ ⟨META#⟩ ⟧ → ⟦ ⟨META#⟩ [ ] ⟧ ;
  sort Cons  | ⟦ ⟨QC⟩ ( ⟨Scopes⟩ ) ⟧ | sugar ⟦ ⟨QC#⟩ ⟧ → ⟦ ⟨QC#⟩ ( ) ⟧ ;
  sort Use    | ⟦ ⟨QV⟩ ⟧ ;
  
  sort Parsed
    | ⟦ ⟨SYNTAX⟩ ⟧
    | ⟦ ⟨SYNTAXOPEN⟩ ⟨SyntacticRef⟩ ⟨SyntacticTail⟩ ⟨SYNTAXCLOSE⟩ ⟧
    ;
  sort SyntacticTail | ⟦ ⟨SYNTAXCONT⟩ ⟨SyntacticRef⟩ ⟨SyntacticTail⟩ ⟧ | ⟦⟧ ;

  sort SyntacticRef
    | ⟦ ⟨Term⟩ ⟧
    | ⟦ ⟨ESCCHAR⟩ ⟧
    ;
  
  sort Scope
    | ⟦ [ ⟨Variables⟩ ] ⟨Term⟩ ⟧
    | ⟦ ⟨Term⟩ ⟧
    ;
  sort Scopes | ⟦ ⟨Scope⟩ ⟨ScopesTail⟩ ⟧ | ⟦⟧ ;
  sort ScopesTail | ⟦ , ⟨Scope⟩ ⟨ScopesTail⟩ ⟧ | ⟦⟧ ;

  sort X | scheme '( ͡° ͜ʖ ͡°)'() ;
  '( ͡° ͜ʖ ͡°)'() → error⟦see google lenny⟧ ;
  
}
