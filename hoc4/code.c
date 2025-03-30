#include <stdio.h>
#include <math.h>
#include "symbol.h"
#include "code.h"
#include "y.tab.h"

static Datum stack[NSTACK];
static Datum *stackp;

Inst prog[NPROG];
Inst *progp;
Inst *pc;

void initcode() {
	stackp = stack;
	progp = prog;
}

void push(Datum d) {
	if (stackp >= &stack[NSTACK]) {
		execerror("stack overflow", (char*) 0);
	}
	*stackp++ = d;
}

Datum pop() {
	if (stackp <= stack) {
		execerror("stack underflow", (char*) 0);
	}
	return *--stackp;
}

Inst *code(Inst f){
	Inst *oprogp = progp;
	if (progp >= &prog[NPROG]) { 
		execerror("program too big", (char*) 0);
	}
	*progp++ = f;
	return oprogp;
}
void execute (Inst* p) {
	for (pc = p; *pc != STOP; ) {
		(*(*pc++))();
	}
}	

void constpush() {
	Datum d;
	d.val = ((Symbol *)*pc++)->u.val;
	push(d);
}

void varpush() {
	Datum d;
	d.sym = (Symbol *)(*pc++);
	push(d);
}

void addop() {
	Datum d1, d2;
	d2 = pop();
	d1 = pop();
	d1.val += d2.val;
	push(d1);
}

void subop() {
	Datum d1, d2;
	d2 = pop();
	d1 = pop();
	d1.val -= d2.val;
	push(d1);	
}

void mulop() {
	Datum d1, d2;
	d2 = pop();
	d1 = pop();
	d1.val *= d2.val;
	push(d1);
}

void divop() {
	Datum d1, d2;
	d1 = pop();
	d2 = pop();
	d2.val /= d1.val;
	push(d2);
}

void negateop() {
	Datum d1;
	d1 = pop();
	d1.val *= -1;
	push(d1);
}

void powerop() {
	Datum d1, d2;
	d1 = pop();
	d2 = pop();
	d1.val = pow(d2.val, d1.val);
	push(d1);
}
void evalop() {
	Datum d;
	d = pop();
	if (d.sym->type == UNDEF) {
		execerror("undefined variable", d.sym->name);
	}	
	d.val = d.sym->u.val;
	push(d);
}

void assign() {
	Datum d1, d2;
	d1 = pop();
	d2 = pop();
	if (d1.sym->type != VAR && d1.sym->type != UNDEF) {
		execerror("assignment to non-variable", d1.sym->name);
	}
	d1.sym->u.val = d2.val;
	d1.sym->type = VAR;
	push(d2);
}	

void print() {
	Datum d;
	d = pop();
	printf("\t%.8g\n", d.val);
}

void bltin() {
	Datum d;
	d = pop();
	d.val = (*(double (*) (double))(*pc++))(d.val);
	push(d);
}
