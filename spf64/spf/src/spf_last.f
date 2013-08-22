 DECIMAL
VECT SHEADER
' YSHEADER TO SHEADER

USER     HLD  \ переменная - позиция последней литеры, перенесенной в PAD

USER C-SMUDGE \ 12 C,

: SMUDGE ( -> )
  C-SMUDGE C@
  LAST @ 1+ C@
  C-SMUDGE C!
  LAST @ 1+ C!
;

: HIDE
  12 C-SMUDGE C! SMUDGE
;

: ALIGN-NOP ( n -- )
\ выровнять HERE на n и заполнить NOP
  HERE DUP ROT 2DUP
  MOD DUP IF - + ELSE 2DROP THEN
  OVER - DUP ALLOT 0x90 FILL
;

: LOOP [COMPILE] _LOOP ; IMMEDIATE
: DO [COMPILE] _DO ; IMMEDIATE

' (ABORT1")  TO (ABORT")
' ERROR_DO   TO ERROR

' FIND1      TO FIND

: INCLUDED INCLUDED_ ;

: CONSTANT ( x "<spaces>name" -- ) \ 94
  HEADER
  CONSTANT-CODE COMPILE, ,
;

: Q, , ;
: LASTWORD ;

