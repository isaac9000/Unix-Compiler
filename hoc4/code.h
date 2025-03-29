#ifndef CODE_H
#define CODE_H
#include "symbol.h"

// Data on the evaluation stack
typedef union Datum {
        double val;
        Symbol *sym;
} Datum;

// Inst is the type of machine code
typedef int (*Inst)();

// These are machine operation code
void eval(), add(), sub(), mul(), div(), negate(), power();
void assign(), bltin(), varpush(), constpush(), print();
Datum pop();

// Code generation
Inst *code(Inst);

// Utility to simulate machine execution
void initcode();
void execute(Inst *);

// Array of machine code instructions
extern Inst prog[];

#define STOP    (Inst) 0



#endif
