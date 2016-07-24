/* Lex specification for -*-C-*- code to extract .hx from .lhx.
 */

%{
#include <stdio.h>
int echo = 0;
%}

%option noyywrap

%%

^[ \t]*"\\begin{hacs}".*  { echo = 1; }
^[ \t]*"\\end{hacs}".*  { echo = 0; putchar('\n'); }

.*  { if (echo) puts(yytext); }

\n /* ignore newlines */

%%

int main(int argc, char** argv) {
  yylex();
  return 0;
}
