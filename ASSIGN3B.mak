CC = icc12w
LIB = ilibw
CFLAGS =  -IC:\icc\include\ -e -D__ICC_VERSION=708 -D__BUILD=0  -l 
ASFLAGS = $(CFLAGS) 
LFLAGS =  -LC:\icc\lib\ -nb:0 -btext:0x4000 -bdata:0x1000 -s2_s1 -dinit_sp:0x3dff -fmots19
FILES = assign3b.o util.o 

ASSIGN3B:	$(FILES)
	$(CC) -o ASSIGN3B $(LFLAGS) @ASSIGN3B.lk  
assign3b.o: .\..\ASSIGN~1\hcs12dp256.h C:\iccv712\include\hc12def.h .\..\ASSIGN~1\util.h C:\iccv712\include\stdio.h C:\iccv712\include\stdarg.h C:\iccv712\include\_const.h
assign3b.o:	..\ASSIGN~1\assign3b.c
	$(CC) -c $(CFLAGS) ..\ASSIGN~1\assign3b.c
util.o:	..\ASSIGN~1\util.s
	$(CC) -c $(ASFLAGS) ..\ASSIGN~1\util.s
