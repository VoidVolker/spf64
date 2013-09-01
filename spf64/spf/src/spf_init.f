
: TITLE CR
  ." ANS FORTH 94 for Linux" CR
  ." A.Cherezov  http://www.forth.org.ru/" CR
  ." M.Maksimov  http://www.chat.ru/~mak"  CR
  ." BTC:1DXQYcg7Vr7orbqTmiEFVxEUQ9o1yAjNNN" CR CR
;

VARIABLE TSTVAR

: TTT S" spf/TT.F" INCLUDED_ ;
: ttt TTT ;

VECT TYPE ' TYPE1 TO TYPE
VECT EMIT ' _EMIT TO EMIT

\ : 0E.  0e F. ;
: SPINIT
    S0 A@ SP! ;

: THTST 1 THROW ;

: TTF S" spf/TT.F"  ;

: ARG DUP  LARGV1 ;
: RRR
  1+ DUP 
  DROP ;

: COMMANDLINE ( -- ADDR LEN )
\ 0 0 EXIT
 ARG   DUP
 IF   ASCIIZ>
 ELSE DUP
 THEN ;

: MM S" MM.F" ;

: INIT
  DBG
 DECIMAL
  <'> ?SLITERAL2 TO ?SLITERAL
  <'> _QCONSTANT-CODE TO CONSTANT-CODE
 
\ S" MM.F" INCLUDED BEGIN AGAIN
 COMMANDLINE ?DUP
\ S" WORDS" DUP
   IF
     <'> EVALUATE CATCH    ?DUP
    IF <'> ERROR CATCH
      DROP \ IF 4 HALT THEN
    THEN
   ELSE DROP  TITLE
   THEN
\ S" MM.F" INCLUDED CR
 SPINIT
  BEGIN
    <'> QUIT CATCH \ SAVEERR
    ?DUP
    IF   CR
\     ." err=" .
      <'> ERROR CATCH DROP
	CR
    ELSE BYE THEN
    SPINIT \ R0 @ RP!
  AGAIN

;


