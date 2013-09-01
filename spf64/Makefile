CC=gcc
LIBS = -ldl -m64

all: spf64

spf64:  main.o amain.o clibs.o
	$(CC) -o  spf64 amain.o main.o clibs.o $(LIBS) -Wl,-Map,messy.map
	objdump -h -S -C -r spf64 > spf64.lss

main.o: main.c
	$(CC) -c -g -m64 -mtune=i686 main.c
	objdump -x -S main.o > main.lss

clibs.o: clibs.c
	$(CC) -c -g -m64 -mtune=i686 clibs.c

amain.o: spf/amain.S spf/img.s
	$(CC) -c -g -m64 -mtune=i686 spf/amain.S 

spf/img.s:  spf/src/linux/*.f spf/src/compiler/*.f spf/src/*.f spf/_mak/djgpp/gdis.f
	spf/bbuild.sh


clean:
	-rm -f spf64
	-rm -f *.o