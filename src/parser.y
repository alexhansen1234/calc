%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "parser.tab.h"
#include "econ_func.h"

#define YYDEBUG 1

// Make Bison aware of functions defined by Flex

extern double variable_values[100];
extern int add_variable(char *);
extern int set_variable(int, double);

extern int yylex();
extern int yyparse();
extern FILE * yyin;

void yyerror(const char * s);
%}

/*
 *  Bison requires a union datatype defined with all possible
 *  data types returned from Flex. In this example, our data
 *  types are integers, floating points or variable identifiers (id)
 */

%union {
    int     index;
    double  num;
}

/*
 * Define terminals (in caps) and associate with a field in the
 * union (in <> brackets)
 */

%token  <num>   NUMBER
%token  <num>   COMMA
%token  <num>   L_BRACKET R_BRACKET
%token  <num>   DIV MUL ADD SUB EQUALS
%token  <num>   POW SQRT MOD
%token  <num>   EOL
%token  <num>   A_F
%token  <num>   F_A
%token  <num>   P_A
%token  <num>   A_P
%token  <num>   P_F
%token  <num>   F_P
%token  <num>   A_G
%token  <num>   ROR
%token <index>  VARIABLE 

%type   <num>   calculation
%type   <num>   expr
%type   <num>   assignment
%type   <num>   line
%type   <num>   function

%left SUB ADD
%left MUL DIV MOD
%left POW
%left L_BRACKET R_BRACKET

%define parse.error verbose

%%
line: 
      EOL                           { printf("Please enter a calculation:\n"); }
    | calculation EOL               { set_variable(0, $1);
                                      printf("= %lf\n", $1); 
                                      YYACCEPT; }
    ;

calculation:
                expr
            |   assignment
            ;

expr: 
      SUB expr                      { $$ = -$2; }
    | NUMBER                        { $$ = $1; }
    | VARIABLE                      { $$ = variable_values[$1]; }
    | function
    | expr DIV expr                 { 
                                        if($3 == 0) 
                                        { 
                                            yyerror("Cannot divide by zero"); 
                                            YYABORT;
                                        } 
                                        else 
                                            $$ = $1 / $3; 
                                    }
    | expr MUL expr                 { $$ = $1 * $3; }
    | L_BRACKET expr R_BRACKET      { $$ = $2; }
    | expr ADD expr                 { $$ = $1 + $3; }
    | expr SUB expr                 { $$ = $1 - $3; }
    | expr POW expr                 { $$ = pow($1, $3); }
    | expr MOD expr                 { $$ = fmod($1, $3); }
    ;

assignment: VARIABLE EQUALS expr          { $$ = set_variable($1, $3); };

function: SQRT L_BRACKET expr R_BRACKET { $$ = sqrt($3); }
        | A_F L_BRACKET expr COMMA expr R_BRACKET { $$ = a_f($3, $5); }
        | F_A L_BRACKET expr COMMA expr R_BRACKET { $$ = f_a($3, $5); }
        | P_A L_BRACKET expr COMMA expr R_BRACKET { $$ = p_a($3, $5); }
        | A_P L_BRACKET expr COMMA expr R_BRACKET { $$ = a_p($3, $5); }
        | P_F L_BRACKET expr COMMA expr R_BRACKET { $$ = p_f($3, $5); }
        | F_P L_BRACKET expr COMMA expr R_BRACKET { $$ = f_p($3, $5); }
        | A_G L_BRACKET expr COMMA expr R_BRACKET { $$ = a_g($3, $5); }
        | ROR L_BRACKET expr COMMA expr COMMA expr COMMA expr COMMA expr R_BRACKET { $$ = ror($3, $5, $7, $9, $11); }
        ;
%%

int main(int argc, char ** argv)
{
    add_variable("ans");
    while(1)
    {
        yyparse();
        continue;
    }
    return 0;
}

void yyerror(const char *s)
{
    fprintf(stderr, "ERROR: %s %ld\n", s, ftell(yyin));
}
