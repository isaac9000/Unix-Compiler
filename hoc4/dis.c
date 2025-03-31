#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "code.h"

int disarraysize = 0;
char disflag = 'i';

char * disarray[NPROG];

char** disassemble(int * size) {
	int i = 0;

	char * str = NULL;
	Symbol * sym = NULL;
	while (i < NPROG && !(prog[i] == STOP)) {
		switch (disflag) {
			case 'i': 
				if (prog[i] == (Inst)evalop) {
					disarray[i] = strdup("evalop");
                		} else if (prog[i] == (Inst)addop) {
					disarray[i] = strdup("addop");
              			} else if (prog[i] == (Inst)subop) {
					disarray[i] = strdup("subop");
                		} else if (prog[i] == (Inst)mulop) {
					disarray[i] = strdup("mulop");
                		} else if (prog[i] == (Inst)divop) {
					disarray[i] = strdup("divop");
                		} else if (prog[i] == (Inst)negateop) {
					disarray[i] = strdup("negateop");
                		} else if (prog[i] == (Inst)powerop) {
					disarray[i] = strdup("powerop");
                		} else if (prog[i] == (Inst)assign) {
					disarray[i] = strdup("ass");
                		} else if (prog[i] == (Inst)bltin) {
					disarray[i] = strdup("bltin");
					disflag = 's';
                		} else if (prog[i] == (Inst)varpush) {
					disarray[i] = strdup("varpush");
					disflag = 's';
                		} else if (prog[i] == (Inst)constpush) {
					disarray[i] = strdup("constpush");
					disflag = 's';
                		} else if (prog[i] == (Inst)print) {
					disarray[i] = strdup("print");
                		} else if (prog[i] == (Inst)pop) {
					disarray[i] = strdup("pop");
				}
				break;
			case 's':
				sym = ((Symbol*)(prog[i]));
				str = malloc(100*sizeof(char));
				if (str == NULL) {
					printf("heap out of storage\n");
					*size = i;
					disarraysize = i;
					return disarray;
				}
				sprintf(str, "name: %s, type: %d, value: 0x%lx", sym->name, sym->type, (unsigned long)sym->u.val);
				disarray[i] = str; 
				disflag = 'i';
				break;
			default:
				disarray[i] = strdup("not recognized");
				break;
		}		
		i++;
	}
	*size = i;
	disarraysize = i;
	return disarray;
}

void destroy() {
	for (int i = 0; i < disarraysize; i++) {
		free(disarray[i]);
	}
}
