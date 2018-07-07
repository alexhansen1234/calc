/* scanner for a toy Pascal-like language */

%{
/* need this for the call to atof() below */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mem.h"
#include "parser.tab.h"
%}

%option noyywrap

delim   [ \t\n]
ws      {delim}+
letter  [A-Za-z]
digit   [0-9]
id      {letter}*({letter}|{digit})*
number  {digit}+(\.{digit}+)?(E[+\-]?{digit}+)?

%%

{number}    { yylval.num = atof(yytext); return NUMBER; }
{id}        { yylval.index = add_variable(yytext); return VARIABLE; } 
"+"         { return ADD; }
"-"         { return SUB; }
"*"         { return MUL; }
"/"         { return DIV; }
"%"         { return MOD; }
"^"         { return POW; }
"("         { return L_BRACKET; }
")"         { return R_BRACKET; }
"="         { return EQUALS; }
[\n]        { return EOL; }
[ \t]       ; 
.           { printf("Unknown token\n"); }
%%
