REQUIRE [IFDEF] _nn/lib/ifdef.f
REQUIRE { _mak/locals4.f

: F7_ED ;
: (D.)          ( d -- addr len )       TUCK DABS  <# #S ROT SIGN #> ;
1 [IF]

: ERR-FILE ERRFILE COUNT ;
: ERR-LINE# ERCURSTR @ ;

: ERROR3 ( ERR-NUM -> ) \ �������� ����������� ������
  DUP 0= IF DROP EXIT THEN
 H-STDERR TO H-STDOUT
 DECIMAL
 CR ERR-FILE   TYPE ." :"  ERR-LINE# 0 (D.) TYPE ." : error: " 
  DUP -2 = IF   DROP 
                ER-A @ ER-U @ TYPE
           ELSE
\  BASE @ >R DECIMAL
\  FORTH_ERROR DECODE-ERROR TYPE
\  R> BASE !
           THEN 
 BYE \ -1 HOLD
;

' ERROR3 TO ERROR
[THEN]

: GR-S ;
: UKEY ABORT ;
: UEMIT ABORT ;
: LPDCB ABORT ;
: COM-CNT ABORT ;
: COM-GET ABORT ;
: TO_COM ABORT ;
: COM-LAST ABORT ;
: COM. ;
: S115200 ;
\ 0x8040000 VALUE IMAGE-BEGIN
\ 0x10000 VALUE 'FORTH_BOOT \ !!!!!!!!

QARM7.F 

BYE
