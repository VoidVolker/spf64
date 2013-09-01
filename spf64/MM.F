.( zzzzzzzzzz)
.( xxxxxxxxx)
.( YYYYYY) CR
-7
.
\ EOF

: OPEN-SOCK ( c-addr u port -- fileid ior )
  >R  FILE-BUFF  ASCII-Z Z\TO/
  R>  SOPEN DUP 0xFFFFFFFF AND 0xFFFFFFFF =
;

-7 VALUE ZZZ
 ZZZ .
\ EOF

\ S" localhost"  8880 OPEN-SOCK . .
S" ibm.com"  80 OPEN-SOCK THROW VALUE SID

S" HELLO!!!!" SID WRITE-FILE .
\ EOF
: $CD   FILE-BUFF ASCII-Z
 DUP 33 DUMP
 ZCD
 ;
.( RRRRR) CR
\ F.F
 \ EOF
 
S" spf" $CD


\ _mak/DIS486.F CR
_mak/lib/disassem.fth
\ EOF
SHOW +

