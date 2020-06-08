
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
* Status Flags in use (ST register):
* ST 0: UP
* ST 1: DOWN
* ST 2: LEFT
* ST 3: RIGHT
* ST 11: SOUND ON/OFF



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
	GOTO 	INIT		Skip executing storage routines

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
	ST=0	0		Clear all used status flags
	ST=0	1
	ST=0	2
	ST=0	3		But set 3 to 1, as snake will start by moving right
	ST=0	4
	ST=0	5
	ST=0	6

	C=0	A		Y co-ord top line
	GOSUB	srS0		

	LC(5)	8		Y co-ord middle line for scoreboard
	GOSUB 	srS1		

	LC(5)	63		Y co-ord bottom line
	GOSUB	srS2
	
	LC(5)	56		Starting x co-ord for snake, constant for now, randomise later
	GOSUB	srS3	

	LC(5)	30		Starting y co-ord for snake
	GOSUB	srS4	
	
	LC(5)	0		Store initial snake length in pixels
	GOSUB	srS6

	LC(5)	2000		Snake update delay in ticks
	GOSUB	srS7

	GOSUB	srR6		Get length
	A=C	A		Store in A
	A=A+A	A
	A=A+A	A		multiply by 4 to convert length into pixels
	GOSUB	srR3		Get initial x-coord into C
	C=C-A	A		Subtract length from initial x-coord
	GOSUB	srS8		Store x-coord of last block into S8

	GOSUB	srR4
	GOSUB	srS9		Stores y-coord of first square into y-coord of last as snake starts horiz.
	

	

	GOSUB	drawScreen	Draw empty screen, lines and score text
	
		
drawScreen
	GOSUB srR0		Top Line
	LA(5)	34
	GOSBVL	=MUL#		Multiply row size by numbers of row to get offset
	GOSUB	srR5		Load ABUFF pointer
	C=C+B	A		Add offset to start to get address for line start now in C
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
	GOSUB	drawLine	go draw bottom line
	GOSUB	drawTopText	go draw Score text
	GOSUB	srR6		get snake length
	D=C	A
	GOSUB	drawSnake 	go draw snake, call with number of squares in D

	
mainLoop
	GOSUB	delayInit	
keyLoop
	GOSUB	delayCheck	Update current time
	?ST=0	5		Has timer expired?
	GOYES	keyLoopc
	GOSUBL	updateSnake	Yes? Go do snake update
	

keyLoopc
	LCHEX	5FF		Check if any key is being pressed on keyboard including [ON]
	OUT=C
	GOSBVL	=CINRTN
	LAHEX	0803F		IN mask for all keys, found using OR on all IN values
	A=A&C	A
	?A#0	A
	GOYES	keySpc		go check if its space being pressed
	GOTO	keyLoop		Otherwise check again

keySpc	LC(3)	001		Check if [SPC] is being pressed
	OUT=C
	GOSBVL	=CINRTN
	?CBIT=0	1
	GOYES	keyUp		No? Check next key	
	ST=1	15		Yes? Return to RPL
	GOSBVL	=GETPTR
	GOVLNG	=LOOP	Exits

keyUp
	LCHEX	080
	OUT=C
	GOSBVL	=CINRTN
	?CBIT=0	1
	GOYES	keyLeft		No? Go check left?
	ST=1	0		Yes? Set the UP movement flag and return to loop
	ST=0	1
	ST=0	2
	ST=0	3
	GOTO	keyLoop

keyLeft
	LCHEX   040
        OUT=C
        GOSBVL  =CINRTN
        ?CBIT=0 2
        GOYES   keyDown		No? Go check down
        ST=0    0		Yes? Set the left movement flag and return to loop
        ST=0    1
        ST=1    2
        ST=0    3
	GOTO keyLoop


keyDown
        LCHEX   040
        OUT=C
        GOSBVL  =CINRTN
        ?CBIT=0	1
        GOYES   keyRight	No? Go check left?
        ST=0	0		Yes? Set the UP movement flag and return to loop
        ST=1    1
        ST=0    2
        ST=0    3
        GOTO keyLoop

keyRight
	LCHEX   040
        OUT=C
        GOSBVL  =CINRTN
        ?CBIT=0 0
        GOYES   keyRtn        No? Go check left?
        ST=0    0               Yes? Set the UP movement flag and return to loop
        ST=0    1
        ST=0    2
        ST=1    3
