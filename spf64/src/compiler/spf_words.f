( Печать списка слов словаря - WORDS.
  ОС-независимые определения.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)

: ?CR-BREAK ( NFA -- NFA TRUE | FALSE )
  DUP
\  CR ." NL2" CR   DUP HH.
  IF
   DUP C@ >OUT A@ +    64 >
     IF >OUT 0!
        NNN A@
        IF    -1 NNN +!  TRUE
        ELSE   ." Q - quit" CR 6 NNN !
              KEY 0x20 OR 
                [CHAR] q <>
                 AND
               ?DUP 0<>
        THEN
     ELSE TRUE
     THEN
  THEN
;

: NLIST ( A -> )
  L@  >OUT   0!
   CR W-CNT 0!  6 NNN L!
  BEGIN   ?CR-BREAK
  WHILE
    W-CNT 1+!
\    DUP 8 DUMP CR
\    DUP H. CR
    DUP ID.
    DUP C@ >OUT +!
    8 >OUT A@ 8 MOD - DUP >OUT +! SPACES
\	9 EDIT
    CDR
  REPEAT KEY? IF KEY DROP THEN
  CR CR ." Words: " W-CNT A@ U.
   CR
;

: WORDS ( -- ) \ 94 TOOLS
\ Список имен определений в первом списке слов порядка поиска. Формат зависит 
\ от реализации.
\ WORDS может быть реализован с использованием слов форматного преобразования 
\ чисел. Соответственно, он может испортить перемещаемую область, 
\ идентифицируемую #>.
  CONTEXT L@   NLIST ;

