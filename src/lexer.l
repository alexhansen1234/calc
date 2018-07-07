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
comma   ,
%%

{number}    { yylval.num = atof(yytext); return NUMBER; }
"+"         { return ADD; }
"-"         { return SUB; }
"*"         { return MUL; }
"/"         { return DIV; }
"%"         { return MOD; }
"^"         { return POW; }
"("         { return L_BRACKET; }
")"         { return R_BRACKET; }
"="         { return EQUALS; }
"a_f"       { return A_F; }
"f_a"       { return F_A; }
"p_a"       { return P_A; }
"a_p"       { return A_P; }
"p_f"       { return P_F; }
"f_p"       { return F_P; }
"a_g"       { return F_P; }
"ror"       { return ROR; }
"sqrt"      { return SQRT; }
","         { return COMMA; }
{id}        { yylval.index = add_variable(yytext); return VARIABLE; } 
[\n]        { return EOL; }
[ \t]       ; 
.           { printf("Unknown token\n"); }

%%
