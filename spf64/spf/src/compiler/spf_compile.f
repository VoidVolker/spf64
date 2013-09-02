
: HERE ( -- addr ) \ 94
\ addr - указатель пространства данных.
  DP A@ 
\  DUP TO :-SET
\  DUP TO J-SET
;

: _COMPILE,
  0xE8 C, \ CALL
  DP A@ 4 + - L,
;

: COMPILE,  \ 94 CORE EXT
\ Интерпретация: семантика не определена.
\ Выполнение: ( xt -- )
\ Добавить семантику выполнения определения, представленого xt, к
\ семантике выполнения текущего определения.
  _COMPILE,
;

: BRANCH, ( ADDR -> )  \ скомпилировать инструкцию ADDR JMP
\  ?SET  SetOP SetJP
   0xE9 C,
  DUP IF DP A@ CELL+ - THEN L,  \  DP @ TO LAST-HERE
;

: RET, ( -> ) \ скомпилировать инструкцию RET
\  ?SET SetOP
   0xC3 C, \ OPT OPT_CLOSE 
;

: LIT, ( W -> )
  'DUP_V COMPILE, \ INLINE,
\  OPT_INIT  SetOP
   0x48 C,  0xB8 C,  Q, \ OPT  \ MOVABS RAX, #
\  OPT_CLOSE
;

: DLIT, ( D -> )
  SWAP LIT, LIT,
;

: S, ( addr u -- )
\ Зарезервировать u символов пространства данных
\ и поместить туда содержимое u символов из addr.
  DP @ SWAP DUP ALLOT CMOVE
;

: S", ( addr u -- ) 
\ Разместить в пространстве данных строку, заданную addr u, 
\ в виде строки со счетчиком.
  DUP C, S,
;

: ", ( A -> )
\ разместить в пространстве данных строку, заданную адресом A, 
\ в виде строки со счетчиком
  COUNT S",
;

: ALIGN ( -- ) \ 94
\ Если указатель пространства данных не выровнен -
\ выровнять его.
  DP A@ ALIGNED DP A@ - ALLOT
;

USER ALIGN-BYTES

: ALIGNED ( addr -- a-addr ) \ 94
\ a-addr - первый выровненный адрес, больший или равный addr.
  ALIGN-BYTES @ DUP 0= IF 1+ DUP ALIGN-BYTES ! THEN
  2DUP
  MOD DUP IF - + ELSE 2DROP THEN
;

: SLIT, ( a u -- )
\ Скомпилировать строку, заданную addr u.
  SLITERAL-CODE COMPILE,  S", 0 C,
;

: CLIT, ( a -- )
 COUNT CLITERAL-CODE COMPILE,  S", 0 C,
;

: ?BRANCH, ( ADDR -> ) \ скомпилировать инструкцию ADDR ?BRANCH
  <'> QBRANCH _COMPILE,
  0x84 \ TO J_COD
  0x0F     \  JX
  C, C,
  DUP IF DP A@ 4 + - THEN L, \ DP @ TO LAST-HERE
;

\ orig - a, 1 (short) ��� a, 2 (near)
\ dest - a, 3

: >MARK ( -> A )
  DP A@ \ DUP TO :-SET
   4 - 
;

: <MARK ( -> A )
  HERE
;

: >ORESOLVE1 ( A -> )
\  ?SET
\  DUP
    DP A@ \ DUP TO :-SET
    OVER - 4 -
    SWAP     L!
\  RESOLVE_OPT
;

: >ORESOLVE ( A, N -- )
  DUP 1 = IF   DROP >ORESOLVE1
          ELSE 2 <> IF -2007 THROW THEN \ ABORT" Conditionals not paired"
               >ORESOLVE1
          THEN
;

: >RESOLVE1 ( A -> )
  HERE OVER - 4 -
  SWAP L!
;

: >RESOLVE ( A, N -- )
  DUP 1 = IF   DROP >RESOLVE1
          ELSE 2 <> IF -2007 THROW THEN \ ABORT" Conditionals not paired"
               >RESOLVE1
          THEN
;
