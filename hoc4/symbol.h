#ifndef SYMBOL_H
#define SYMBOL_H
typedef struct Symbol {
        char *name;
        short type;
        union {
                double val;
                double (*ptr)(double);
        } u;
        struct Symbol * next;
} Symbol;

// Installs into symbol table
Symbol *install(char *s, int t, double d);

// Searches the symbol table
Symbol *lookup(char *s);

// Prints out error message
void execerror(char* s, char* t);
#endif
