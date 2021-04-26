CC=gcc
CFLAGS=-fPIC
LDFLAGS=-shared

all: cptrace.so anti

cptrace.so: cptrace.o
	$(CC) -o $@ $^ $(LDFLAGS)

cptrace.o: cptrace.c
	$(CC) $(CFLAGS) -c -o $@ $^

anti: anti-debug.o
	$(CC) -o $@ $^ 

%.o: %.c
	$(CC) -c -o $@ $^

clean:
	rm -f cptrace.o
	rm -f cptrace.so
	rm -f anti-debug.o
	rm -f anti

.PHONY: all clean
