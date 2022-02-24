REM SPRITE VECTORING ROUTINE

10 DATA 162,0,189,52,3,125,0,208,157,0
11 DATA 208,232,224,16,208,242,76,49
12 DATA 234
40 FOR P=49152 TO 49170
41 READ D : POKE P,D
42 NEXT

REM SPRITE POINTERS; ALL POINT TO 15*64
REM = 960

50 FOR A=2040 TO 2047 : POKE A,15 : NEXT

REM SPRITE DATA (FILL ALL THE BITS); THE
REM MEMORY REGIONS ARE THE DATASETTE
REM BUFFER AND AN UNUSED REGION

60 FOR A=960 TO 1022 : POKE A,255 : NEXT

REM SPRITE VECTORS

70 FOR A=820 TO 835
71 POKE A,INT(4*RND(1)+1)
72 NEXT

REM SET SERVICE INTERRUPT VECTOR TO THE
REM VECTORING ROUTINE, AND ENABLE ALL
REM THE SPRITES

80 POKE 788,0 : POKE 789,192
81 POKE 53269,255