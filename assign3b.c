#include "hcs12dp256.h"
#include "util.h"
#include <stdio.h>

#pragma nonpaged_function putchar
int putchar(char c){
	while((SCI0SR1 & 0x80) == 0) { } 
	SCI0DRL = c;
	return c;
}

// Scans the entire keypad once, each row in turn, and returns the row/column of the
// first key press it detects.
// Return the two values (row,column) within a single byte but putting the row value in
// the lower nibble and the column value in the higher nibble of the return value.
// Returns -1 if no key is being pressed at the time.
char pollKeypad()
{
	char i; //Basic counter
	SPI1CR1 = 0x00; 
	DDRP = 0x0F;
	DDRH = 0x00;
	PTP = 0x01; // For row 1
	PTM = 0x08; 
	DDRK = 0x20;
	for(i =1; i<= 8; i *= 2)
	{
		PTP = i;   //Increases row
		if((PTH & 0xF0) == 0x10){    // Checks column 1 
			PTM= 0x00; // clears port M
			return 0x10 + i;
		}
		else if((PTH & 0xF0) == 0x20){  // Checks column 2
			PTM= 0x00; 
			return 0x20 + i;
		}
		else if((PTH & 0xF0) == 0x40){  // Checks column 3
			PTM= 0x00; 
			return 0x40 + i;
		}
		else if((PTH & 0xF0) == 0x80){  // Checks column 4
			PTM= 0x00; 
			return 0x80 + i;
		}
	}
	return -1;  //Returned if no value is found
}

// Maps a (row,column) pair of a keypad button into its respective ASCII character
// @param rowColumn Contains the position of a keypad button, encoded as a row in the low 4 bits and a column position in the high 4 bits
// Returns NULL if the (row,column) positions are out-of-bounds.
char mapRCtoChar(char rowColumn)
{
	char row;
	char column;
	char array[4][4] = {{'1','2','3','A'},   //Creates 4x4 arrow to simulate keypad
  	    			   	{'4','5','6','B'},
					    {'7','8','9','C'},
					    {'E','0','F','D'}};
	char inRange  = getRowColumn(rowColumn, &row, &column);
	if (inRange == 0){ return array[row][column]; }
	else{ return NULL; }
}
 
void main(void)
{
	char final;
	char temp = 0;
	while (1){
		final = mapRCtoChar(pollKeypad());  //Gets input
		if(final != NULL && final != temp){ //Makes sure a button is pressed
			temp = final;
			printf("\n");
			printChar(final);
			if (final >= 0x30 && final < 0x40){
				final -= 0x30;
				PTM = 0x08;
				DDRT = 0x0F;
				PTT = final;
				PTM = 0x00;
			}
		}
    }
}

				 
			 	