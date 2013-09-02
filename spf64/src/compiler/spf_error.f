( Обработка ошибок.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Ревизия: Cентябрь 1999
)

VARIABLE SAVEERR?
VARIABLE >IN_WORD

VARIABLE ERCURSTR 
VARIABLE ER>IN

VECT ERROR      \ обработчик ошибок (ABORT)
VECT (ABORT")

 CREATE ERRTIB  C/L 1+ ALLOT
 CREATE ERRFILE C/L 1+ ALLOT


: SAVEERR	
	DUP SAVEERR? @ AND
	IF DBG	
	  SOURCE ERRTIB $! >IN_WORD @ ER>IN ! SAVEERR? OFF
\            SOURCE-ID  0 <> \ 999 HERE WITHIN 
\		IF CURFILE @ ASCIIZ> C/L UMIN ERRFILE $! CURSTR @ ERCURSTR !
\		THEN 
	THEN ;

: _ERROR_DO ( ERR-NUM -> )
	SAVEERR
	CR ERRFILE COUNT TYPE ." :" ERCURSTR @ .
( )	CR ERRTIB COUNT TYPE 
( )	CR ER>IN @ BEGIN SPACE 1- DUP 0 MAX 0= UNTIL ." ^" DROP
	CR ." ERR=" .
	CR  S0 A@ SP! STATE 0!
;

: ?ERROR ( F, N -> )
  SWAP IF THROW ELSE DROP THEN
;

: (ABORT1") ( flag c-addr -- )
  ROT IF ER-U ! ER-A ! -2 THROW ELSE 2DROP THEN
;

:  ERR-TYPE
	CR ERRTIB COUNT TYPE 
	CR ER>IN @ BEGIN SPACE 1- DUP 0 MAX 0= UNTIL ." ^" DROP
;

: ERROR_DO ( ERR-NUM -> ) \ �������� ����������� ������
  CR ERRFILE COUNT TYPE ." :" ERCURSTR @ .
  DUP -2 = IF   DROP ERR-TYPE
                ER-A A@ ER-U A@ TYPE CR EXIT
           THEN
	ERR-TYPE
  DECIMAL [COMPILE] [
  S" SPF.ERR" R/O OPEN-FILE
  IF DROP ." ERROR #" . CR EXIT THEN
  SOURCE-ID >R
     TO SOURCE-ID
     >R
     BEGIN
       REFILL 0= #TIB A@ 0= OR
       PARSE-WORD ['] ?SLITERAL CATCH
       IF 2DROP DROP -1 R@ . ELSE R@ = THEN OR
     UNTIL
\  [CHAR] \ PARSE TYPE ."  ERR# " R> .
  >IN 0! [CHAR] \ PARSE TYPE RDROP
  SOURCE-ID CLOSE-FILE THROW
  R> TO SOURCE-ID
  CR
;
