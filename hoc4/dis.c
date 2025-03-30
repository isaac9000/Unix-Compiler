#include <stdio.h>
#include <stdlib.h>
#include "code.h"


char disflag = 'i';
// Gotta turn the thing into Symbol * and find its u.val or some shit
char * disarray[NPROG];
char** disassemble(int * size) {
	int i = 0;
	char * str = NULL;
	Symbol * sym = NULL;
	// end at STOP	
	while (i < NPROG && !(prog[i] == STOP)) {
		switch (disflag) {
			case 'i': 
				if (prog[i] == (Inst)evalop) {
                        		disarray[i] = "evalop";
                		} else if (prog[i] == (Inst)addop) {
                        		disarray[i] = "addop";
              			} else if (prog[i] == (Inst)subop) {
                        		disarray[i] = "subop";
                		} else if (prog[i] == (Inst)mulop) {
                        		disarray[i] = "mulop";
                		} else if (prog[i] == (Inst)divop) {
                        		disarray[i] = "divop";
                		} else if (prog[i] == (Inst)negateop) {
                        		disarray[i] = "negateop";
                		} else if (prog[i] == (Inst)powerop) {
                        		disarray[i] = "powerop";
                		} else if (prog[i] == (Inst)assign) {
                        		disarray[i] = "assign";
                		} else if (prog[i] == (Inst)bltin) {
                        		disarray[i] = "bltin";
					disflag = 's';
                		} else if (prog[i] == (Inst)varpush) {
                        		disarray[i] = "varpush";
					disflag = 's';
                		} else if (prog[i] == (Inst)constpush) {
                        		disarray[i] = "constpush";
					disflag = 's';
                		} else if (prog[i] == (Inst)print) {
                        		disarray[i] = "print";
                		} else if (prog[i] == (Inst)pop) {
                                        disarray[i] = "pop"; 
				} else {
					disarray[i] = "not recognized";
				}
				break;
			case 's':
				sym = ((Symbol*)(prog[i]));
				str = malloc(100*sizeof(char));
				sprintf(str, "name: %s, type: %d, value: 0x%lx", sym->name, sym->type, (unsigned long)sym->u.val);
				disarray[i] = str; 
				disflag = 'i';
				break;
		}		
		i++;
	}
	*size = i;
	return disarray;
}

void destroy() {
	
}
