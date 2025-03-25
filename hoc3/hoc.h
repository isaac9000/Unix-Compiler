typedef struct Symbol {
        char *name;
        short type;
        union {
                double val;
                double (*ptr)(double);
        } u;
        struct Symbol * next;
} Symbol;

Symbol *install(char *s, int t, double d);
Symbol *lookup(char *s);

void execerror(char* s, char* t);
