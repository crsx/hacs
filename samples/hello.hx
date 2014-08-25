module "Hello" {
space " " | nested "/*" "*/" ;
token World | [A-Za-z0-9_-]+ ;
sort Who | ⟦ ⟨World⟩ ⟧;
sort Greeting | ⟦ Hello, ⟨Who⟩! ⟧;
| scheme Greet | Greet(Who);
Greet(#who) → ⟦ Hello, ⟨Who #who⟩! ⟧;
}
