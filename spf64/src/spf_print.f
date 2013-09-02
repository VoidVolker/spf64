( Слова форматной печати чисел.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999 [переход на USER-переменные и
  замена CODE-слов высокоуровневыми определениями]
)

: MH.
  DUP 0xF AND  DUP 10 < 0= IF 7 + THEN 0x30 + >R  4 RSHIFT
  
  DUP 0xF AND  DUP 10 < 0= IF 7 + THEN 48 +  >R  4 RSHIFT
  DUP 0xF AND  DUP 10 < 0= IF 7 + THEN 48 +  >R  4 RSHIFT
  
  DUP 0xF AND  DUP 10 < 0= IF 7 + THEN 48 +  >R  4 RSHIFT
  DUP 0xF AND  DUP 10 < 0= IF 7 + THEN 48 +  >R  4 RSHIFT
  DUP 0xF AND  DUP 10 < 0= IF 7 + THEN 48 +  >R  4 RSHIFT
  
  DUP 0xF AND  DUP 10 < 0= IF 7 + THEN 48 +  >R  4 RSHIFT
  DUP 0xF AND  DUP 10 < 0= IF 7 + THEN 48 +  >R  4 RSHIFT
  DUP 0xF AND  DUP 10 < 0= IF 7 + THEN 48 +  >R  4 RSHIFT
 R> EMIT R> EMIT R> EMIT    
 R> EMIT R> EMIT R> EMIT    
 R> EMIT R> EMIT  
  R>  EMIT    
  DROP
;


: HEX ( -- ) \ 94 CORE EXT
\ Установить содержимое BASE равным шестнадцати.
  16 BASE !
;

: DECIMAL ( -- ) \ 94
\ Установить основание системы счисления равным десяти.
  10 BASE !
;

: HOLD ( char -- ) \ 94
\ Добавить char к началу форматной числовой строки.
\ Исключительная ситуация возникает, если использовать HOLD
\ вне <# и #>, ограничивающивающих преобразование чисел.
  HLD A@ 1- DUP HLD ! C!
;

\ : HOLDS ( addr u -- ) \ from eserv src
\  TUCK + SWAP 0 ?DO DUP I - 1- C@ HOLD LOOP DROP ;

: <# ( -- ) \ 94
\ Начать форматное преобразование чисел.
  PAD 1- HLD !
  0 PAD 1- C!
;

: # ( ud1 -- ud2 ) \ 94
\ Делением ud1 на значение BASE выделить одну цифру с конца и
\ добавить ее в буфер форматного преобразования чисел,
\ оставив частное ud2.
\ Исключительная ситуация возникает, если использовать #
\ вне <# и #>, ограничивающивающих преобразование чисел.
  0 BASE A@ UM/MOD  >R
    BASE A@ UM/MOD 
  SWAP DUP 10 < 0= IF 7 + THEN 48 + 
  HOLD R>
;

: #S ( ud1 -- ud2 ) \ 94
  BEGIN
    #  2DUP D0=
  UNTIL
;

: #> ( xd -- c-addr u ) \ 94
\ Убрать xd. Сделать буфер форматного преобразования доступным в виде
\ строки символов, заданной c-addr и u.
\ Программа может менять символы в этой строке.
  2DROP HLD A@ PAD OVER - 1-
;

: SIGN ( n -- ) \ 94
\ Если n отрицательно, добавить в строку форматного преобразования
\ чисел минус.
\ Исключительная ситуация возникает, если использовать SIGN
\ вне <# и #>, ограничивающивающих преобразование чисел.
  0< IF [CHAR] - HOLD THEN
;

: (D.)  ( d -- addr len )  DUP >R DABS <# #S R> SIGN #> ;

: D.    ( d -- )   (D.) TYPE SPACE ;

: . ( n -- )   S>D D. ;

: D.R ( d w -- )   >R (D.) R> OVER - 0MAX SPACES TYPE ;

: .R  ( n w -- )   >R  S>D  R>  D.R ;

: U.R ( u w -- )   0 SWAP D.R ;

: U. ( u -- ) \ 94
\ Напечатать u в свободном формате.
  U>D D.
;

: H. BASE A@ SWAP HEX U. BASE ! ;

: .0
  >R 0 <# #S #> R> OVER - 0 MAX 
    BEGIN  DUP 0>
    WHILE 1- [CHAR] 0 EMIT
    REPEAT DROP
    TYPE 
;

: >PRT
  DUP BL U< IF DROP [CHAR] . THEN
;

: PTYPE
    BEGIN DUP 0>
    WHILE 1- SWAP COUNT >PRT EMIT SWAP
    REPEAT 2DROP
\  0 DO DUP C@ >PRT EMIT 1+ LOOP DROP
;

: DUMP ( addr u -- ) \ 94 TOOLS
  DUP 0= IF 2DROP EXIT THEN
  BASE A@ >R HEX
  15 + 16 U/ 0 DO
    CR DUP 4 .0 SPACE
    SPACE DUP 16 0
      DO  I 3 AND 0= IF SPACE THEN
         DUP       C@
\	0xFF AND
 2 .0 SPACE  1+
      LOOP
       SWAP  16  PTYPE
  LOOP DROP R> BASE !
;

: (.") ( T -> )
  COUNT TYPE
;
\ ' (.") TO (.")-CODE

: DIGIT ( C, N1 ->> N2, TF / FF )
\ N2 - значение литеры C как
\ цифры в системе счисления по основанию N1
   >R
   [CHAR] 0 - 10 OVER U<
   IF 
      DUP [CHAR] A [CHAR] 0 -     < IF  RDROP DROP 0 EXIT      THEN
      DUP [CHAR] a [CHAR] 0 -  1- > IF [CHAR] a  [CHAR] A - -  THEN
          [CHAR] A [CHAR] 0 - 10 - -
   THEN R> OVER U> DUP 0= IF NIP THEN ;

: >NUMBER ( ud1 c-addr1 u1 -- ud2 c-addr2 u2 ) \ 94
\ ud2 - результат преобразования символов строки, заданной c-addr1 u1,
\ в цифры, используя число в BASE, и добавлением каждой к ud1 после
\ умножения ud1 на число в BASE. Преобразование продолжается слева
\ направо до первого непреобразуемого символа, включая символы "+" и "-",
\ или до полного преобразования строки.
\ c-addr2 - адрес первого непреобразумого символа или первого символа
\ за концом строки, если строка была полностью преобразована.
\ u2 - число непреобразованных символов в строке.
\ Неоднозначная ситуация возникает, если ud2 переполняется во время
\ преобразования.
  BEGIN
    DUP
  WHILE
    >R
    DUP >R
    C@ BASE @ DIGIT 0=     \ ud n flag
    IF R> R> EXIT THEN     \ ud n  ( ud = udh udl )
    SWAP BASE @ UM* DROP   \ udl n udh*base
    ROT BASE @ UM* D+      \ (n udh*base)+(udl*baseD)
    R> 1+ R> 1-
  REPEAT
  DBG
;


