#ifndef HOC_H
#define HOC_H
#include "symbol.h"

Symbol *install(char *s, int t, double d);
Symbol *lookup(char *s);

typedef union Datum {
	double val;
	Symbol *sym;
} Datum;
extern Datum pop();
typedef int (*Inst)();
#define STOP	(Inst) 0

extern  Inst prog[];
void eval(), add(), sub(), mul(), div(), negate(), power();
void assign(), bltin(), varpush(), constpush(), print();
extern Inst *code(Inst);
#endif
