; SYSC-2003 Winter 2007 Supplied code

; SYSC 2003 Assignment 3(modified from assignment 2 solutions)
; 
; Dan Mihailescu
; March 12, 2016
; 
; Util 

TRUE	= 1
FALSE	= 0

	
; void printHex (char hexNumber)
;   D (in B) is hexNumber, a number from 0..15
;
_printHex::
       andb  #$0f      ; mask off bits
       cmpb  #$09      ; compare to number
       bhi   above9    ; branch if a thru f
       addb  #$30      ; add standard offset
       bra hex
above9:
       addb  #$37      ; change a-f to ascii
hex:
       jsr   printChar
       rts
	   
REGBS  = $0000 
SC0SR1 = REGBS+$CC
SC0DRL = REGBS+$CF

; void printChar( char character)
;    D (in B) is character.
_printChar::
 	pshd
here:   
    brCLR  SC0SR1,#$80,here
;	LDAB	SC0SR1	; read status
;	BITB	#$80  	; test Transmit Data Register Empty bit
;	BEQ	OUTSCI2	; loop if TDRE=1
;	ANDA	#$7F   	; mask parity
	STAB	SC0DRL	; send character
	puld
    rts
		 
; void printStr( char* string)
;    D contains address of null-terminated string.
_printStr::
     pshd
     pshy
	 xgdy
nextCharInStr:
	 ldab 1,y+
	 cmpb #0x00
	 beq printStrDone
	 jsr printChar	
	bra nextCharInStr
printStrDone:
    puly
	puld
    rts
    
    
; unsigned int convertToDecimal(char *string)
; 
; Returns the numeric equivalent of the decimal string.
;
; param -  D contains address of a null-terminated string denoting a valid positive decimal number, eg '1234' = ; 1234d
; return - An unsigned int containing the decimal value equivalent to string
_convertToDecimal::
	pshx
	pshy
	xgdx
	ldd #0
	ldy #0
convertNextChar:
	ldab 1, x+
	cmpb #0
	beq convertToDecimalDone
	
	; Convert from ASCII to numerical value
	subb #$30
		
	; Shift and add the next value
	pshd
	
	
	; Shift by a factor of 10
	ldd #10		
	emul
	
	; Add the next value
	addd 0, sp
	
	; Put the sum back in y and pull b
	xgdy
	puld
		

	; Get the next character
	bra convertNextChar
	
convertToDecimalDone:
	xgdy
	pulx
	puly
	rts
	

; void convertToString(char num, char *string)
; 
; Returns the decimal string equivalent of num, with leading zeros in 
; the hundreds and tens columns (so that the returned string is always three digits long)
;  
; param - num Passed in b - An unsigned byte number (maximum value = 255)
; param - Address passed on stack - string A pointer to a null-terminated string of at least 4 bytes (3 digits+1terminator) in which the subroutine will store the string equivalent of num
; 

_convertToString::
	pshd
	pshx
	pshy
	
	ldaa #0
	ldx  #0
	xgdy			; Put the parameter in Y
	ldd 8, sp		; Get the address of string
	addd #4			; Get the address slot for the last element
	xgdy			; Put the address in Y and the parameter back in D
	
	clr 1, -y		; Set the null terminator for the string and decrement the address pointer
	
convertNextNumberToString:
	ldx #10			; Number to divide by
	idiv			; Divide number by 10
	addd #$30		; Convert to ASCII
	stab 1, -y		; Store the ASCII value and 
	tfr x, d		; Put the remaining number in D
	cpy 8, sp		; Check if we are at the starting address
	bne convertNextNumberToString
	
	
convertToStringDone:
	puly
	pulx
	puld
	rts


; char getRowColumn(char code, char *row, char *column)
; Extracts and returns the row and column information from the code, returning true
; if the code contains valid row/column values. Return false (-1) if not.
;
; param code is a byte divided up into two nibbles, 
;		the high nibble being the column identifier
;		the low nibble being the row identifier
;    	Both identifiers are not numbers but are instead bit masks with a one in the bit
;   	position corresponding to the row/column, and all other bit positions zero.
;        eg. A nibble 0001 has a one in bit position 0 and therefore identifies row/column 0
;	     eg. A nibble 1000 has a one in bit position 3 and therefore identifies row/column 3
;
; param row  A pointer to an unsigned byte in which the subroutine will return the row, 0..3
; param column A pointer to an unsigned byte in which the subroutine will return the column, 0..3
; return  0 if the code had two valid identifiers (one 1 and rest zero).
;-1 if either row/column identifier had an invalid format (eg. more than one 1 or no 1s at all)
;

_getRowColumn::
	psha
	pshx
	pshy
	
	ldy 9, sp			; Get address of row return

getRowColumnInit:	
	; Initialize the values
	ldaa	#4				; Bits in a nibble
	ldx		#$FFFF			; Potential return of -1
	
getRowColumnLoop:	
	cmpa #0
	beq getRowColumnLoopCheck	; Terminating case, no more bits to check
	deca						; Decrement a
	
	lslb					; Rotate the bits left
	bcc getRowColumnLoop	; If there was no bit set the loop again
	
getRowColumnFound:
	cpx #$FFFF
	bne getRowColumnError	; There has already been a 1 in the sequence so abort with -1
	staa 0, y
	ldx  #0
	bra getRowColumnLoop
	
getRowColumnLoopCheck:
	cpy 7, sp				
	beq getRowColumnDone	; Make sure row and column are both done
	ldy 7, sp			
	bra getRowColumnInit	; Not done columns so do it again

getRowColumnError:
	ldx #$FF
	
getRowColumnDone:
	tfr x, b
	puly
	pulx
	pula
	rts
	
; char getChar(char row, char column)
; Returns the ASCII character corresponding to the [row][column] location on the keypad
; See the HC12 boards in the lab for the layout of the keypad.
; 
; param row   An unsigned byte from 0 to 3, where 0 is the topmost row.
; param column An unsigned byte from 0 to 3, where 0 is the leftmost column.
; return ASCII character '1' to '9' or 'A' to 'F'.

_getChar::
	psha
	pshx

	; Row is in b
	ldaa 6, sp ; Put column in a
	
	; If the row or column are 3 then the return will be a hex character
	cmpa #3
	beq getCharHexColumn
	cmpb #3
	beq getCharHexRow
		
	; If the first two cases are not true then we have a numeric value
	; Multiply the number of columns by the actual row and add the column plus 1
	; (R * 3) + C + 1
	
	tfr a, x		; Put column in X
	ldaa #3			; Load max number of rows in A
	mul				; Multiply row by 3 => B
	tfr x, a		; Put column in A
	aba				; Add A and B => A
	tab				; Transfer answer to B
	
	addb #$31		; Convert to ASCII + 1
	bra getCharDone


getCharHexColumn:
	tab
	addb #'A'
	bra getCharDone
	

getCharHexRow:
	cmpa #0
	beq getCharHexE	
	cmpa #1
	beq getCharZero	

getCharHexF:
	ldab #'F'
	bra getCharDone

getCharHexE:
	ldab #'E'
	bra getCharDone
	
getCharZero:
	ldab #'0'

getCharDone:
	pulx
	pula
	rts
