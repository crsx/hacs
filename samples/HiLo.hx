// TEST EACH NUMBER AS HI OR LO.

module org.crsx.hacs.samples.HiLo {
  token INT | [+-]? [0-9]+ ;  // integer

  // Input is list of integers.
  sort W | ⟦⟨INT⟩⟧ ;
  main sort L | ⟦⟨W⟩ ⟨L⟩⟧ | ⟦⟧ ;

  // Output is Hi or Lo for each number...
  sort Answer | ⟦Hi⟧ | ⟦Lo⟧ ;
  sort Answers | ⟦ ⟨Answer⟩ ⟨Answers⟩ ⟧ | ⟦ ⟧ ;

  // Main scheme provides answer for each integer.
  sort Answers | scheme Test(L) ;
  Test(⟦ ⟨INT#n⟩ ⟨L#L⟩ ⟧) → ⟦ ⟨Answer Test1(#n)⟩ ⟨Answers Test(#L)⟩ ⟧ ;
  Test(⟦⟧) → ⟦⟧ ;

  // An answer is obtained by picking one of two constants based on a computed test.
  sort Answer | scheme Test1(INT) ;
  Test1(#n) → ToAnswer(ComputedAnswer(#n, ⟦Lo⟧, ⟦Hi⟧)) ;

  // The first step of the process is to build a computed result that will contain the answer
  // but HACS still treats it to have Computed sort.
  sort Computed | scheme ComputedAnswer(INT, Answer, Answer) ;
  ComputedAnswer(#n, #yes, #no) → ⟦ #n < 10 ? #yes : #no ⟧ ;

  // We force computed answer back to a proper answer (THIS IS UNSAFE).
  sort Answer | scheme ToAnswer(Computed) ;
  ToAnswer(#n) → #n ;
}