keyRtn
        GOTO keyLoop



updateSnake
	?ST=1	0
	GOYES	goUp
	?ST=1	1
	GOYES	goDown
	?ST=1	2
	GOYES	goLeft
	GOLONG	goRight

goUp
	GOSUB	srR4
	C=C-CON	A,4
	GOSUB	srS4
	LC(5)	1	
	D=C	A
	GOSUB	drawSnake
	LC(5)	1
	D=C	A
	GOTO mainLoop

goDown
	GOSUB   srR4
        C=C+CON	A,4
        GOSUB   srS4
        LC(5)   1
        D=C     A
        GOSUB   drawSnake
        LC(5)   1
        D=C     A
        GOTO mainLoop

goLeft
	GOSUB   srR3
        C=C-CON	A,4
        GOSUB   srS3
        LC(5)   1
        D=C     A
        GOSUB   drawSnake       go draw one new segment only
        LC(5)   1
        D=C     A
	GOTO    mainLoop

goRight
	GOSUB	srR3
	C=C+CON	A,4
	GOSUB	srS3
	LC(5)	1
	D=C	A
	GOSUB	drawSnake 	go draw one new segment only
	LC(5)	1
	D=C	A	go delete last square of snake
	GOTO	mainLoop

drawSnake
        ?D=0    A
        RTNYES
        GOSUB   srR4            Get snake y-coord
        LA(5)   34
        GOSBVL  =MUL#           B[A] now equals offset
        GOSUB   srR3                    Get snake x-coord
        CSRB.F  A
        CSRB.F  A
        C=C-D   A               Always draw next square to the left for now
	B=B+C   A
        GOSUB   srR5
        C=C+B   A		C now contains ABUFF pointer to start of square
        D0=C
        GOSUB   drawSquare2
        D=D-1   A               one square drawn, subtract from squares left to draw
        GOSUB   drawSnake       draw next part of snake
        RTN



deleteSnake
        GOSUB   srR9            Get snake y-coord
        LA(5)   34
        GOSBVL  =MUL#           B[A] now equals offset
        GOSUB   srR8                    Get snake x-coord
        CSRB.F  A
        CSRB.F  A
        C=C-D   A               Always draw next square to the left for now
        B=B+C   A
        GOSUB   srR5
        C=C+B   A               C now contains ABUFF pointer to start of square
        D0=C
        GOSUB   clearSquare
        D=D-1   A               one square drawn, subtract from squares left to draw
        GOSUB   srR8
        C=C+1   A
        C=C+1   A
        C=C+1   A
        C=C+1   A
        GOSUB   srS8
	RTN



clearSquare			Call with D0 set to rightmost, uppermost edge of square to clear
        LC(5)   0
        DAT0=C  1
        GOSUB   D0DOWN
        LC(5)   0
        DAT0=C  1
        GOSUB   D0DOWN
        LC(5)   0
        DAT0=C  1
        GOSUB   D0DOWN
        LC(5)   0
        DAT0=C  1
        RTN

	
drawSquare2
	LC(5)	15
	DAT0=C	1
	GOSUB	D0DOWN
	LC(5)	15
	DAT0=C	1
	GOSUB	D0DOWN	
	LC(5)   15
        DAT0=C  1
        GOSUB   D0DOWN
   	LC(5)   15
        DAT0=C  1
	RTN




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



delayInit			Get time and store into R3 scratch reg, clears all registers
	GOSBVL	=GetTimChk
	R3=C	
	RTN		


delayCheck			Returns 1 on st 5 if we are ready to update snake
	C=0	W
	GOSUBL	srR7
	R4=C
	GOSBVL	=GetTimChk
	A=R3
	P=	12
	C=C-A	WP
	A=R4
	?A>=C	WP
	GOYES delayMore
	P=	0
	ST=1	5
	RTN
delayMore
	P=	0
	ST=0	5
	RTN

drawTopText
	LC(5)	3		Y-coord where text starts
	LA(5)	34		DOES NOTHING FOR NOW, ADD LATER
	RTN


	
D0DOWN
	D0=D0+	16
	D0=D0+	16
	D0=D0+	2
	RTN
ENDCODE
	TURNMENUON
	RECLAIMDISP


;











	












			 
