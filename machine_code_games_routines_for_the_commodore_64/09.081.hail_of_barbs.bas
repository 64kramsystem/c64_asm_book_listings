5 REM ** HAIL OF BARBS
10 DATA 169, 191, 133, 251, 169, 7, 133, 252
20 DATA 160, 0, 177, 251, 201, 36, 208, 10
30 DATA 160, 40, 145, 251, 160, 0, 169, 32
40 DATA 145, 251, 165, 251, 56, 233, 1, 133
50 DATA 251, 165, 252, 233, 0, 133, 252, 201, 3, 208, 221, 96
60 FOR L = 820 TO 863 : READ D : POKE L, D : NEXT
1000 PRINT "[CLS]" : POKE 53281, 0
1010 POKE 1024 + INT(40 * RND(1)), 36 : SYS 830 : GOTO 1010
