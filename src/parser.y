%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "parser.tab.h"

// Make Bison aware of functions defined by Flex

extern double variable_values[100];
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
%token  <num>   L_BRACKET R_BRACKET
%token  <num>   DIV MUL ADD SUB EQUALS
%token  <num>   POW MOD
%token  <num>   EOL
%token <index>  VARIABLE 

%type   <num>   calculation
%type   <num>   expr
%type   <num>   assignment
%type   <num>   line

%left SUB ADD
%left MUL DIV MOD
%left POW
%left L_BRACKET R_BRACKET

%%
line: 
      EOL                           { printf("Please enter a calculation:\n"); }
    | calculation EOL               { printf("= %lf\n", $1); YYACCEPT; }
    ;

calculation:
                expr
            |   assignment
            ;

expr: 
      SUB expr                      { $$ = -$2; }
    | NUMBER                        { $$ = $1; }
    | VARIABLE                      { $$ = variable_values[$1]; }
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

assignment:VARIABLE EQUALS expr          { $$ = set_variable($1, $3); };
    
%%

int main(int argc, char ** argv)
{
    while(!yyparse())
    {
        continue;
    }
    return 0;
}

void yyerror(const char *s)
{
    fprintf(stderr, "ERROR: %s\n", s);
}
