( Консольный ввод-вывод.
  Windows-зависимые слова.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
  Изменения - Ruvim Pinka ноябрь 1999
)

: ACCEPT0 ( c-addr +n1 -- +n2 ) \ 94
   OVER + 1- OVER      \ SA EA A
   BEGIN KEY          \ SA EA A C
\ ." {"   DUP H. ." }"
     DUP 10 = OVER 13 = OR 0= 
   WHILE
       DUP 0x1B = IF  DROP DUP C@ EMIT   ELSE
       DUP   8  = IF  EMIT BL EMIT 8 EMIT
                     2- >R OVER 1- R> UMAX ELSE
       DUP   9  = IF  DROP DUP 8 BLANK
                     >R OVER R>    \ SA EA SA A
                     SWAP OVER -   \ SA EA SA A-SA
                     8 / 1+ 8 * +  ELSE    DUP EMIT  OVER C!
                THEN THEN
                THEN 1+ OVER UMIN \ SA EA A
   REPEAT                         \ SA EA A C
   DROP NIP - NEGATE ;

: ANSI_ESCAPE ( -- | output escape code )
        27 EMIT [CHAR] [ EMIT ;

: AT-XY ( x y --- )
\ Put screen cursor at location (x,y) (0,0) is upper left corner.
  BASE A@ >R DECIMAL
  ANSI_ESCAPE SWAP 1+  SWAP 0 .R [CHAR] ; EMIT
   1+ 0 .R [CHAR] H EMIT
   R> BASE ! ;

: READ-CDNUMBER  ( c - n | read a numeric entry delimited by character c)
        >R 0 BEGIN
                KEY DUP R@ - WHILE
                SWAP 10 * SWAP [CHAR] 0 - +
        REPEAT
        R> 2DROP ;

: AT-XY?  ( -- x y | return the current cursor coordinates)
        ANSI_ESCAPE ." 6n"
        KEY DROP KEY DROP  \ <ESC> [
        [CHAR] ; READ-CDNUMBER [CHAR] R READ-CDNUMBER
\        2- SWAP 2-
 2- SWAP 
 ;


: ACC_INSERT ( ADDR ADDR1 -- ADDR ADDR1 )
  2DUP U> 0= IF BREAK
   AT-XY? 2>R
  2DUP - >R DUP DUP 1+ R@ MOVE
   DUP R> 1+ TYPE
  2R> AT-XY
;

: ACC_DELETE ( ADDR ADDR1 -- ADDR ADDR1 )
  2DUP U> 0= IF BREAK
   AT-XY? 2>R
  2DUP - >R DUP 1+ OVER R@ MOVE
   DUP R> 1+ TYPE
  2R> AT-XY
;

: ACC_EMIT ( addr c -- addr+1 ) 
  >R
  ACC_INSERT   
  R@ EMIT 
  R> OVER C! 1+ ;

: ACC_LEFT (  SA EA A --  SA EA A' )
 8 EMIT 1- >R OVER R> UMAX ;

: ACC_HOME (  SA EA A --  SA EA SA )
  SWAP >R
  OVER -  0 ?DO 8 EMIT LOOP
  R> OVER
;

: ACC_END  (  SA EA A --  SA EA SA )
  >R
  DUP >R
  BEGIN 1- 2DUP U> 0= IF DUP C@   BL <> 
		ELSE TRUE
		THEN
  UNTIL 1+
  R> SWAP \  SA EA SA

  DUP R> - 
  DUP 0< IF ABS 0 ?DO 8 EMIT LOOP 
         ELSE 0 ?DO 0x1B EMIT ." [C" LOOP
	 THEN
;

CREATE LAST_STP 0x101 ALLOT

: DO1B
 KEY?		0=	IF BREAK
 KEY DUP [CHAR] [ <>	IF ACC_EMIT BREAK
 KEY?		0=	IF ACC_EMIT BREAK DROP
 KEY
  CASE
	[CHAR] D OF ACC_LEFT  ENDOF
	[CHAR] C OF 0x1B EMIT ." [C" 1+ ENDOF
	[CHAR] A OF ACC_HOME DROP >R
                     LAST_STP COUNT 2DUP TYPE
                     >R OVER R> R@ UMIN CMOVE R>
                     OVER  LAST_STP C@ +  ENDOF
	[CHAR] 1 OF ACC_HOME  KEY? 0=	IF BREAK
			KEY DUP [CHAR] ~ <> IF ACC_EMIT BREAK DROP
		 ENDOF
	[CHAR] 3 OF ACC_DELETE  ENDOF
	[CHAR] 4 OF ACC_END   KEY? 0=	IF BREAK
			KEY DUP [CHAR] ~ <> IF ACC_EMIT BREAK DROP
		 ENDOF
  >R [CHAR] [ ACC_EMIT R> ACC_EMIT 0
 ENDCASE ;

: ACCEPT2_ ( c-addr +n1 -- c-addr EA A )
   AT-XY? NIP 0x50 - NEGATE UMIN
   2DUP BLANK
   OVER + 1- OVER      \ SA EA A
   BEGIN KEY          \ SA EA A C
\ ." {"   DUP H. ." }"
     DUP 10 = OVER 13 = OR 0= 
   WHILE        CASE
	0x1B	OF DO1B   ENDOF
	 8 	OF ACC_LEFT ACC_DELETE ENDOF
               ACC_EMIT
              0 ENDCASE  OVER UMIN \ SA EA A
   REPEAT                         \ SA EA A C
   DROP
   ;

: ACCEPT2 ( c-addr +n1 -- +n2 ) \ 94
  ACCEPT2_
  ACC_END NIP
  OVER - DUP IF  2DUP  LAST_STP $! THEN
  NIP CR
;

VECT ACCEPT

' ACCEPT1 TO ACCEPT

: TYPE1 ( c-addr u -- ) \ 94
\  H-STDOUT DUP IF WRITE-FILE THROW ELSE 2DROP DROP THEN
 H-STDOUT  WRITE-FILE DROP
;

CREATE WXZTYPE-BUFF 0x101 ALLOT

: WXTYPE ( c-addr u -- )
\  H-STDOUT DUP IF WRITE-FILE THROW ELSE 2DROP DROP THEN
\ H-STDOUT
\ IF H-STDOUT  WRITE-FILE DROP EXIT
\ THEN
  WXZTYPE-BUFF  ASCII-Z  ZTYPE
;

: _CR ( -- ) \ 94
\ ������� ������.
\  Z\" \n\r" ZTYPE
  LT LTL @ TYPE
 ;

VECT CR ' _CR TO CR

VARIABLE EMITVAR

: _EMIT ( x -- ) \ 94
\ ���� x - ������������ ������, ������� ��� �� �������.
\  >R RP@ 1 TYPE1 RDROP
EMITVAR L!  EMITVAR 1 TYPE1 

;
