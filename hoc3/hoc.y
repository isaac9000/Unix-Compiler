%{
#include <signal.h>
#include <stdio.h>
#include <signal.h>
#include "init.h"
#include "hoc.h"
/*#define YYSTYPE double */
int yylex();
int yyerror(char*);
void execerror(char*, char*);
%}
%union {
        double val;
        Symbol *sym;
}
%token <val> NUMBER
%token <sym> VAR BLTIN UNDEF
%type <val> expr asgn
%right '='
%left '+' '-' /* left associative, same precedence */
%left '*' '/' /* left assoc, same precedence */
%left UNARYMINUS
%right '^'
%%
list:   /* nothing */
        | list '\n'
        | list asgn '\n'
        | list expr '\n' { if ($2 == -0) $2 = 0.0; printf("\t%.8g\n", $2); }
        | list error '\n' { yyerrok; }
        ;
asgn:    VAR '=' expr { $$ = $1->u.val = $3; $1->type = VAR; }
        ;
expr:   NUMBER
        | VAR { if ($1->type == UNDEF) {
                execerror("undefined variable", $1->name);
                }
                $$ = $1->u.val; }
        | asgn
        | BLTIN '(' expr ')' { $$ = (*($1->u.ptr))($3); }
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
        init();
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
        if (isalpha(c)) {
                Symbol *s;
                char sbuf[100], *p = sbuf;
                do {
                        *p++ = c;
                } while ((c = getchar()) != EOF && isalnum(c));
                ungetc(c, stdin);
                *p = '\0';
                if ((s = lookup(sbuf)) == 0) {
                        s = install(sbuf, UNDEF, 0.0);
                }
                yylval.sym = s;
                return s->type == UNDEF ? VAR : s->type;
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

