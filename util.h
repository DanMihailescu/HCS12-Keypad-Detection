/* Prints a single hex-digit (0..15 only) on the serial channel
 * Example: If digit is 9d, then '9' is printed on the serial channel
 * Example: If digit is 10d, then 'A' is printed on the serial channel
 *
 * @param	digit		An unsigned byte number containing only a number from 0..15 (high nibble is zero)
 */
void printHex (char digit);


/* Prints the given character on the serial channel 
 * @param	character	A legal printable ASCII character
 */
void printChar( char character);


/* Prints the string on the serial channel
 * @param	string		A pointer to a null-terminated array of legal printable ASCII characters
 */
void printStr( char* string);


/* Returns the numeric equivalent of the decimal string.
 * @param string A null-terminated string denoting a valid positive decimal number, eg '1234' = 1234d
 * @return	 An unsigned int containing the decimal value equivalent to string
 */
unsigned int convertToDecimal(char *string);

/* Returns the decimal string equivalent of num, with leading zeros in 
 * the hundreds and tens columns (so that the returned string is always three digits long)
 * @param num	An unsigned byte number (maximum value = 255)
 * @param string A pointer to a null-terminated string of at least 4 bytes (3 digits+1terminator)
 *		 in which the subroutine will store the string equivalent of num
 */
void convertToString(char num, char *string);


/* Extracts and returns the row and column information from the code, returning true
 * if the code contains valid row/column values. Return false (-1) if not.
 * 
 * boolean getRowColumn( unsigned byte code, &unsigned byte row, & unsigned byte column)
 * @param  code is a byte divided up into two nibbles, 
 *		the high nibble being the column identifier
 *		the low nibble being the row identifier
 *     Both identifiers are not numbers but are instead bit masks with a one in the bit
 *     position corresponding to the row/column, and all other bit positions zero.
 *           eg. A nibble 0001 has a one in bit position 0 and therefore identifies row/column 0
 *	     eg. A nibble 1000 has a one in bit position 3 and therefore identifies row/column 3
 * @param row  A pointer to an unsigned byte in which the subroutine will return the row, 0..3
 * @param column A pointer to an unsigned byte in which the subroutine will return the column, 0..3
 * @return  0 if the code had two valid identifiers (one 1 and rest zero).
 *	    -1 if either row/column identifier had an invalid format (eg. more than one 1 or no 1's at all)
 */
char getRowColumn(char code, char *row, char *column);

/* Returns the ASCII character corresponding to the [row][column] location on the keypad
 * See the HC12 boards in the lab for the layout of the keypad.
 * @param row   An unsigned byte from 0 to 3, where 0 is the topmost row.
 * @param column An unsigned byte from 0 to 3, where 0 is the leftmost column.
 * @return ASCII character '1' to '9' or 'A' to 'F'.
 */
char getChar(char row, char column);






