	.module assign3b.c
	.area text
;              c -> 1,SP
_putchar$device_specific$::
	pshd
; #include "hcs12dp256.h"
; #include "util.h"
; #include <stdio.h>
; 
; #pragma nonpaged_function putchar
; int putchar(char c){
L4:
; 	while((SCI0SR1 & 0x80) == 0) { } 
L5:
	brclr 0xcc,#128,L4
; 	SCI0DRL = c;
	movb 1,S,0xcf
; 	return c;
	ldab 1,S
	clra
L3:
	.dbline 0 ; func end
	leas 2,S
	rts
;              i -> 0,SP
_pollKeypad::
	leas -1,S
; }
; 
; // Scans the entire keypad once, each row in turn, and returns the row/column of the
; // first key press it detects.
; // Return the two values (row,column) within a single byte but putting the row value in
; // the lower nibble and the column value in the higher nibble of the return value.
; // Returns -1 if no key is being pressed at the time.
; char pollKeypad()
; {
; 	char i; //Basic counter
; 	SPI1CR1 = 0x00; 
	clr 0xf0
; 	DDRP = 0x0F;
	movb #15,0x25a
; 	DDRH = 0x00;
	clr 0x262
; 	PTP = 0x01; // For row 1
	movb #1,0x258
; 	PTM = 0x08; 
	movb #8,0x250
; 	DDRK = 0x20;
	movb #32,0x33
; 	for(i =1; i<= 8; i *= 2)
	movb #1,0,S
	bra L11
L8:
; 	{
; 		PTP = i;   //Increases row
	movb 0,S,0x258
; 		if((PTH & 0xF0) == 0x10){    // Checks column 1 
	ldab 0x260
	andb #240
	cmpb #16
	bne L12
; 			PTM= 0x00; // clears port M
	clr 0x250
; 			return 0x10 + i;
	ldab 0,S
	addb #16
	clra
	bra L7
L12:
; 		}
; 		else if((PTH & 0xF0) == 0x20){  // Checks column 2
	ldab 0x260
	andb #240
	cmpb #32
	bne L14
; 			PTM= 0x00; 
	clr 0x250
; 			return 0x20 + i;
	ldab 0,S
	addb #32
	clra
	bra L7
L14:
; 		}
; 		else if((PTH & 0xF0) == 0x40){  // Checks column 3
	ldab 0x260
	andb #240
	cmpb #64
	bne L16
; 			PTM= 0x00; 
	clr 0x250
; 			return 0x40 + i;
	ldab 0,S
	addb #64
	clra
	bra L7
L16:
; 		}
; 		else if((PTH & 0xF0) == 0x80){  // Checks column 4
	ldab 0x260
	andb #240
	cmpb #128
	bne L18
; 			PTM= 0x00; 
	clr 0x250
; 			return 0x80 + i;
	ldab 0,S
	addb #128
	clra
	bra L7
L18:
; 		}
; 	}
L9:
	ldab 0,S
	clra
	lsld
	stab 0,S
L11:
	ldab 0,S
	cmpb #8
	bls L8
; 	return -1;  //Returned if no value is found
	ldd #255
L7:
	.dbline 0 ; func end
	leas 1,S
	rts
L21:
	.byte 49,50
	.byte 51,'A
	.byte 52,53
	.byte 54,'B
	.byte 55,56
	.byte 57,'C
	.byte 'E,48
	.byte 'F,'D
;          array -> 6,SP
;         column -> 22,SP
;            row -> 23,SP
;        inRange -> 24,SP
;      rowColumn -> 26,SP
_mapRCtoChar::
	pshd
	leas -25,S
; }
; 
; // Maps a (row,column) pair of a keypad button into its respective ASCII character
; // @param rowColumn Contains the position of a keypad button, encoded as a row in the low 4 bits and a column position in the high 4 bits
; // Returns NULL if the (row,column) positions are out-of-bounds.
; char mapRCtoChar(char rowColumn)
; {
; 	char row;
; 	char column;
; 	char array[4][4] = {{'1','2','3','A'},   //Creates 4x4 arrow to simulate keypad
	ldy #L21
	leax 6,S
	ldd #8
X0:
	movw 2,Y+,2,X+
	dbne D,X0
;   	    			   	{'4','5','6','B'},
; 					    {'7','8','9','C'},
; 					    {'E','0','F','D'}};
; 	char inRange  = getRowColumn(rowColumn, &row, &column);
	leay 22,S
	sty 2,S
	leay 23,S
	sty 0,S
	ldab 26,S
	clra
	jsr _getRowColumn
	stab 24,S
; 	if (inRange == 0){ return array[row][column]; }
	cmpb #0
	bne L22
	leay 6,S
	ldab 23,S
	clra
	lsld
	lsld
	sty 4,S
	addd 4,S
	tfr D,Y
	ldab 22,S
	clra
	sty 4,S
	addd 4,S
	tfr D,Y
	ldab 0,Y
	clra
	bra L20
L22:
; 	else{ return NULL; }
	ldd #0
L20:
	.dbline 0 ; func end
	leas 27,S
	rts
;           temp -> 2,SP
;          final -> 3,SP
_main::
	leas -4,S
; }
;  
; void main(void)
; {
; 	char final;
; 	char temp = 0;
	clr 2,S
	bra L26
L25:
; 	while (1){
; 		final = mapRCtoChar(pollKeypad());  //Gets input
	jsr _pollKeypad
	clra
	jsr _mapRCtoChar
	stab 3,S
; 		if(final != NULL && final != temp){ //Makes sure a button is pressed
	cmpb #0
	beq L28
	ldab 3,S
	cmpb 2,S
	beq L28
; 			temp = final;
	movb 3,S,2,S
; 			printf("\n");
	ldy #L30
	sty 0,S
	jsr _printf
; 			printChar(final);
	ldab 3,S
	clra
	jsr _printChar
; 			if (final >= 0x30 && final < 0x40){
	ldab 3,S
	cmpb #48
	blo L31
	ldab 3,S
	cmpb #64
	bhs L31
; 				final -= 0x30;
	ldab 3,S
	subb #48
	stab 3,S
; 				PTM = 0x08;
	movb #8,0x250
; 				DDRT = 0x0F;
	movb #15,0x242
; 				PTT = final;
	movb 3,S,0x240
; 				PTM = 0x00;
	clr 0x250
; 			}
L31:
; 		}
L28:
;     }
L26:
	bra L25
X1:
L24:
	.dbline 0 ; func end
	leas 4,S
	rts
L30:
	.byte 10,0
