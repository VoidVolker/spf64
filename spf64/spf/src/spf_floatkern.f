\ ���� float ����������

0 [IF]

: F.	f_dot ;
: F* f_star ;
: F+ f_plus ;
: F- f_minus ;
: F/ f_slash ;
: F0< f_zero_less ;
: F0= f_zero_equal ;
: F< f_less_than ;

: F>D DUP f_to_d1 DUP f_to_d2 ;
: UD>F >R DUP >R d_to_f RDROP RDROP DROP  ;
[THEN]

: F.	PF. ZTYPE ;

: F0< DUP f_zero_less ;
: F0= DUP f_zero_equal ;
: F<  DUP f_less_than ;

: FCELL DUP FCELL_ ;

CREATE ZFLOAT 0x101 ALLOT

: >FLOAT  ( addr len -- flag )
  2DUP + 1- C@ 0x20 OR [CHAR] e = IF 1- THEN
  ZFLOAT ASCII-Z ZTOFLOAT ;

: FLIT R> DUP F@ FCELL @ + >R ;
: F,  HERE F! FCELL @ ALLOT ;

: FLIT,  ['] FLIT COMPILE, F, ;

: FLITERAL ( F: r -- )
      STATE A@ IF FLIT, THEN
; IMMEDIATE


: NOTFOUND ( c-addr u -- )
  2DUP 2>R <'> ?SLITERAL CATCH ?DUP
  IF NIP NIP 2R>
    >FLOAT \ ." F=" DUP .
    IF  [COMPILE] FLITERAL DROP
    ELSE  THROW
    THEN
  ELSE  2R> 2DROP
  THEN
;
