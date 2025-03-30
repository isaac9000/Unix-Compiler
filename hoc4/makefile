OBJS = hoc.o code.o dis.o init.o math.o symbol.o

YFLAGS = -d
CFLAGS += -g #enable debugging

hoc4:	$(OBJS)
	cc $(OBJS) -lm -g -o hoc4

hoc.o code.o init.o symbol.o:	hoc.h

code.o init.o symbol.o:	x.tab.h

x.tab.h:y.tab.h
	-cmp -s x.tab.h y.tab.h || cp y.tab.h x.tab.h

pr: 	hoc.y hoc.h code.c init.c math.c symbol.c
	@pr $?
	@touch pr
clean:
	rm -f $(OBJS) [xy].tab.[ch]
