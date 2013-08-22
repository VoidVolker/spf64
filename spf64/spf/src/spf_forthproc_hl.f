
8	CONSTANT CELL
-1	CONSTANT TRUE
0	CONSTANT FALSE

: DBG ;
: DBG1 ;

: DABS ( d -- ud ) \ 94 DOUBLE
\ ud абсолютная величина d.
  DUP 0< IF DNEGATE THEN
;

: 0MAX 0 MAX ;

: ERASE ( addr u -- ) \ 94 CORE EXT
\ Если u больше нуля, очистить все биты каждого из u байт памяти,
\ начиная с адреса addr.
  0 FILL ;

: BLANK ( addr len -- )     \ fill addr for len with spaces (blanks)
  BL FILL ;

VARIABLE AASAVE
VARIABLE AASAVE0

: COMPARE ( addr1 u1 addr2 u2 --- diff )
\ Compare two strings. diff is negative if addr1 u1 is smaller, 0 if it
\ is equal and positive if it is greater than addr2 u2.
\ CR ." CO="  0 PICK H. 1 PICK H. 2 PICK H. 3 PICK H.
  ROT 2DUP - >R
  MIN DUP IF
   >R
   BEGIN
    OVER \ DUP H.
     C@
     OVER C@
 \     2DUP EMIT EMIT
       - \ DUP .
     IF
     SWAP C@ SWAP C@ -
  \       ." Z=" DUP .
       2RDROP
\ R> R> 2DROP 
        EXIT
    THEN 
    1+ SWAP 1+ SWAP
    R> 1- DUP >R   0=
   UNTIL R>
  THEN DROP
  DROP DROP R> NEGATE
;


: SEARCH ( c-addr1 u1 c-addr2 u2 -- c-addr3 u3 flag ) \ 94 STRING
    2>R 2DUP
    BEGIN
      DUP 1+ R@ >
    WHILE
      OVER 2R@ TUCK COMPARE 0=
      IF 2RDROP 2SWAP 2DROP TRUE EXIT THEN
      1- SWAP 1+ SWAP
    REPEAT 2RDROP 2DROP 0
;

: xCOMPARE ( addr1 u1 addr2 u2 --- diff )
\ Compare two strings. diff is negative if addr1 u1 is smaller, 0 if it
\ is equal and positive if it is greater than addr2 u2.
\ CR ." CO="  0 PICK H. 1 PICK H. 2 PICK H. 3 PICK H.
  ROT 2DUP - >R
  MIN DUP IF
   >R
   BEGIN
    OVER \ DUP H.
     C@
     OVER C@
 \     2DUP EMIT EMIT
       - \ DUP .
     IF
     SWAP C@ SWAP C@ -
  \       ." Z=" DUP .
       2RDROP
\ R> R> 2DROP 
        EXIT
    THEN 
    1+ SWAP 1+ SWAP
    R> 1- DUP >R   0=
   UNTIL R>
  THEN DROP
  DROP DROP R> NEGATE
;


: xSEARCH ( c-addr1 u1 c-addr2 u2 -- c-addr3 u3 flag ) \ 94 STRING
\ CR ." XS="
    2>R 2DUP
    BEGIN
\      DUP 1+ R@ DUP . 2DUP . .  > DUP .
      DUP 1+ R@ > 
    WHILE
      OVER 2R@ TUCK xCOMPARE 0=
      IF 2RDROP 2SWAP 2DROP TRUE EXIT THEN
      1- SWAP 1+ SWAP
    REPEAT 2RDROP 2DROP 0
;

: OFF 0 SWAP ! ;
: ON -1 SWAP ! ;


: MOVE ( addr1 addr2 u -- ) \ 94
\ Если u больше нуля, копировать содержимое u байт из addr1 в addr2.
\ После MOVE в u байтах по адресу addr2 содержится в точности то же,
\ что было в u байтах по адресу addr1 до копирования.
  >R 2DUP SWAP R@ + U< \ назначение попадает в диапазон источника или левее
  IF 2DUP U<           \ И НЕ левее
     IF R> CMOVE> ELSE R> CMOVE THEN
  ELSE R> CMOVE THEN ;



255 CONSTANT MAXCOUNTED   \ maximum length of contents of a counted string

\ : 0X BASE @ HEX >R BL WORD ?LITERAL
\      R> BASE ! ; IMMEDIATE
: "CLIP"        ( a1 n1 -- a1 n1' )   \ clip a string to between 0 and MAXCOUNTED
                MAXCOUNTED MIN 0 MAX ;

: PLACE         ( addr len dest -- )
                SWAP "CLIP" SWAP
                2DUP 2>R
                CHAR+ SWAP MOVE
                2R> C! ;

: +PLACE        ( addr len dest -- ) \ append string addr,len to counted
                                     \ string dest
                >R "CLIP" MAXCOUNTED  R@ C@ -  MIN R>
                                        \ clip total to MAXCOUNTED string
                2DUP 2>R

                COUNT CHARS + SWAP MOVE
                2R> +! ;

: C+PLACE       ( c1 a1 -- )    \ append char c1 to the counted string at a1
                DUP 1+! COUNT + 1- C! ;


0  VALUE  DOES-CODE
' _USER-VALUE-CODE VALUE USER-VALUE-CODE
'  _TOUSER-VALUE-CODE  VALUE TOUSER-VALUE-CODE



: $!         ( addr len dest -- )
   PLACE ;

: $+!         ( addr len dest -- )
   +PLACE ;

: ASCII-Z     ( addr len buff -- buff-z )        \ make an ascii string
   DUP >R $! R> COUNT OVER + 0 SWAP C! ;

: SHORT? ( n -- -129 < n < 128 )
  0x80 + 0x100 U< ;

: REL@ ( ADDR -- ADDR' )
         DUP L@ + ;

: <'>
R>  1+ DUP 4 + >R  REL@ 4 + ;

: , HERE ! CELL ALLOT ;

: CHARS ;
\EOF

: R>     ['] C-R>    INLINE, ;   IMMEDIATE
: >R     ['] C->R    INLINE, ;   IMMEDIATE

: */ ( n1 n2 n3 -- n4 ) \ 94
\ Умножить n1 на n2, получить промежуточный двойной результат d.
\ Разделить d на n3, получить частное n4.
  */MOD NIP
;

: CHARS ( n1 -- n2 ) \ 94
\ Прибавить размер символа к c-addr1 и получить c-addr2.
; IMMEDIATE

: >CELLS ( n1 -- n2 ) \ "to-cells" [http://forth.sourceforge.net/word/to-cells/index.html]
\ Convert n1, the number of bytes, to n2, the corresponding number
\ of cells. If n1 does not correspond to a whole number of cells, the
\ rounding direction is system-defined.
  CELLS
;



: 2CONSTANT  ( d --- )
\ Create a new definition that has the following runtime behavior.
\ Runtime: ( --- d) push the constant double number on the stack. 
  CREATE HERE 2! 8 ALLOT DOES> 2@ ;


 
 
