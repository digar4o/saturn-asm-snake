************************************************************
************************************************************
**
**	Name: Snake Game
**	
**	Author: Martin Radulov
**	
**	Abstract: Written for the HP48S using a universal
**		  entry point list - uentries.o
**
**	Entry: 	None
**	Exit: 	None
**
**=========================================================
	

ASSEMBLE
	NIBASC /HPHP48-L/
RPL

::

 RECLAIMDISP
 TURNMENUOFF
	
 ABUFF

 #F
 ONE	
 MAKEGROB
 DO>STR
	
 56 TestSysFlag

CODE	

**********************************************************
*
* RPL code above creates the following objects on stack:
*
* L3: Address pointing to ABUFF (start of display memory)
* L2: String object of F*5 nibbles for variables
* L1: Contents of flag 56 (sound off/on)
*
**********************************************************
*
*    Status Flags in use (ST register):
*     
*



	ST=0	15		Interrupts off
	INTOFF			Turns off keyboard int.
	P=	0
	
	ST=0	11		Sound on
	GOSBVL	=popflag	Pop flag from stack L1 and set carry bit to 1 if TRUE
	GONC	DATA		Goto DATA if not set and keep sound on
	ST=1	11		Otherwise, turn that shit off


DATA				Lets store some initial values
	GOSBVL	=SAVPTR		Save RPL pointers so they can be restored on game exit
	A=DAT1	A		Read variable string pointer into A
	A=A+CON	A,10		Add 10 nibbles to skip past string header/prolog
	R0=A.F	A		Keep this in R0 scratch register
	D1=D1+	5		Go ahead to next stack level 5 nibbles ahead
	A=DAT1	A		Read ABUFF pointer
	LC(5)	20
	C=C+A	A		Skip 20 nibbles past ABUFF prolog to pointer address
	GOSUB 	srS5		Save in 5th set of 5 nibble of string
	GOSUB 	INIT		Skip executing storage routines

********************************************************
*
* Variable storage system goes here, put value to store
* into A[A] 
*
********************************************************

srR0	LC(5)	0		
	GOTO srRC		Pass number of variable to store into to srRC

srR1    LC(5)   1               
        GOTO srRC              

srR2    LC(5)   2 
        GOTO srRC   

srR3    LC(5)   3 
        GOTO srRC   

srR4    LC(5)   4 
        GOTO srRC   

srR5    LC(5)   5 
        GOTO srRC   

srR6    LC(5)   6 
        GOTO srRC   

srR7    LC(5)   7 
        GOTO srRC   

srR8    LC(5)   8 
        GOTO srRC   

srR9    LC(5)   9 
        GOTO srRC   

srR10   LC(5)   10 
        GOTO srRC   

srR11   LC(5)   11 
        GOTO srRC   

srR12   LC(5)   12 
        GOTO srRC   

srR13   LC(5)   13 
        GOTO srRC   

srR14    LC(5)   14 

        
srRC	ACEX	A		Swaps A and C registers
	CD0EX			Swaps C and D0
	RSTK=C			Let's keep the original value of D0 on stack so we can restore it
	C=A	A		C now contains number of variable to store into
	C=C+C	A		Several additions to multiply by 5 and get offset to store into
	C=C+C	A
	C=C+A	A
	A=R0.F	A		Get address of variable string
	A=A+C	A		Add offset
	AD0EX			Address now in D0, also restores A[A]
	C=DAT0	A	
	CD0EX
	C=RSTK			Restore D0 value and put value of variable into C
	CD0EX
	RTN


srS0	RSTK=C			Moves value to store from C to RSTK
	LC(5)	0		Loads variable no. to store into to C
	GOTO srSC

srS1    RSTK=C
        LC(5)   1
        GOTO srSC

srS2    RSTK=C
        LC(5)   2
        GOTO srSC

srS3    RSTK=C
        LC(5)   3
        GOTO srSC

srS4    RSTK=C
        LC(5)   4
        GOTO srSC

srS5    RSTK=C
        LC(5)   5
        GOTO srSC

srS6    RSTK=C
        LC(5)   6
        GOTO srSC

srS7    RSTK=C
        LC(5)   7
        GOTO srSC

srS8    RSTK=C
        LC(5)   8
        GOTO srSC

srS9    RSTK=C
        LC(5)   9
        GOTO srSC

srS10   RSTK=C
        LC(5)   10
        GOTO srSC

srS11   RSTK=C
        LC(5)   11
        GOTO srSC

srS12   RSTK=C
        LC(5)   12
        GOTO srSC

srS13   RSTK=C
        LC(5)   13
        GOTO srSC

srS14   RSTK=C
        LC(5)   14
        
srSC	GOSBVL	=ASLW5		Calls ROM routine to shift A left 5 nibbles to preserve A[A] value
	AD0EX			Get D0 into A[A]
	GOSBVL	=ASLW5		Shift another 5 nibbles to the right to save D0
	A=C	A
	C=C+C	A	
	C=C+C	A	
	C=C+A	A
	A=R0.F 	A
	A=A+C	A	
	D0=A	
	C=RSTK
	DAT0=C 	A		Write value into correct part of string	
	GOSBVL =ASRW5		Start shifting back to restore DO and A[A]
	D0=A	
	GOSBVL =ASRW5
	RTN


INIT
	C=0	A		Y co-ord top line
	GOSUB	srS0		

	LC(5)	8		Y co-ord middle line for scoreboard
	GOSUB 	srS1		

	LC(5)	63		Y co-ord bottom line
	GOSUB	srS2
	
	LC(5)	22		Starting x co-ord for snake, constant for now, randomise later
	GOSUB	srS3	

	LC(5)	75		Starting y co-ord for snake
	GOSUB	srS4	

	GOSUB	drawScreen	Draw empty screen, lines and score text
	

drawScreen
	GOSUB srR0		Top Line
	LA(5)	34
	GOSBVL	=MUL#		Multiply row size by numbers of row to get offset
	GOSUB	srR5		Load ABUFF pointer
	C=C+B	A		Add offet to start to get address for line start now in C
	GOSUB drawLine		go draw top line
	GOSUB 	srR1
	LA(5)	34
	GOSBVL	=MUL#		
	GOSUB	srR5
	C=C+B	A
	GOSUB	drawLine	go draw middle line
	GOSUB	srR2
	LA(5)	34
	GOSBVL	=MUL#
	GOSUB 	srR5
	C=C+B	A
	GOSUB	drawLine	go draw top line
	

keyLoop				Start keyboard loop, just exits on space for now
	LC(3)	001
	OUT=C
	GOSBVL	#01160
	?CBIT=0	1
	GOYES	keyLoop
	ST=1	15
	GOVLNG	=GETPRTLOOP	Exits
	

drawLine			Call this to draw a line that spans a row, load y-coord into C before jmp
	D0=C	A
	C=0	W
	C=C-1	W		load FFFFFF into C,warning carry bit set now
	DAT0=C	W
	D0=D0+	16		Drawing two sets of 64 pixels (W field) and one set of 8 (B field)	
	DAT0=C	W	
	D0=D0+	16
	DAT0=C	B	
	RTN

	
ENDCODE
	TURNMENUON
	RECLAIMDISP


;











	












			 
