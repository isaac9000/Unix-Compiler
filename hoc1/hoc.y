%{
#include <stdio.h>
#include <signal.h>
#define YYSTYPE double
int yylex();
int yyerror(char*);
void execerror(char*, char*);
%}
%token NUMBER

%left '+' '-' /* left associative, same precedence */
%left '*' '/' /* left assoc, same precedence */
%%
list:   /* nothing */
        | list '\n'
        | list expr '\n' { if ($2 == -0) $2 = 0.0; printf("\t%.8g\n", $2); }
        ;
expr:   NUMBER
        | expr '+' expr { $$ = $1 + $3; }
        | expr '-' expr { $$ = $1 - $3; }
        | expr '*' expr { $$ = $1 * $3; }
        | expr '/' expr { $$ = $1 / $3; }
        | '(' expr ')'  { $$ = $2; }
        ;
%%
#include <ctype.h>
#include <setjmp.h>
char *progname;
int lineno = 1;

int main(int argc, char* argv[])
{
        progname = argv[0];
        yyparse();
        return 0;
}

void warning(char*, char*);
void execerror(char* s, char* t) {
        warning(s, t);
}

void fpecatch(int signum) {
        execerror("floating point exception", (char *) 0);
}

int yylex()
{
        int c;

        while ((c=getchar()) == ' ' || c == '\t')
                ;
        if (c == EOF)
                return 0;
        if (c == '.' || isdigit(c)) {
                ungetc(c, stdin);
                scanf("%lf", &yylval);
                return NUMBER;
        }
        if (c == '\n')
                lineno++;
        return c;
}

void warning(char* s, char* t) {

        fprintf(stderr, "%s: %s", progname, s);
        if (t) {
                fprintf(stderr, " %s", t);
        }
        fprintf(stderr, " near line %d\n", lineno);
}

int yyerror(char* s) {
        fprintf(stderr, "%s: %s", progname, s);
        fprintf(stderr, " near line %d\n", lineno);
        return 0;
}

