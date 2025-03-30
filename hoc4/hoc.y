%{
#include <stdio.h>
#include <signal.h>
#include "init.h"
#include "code.h"
#include "hoc.h"
#include "dis.h"
/*#define YYSTYPE double */
int yylex();
int yyerror(char*);
void execerror(char*, char*);
#define code2(c1,c2)	code(c1); code(c2)
#define code3(c1,c2,c3)	code(c1); code(c2); code(c3)
%}
%union {
        Symbol	*sym;
	Inst	*inst;
}
%token <sym> NUMBER VAR BLTIN UNDEF
%right '='
%left '+' '-' /* left associative, same precedence */
%left '*' '/' /* left assoc, same precedence */
%left UNARYMINUS
%right '^'
%%
list:   /* nothing */
        | list '\n'
        | list asgn '\n' { code2((Inst)pop, STOP); return 1; }
        | list expr '\n' { code2((Inst)print, STOP); return 1; }
        | list error '\n' { yyerrok; }
        ;
asgn:    VAR '=' expr { code3((Inst)varpush, (Inst)$1, (Inst)assign); }
        ;
expr:   NUMBER	{ code2((Inst)constpush, (Inst)$1); }
        | VAR	{ code3((Inst)varpush, (Inst)$1, (Inst)evalop); }
        | asgn 
        | BLTIN '(' expr ')' { code2((Inst)bltin, (Inst)$1->u.ptr); }
	| '(' expr ')'
        | expr '+' expr { code((Inst)addop); }
        | expr '-' expr { code((Inst)subop); }
        | expr '*' expr { code((Inst)mulop); }
        | expr '/' expr { code((Inst)divop); }
	| expr '^' expr { code((Inst)powerop); }
	| '-' expr %prec UNARYMINUS { code((Inst)negateop); }
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
	for (initcode(); yyparse(); initcode()) {
		char ** disarray = NULL; 
		int dislength = 0;
		disarray = disassemble(&dislength);
		for (int i = 0; i < dislength; i++) {
			printf("%s\n", disarray[i]);
		} 
		execute(prog);
	}
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
		double d;
                ungetc(c, stdin);
                scanf("%lf", &d);
		yylval.sym = install("", NUMBER, d);
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

