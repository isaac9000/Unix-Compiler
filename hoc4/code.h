#ifndef CODE_H
#define CODE_H
#include "symbol.h"

// For code.c and diss.c to change the size of the machine code array and evaluation stack
#define NPROG 2000
#define NSTACK 256

// Data on the evaluation stack
typedef union Datum {
        double val;
        Symbol *sym;
} Datum;

// Inst is the type of machine code
typedef int (*Inst)();

// These are machine operation code
void evalop(), addop(), subop(), mulop(), divop(), negateop(), powerop();
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
