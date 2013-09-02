\  WORDS
\ 7 CONSTANT WWW
\ : VV IF  1 .  ELSE 0 . THEN ;

\ EOF
: WW BEGIN DUP 
     WHILE   1- [CHAR] U EMIT  ." ZZZ="
       DUP H.
     REPEAT ;

\ : YY 99 0 _DO I  .  I 11 > IF LEAVE THEN  2 +LOOP ;

: ATT ABORT" ZZZZ" ;

\ : ZZ  _DO _LOOP ;
\ ' VV 22 DUMP


