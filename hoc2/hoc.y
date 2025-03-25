%{
#include <stdio.h>
#include <signal.h>
/*#define YYSTYPE double */
int yylex();
int yyerror(char*);
void execerror(char*, char*);
double mem[26];
%}
%union {
        double val;
        int index;
}
%token <val> NUMBER
%token <index> VAR
%type <val> expr
%right '='
%left '+' '-' /* left associative, same precedence */
%left '*' '/' /* left assoc, same precedence */
%left UNARYMINUS
%%
list:   /* nothing */
        | list '\n'
        | list expr '\n' { if ($2 == -0) $2 = 0.0; printf("\t%.8g\n", $2); }
        | list error '\n' { yyerrok; }
        ;
expr:   NUMBER
        | VAR { $$ = mem[$1]; }
        | VAR '=' expr { $$ = mem[$1] = $3; }
        | '-' expr %prec UNARYMINUS {
                if ($2 == 0.0) {
                        $$ = 0;
                }
                $$ = -$2; }
        | expr '+' expr { $$ = $1 + $3; }
        | expr '-' expr { $$ = $1 - $3; }
        | expr '*' expr { $$ = $1 * $3; }
        | expr '/' expr {
                if ($3 == 0.0) {
                        execerror("division by zero", "");
                }
                $$ = $1 / $3; }
        | '(' expr ')'  { $$ = $2; }
%%
#include <ctype.h>
#include <setjmp.h>
char *progname;
int lineno = 1;
jmp_buf begin;

int main(int argc, char* argv[])
{
        void fpecatch(int);

        progname = argv[0];
        setjmp(begin);
        signal(SIGFPE, fpecatch);
        yyparse();
        return 0;
}

void warning(char*, char*);
void execerror(char* s, char* t) {
        warning(s, t);
        longjmp(begin, 0);
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
                scanf("%lf", &yylval.val);
                return NUMBER;
        }
        if (islower(c)) {
                yylval.index = c-'a';
                return VAR;
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

