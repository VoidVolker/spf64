( Слова немедленного выполнения, используемые при компиляции
  структур управления в теле высокоуровневого определения.
  ОС-независимые определения.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)

: IF  \ 94
\ Интерпретация: семантика неопределена.
\ Компиляция: ( C: -- orig )
\ Положить на управляющий стек позицию новой неразрешенной ссылки вперед orig.
\ Добавить семантику времени выполнения, данную ниже, к текущему определению.
\ Семантика незавершена, пока orig не разрешится, например, по THEN или ELSE.
\ Время выполнения: ( x -- )
\ Если все биты x нулевые, продолжать выполнение с позиции, заданной 
\ разрешением orig.
  ?COMP DP A@ ?BRANCH, >MARK 1
; IMMEDIATE

: ELSE \ 94
\ Интерпретация: семантика неопределена.
\ Компиляция: ( C: orig1 -- orig2 )
\ Положить на управляющий стек позицию новой неразрешенной ссылки вперед orig2.
\ Добавить семантику времени выполнения, данную ниже, к текущему определению.
\ Семантика незавершена, пока orig2 не разрешится (например, по THEN). 
\ Разрешить ссылку вперед orig1, используя позицию следующей добавленной 
\ семантики выполнения.
\ Время выполнения: ( -- )
\ Продолжить выполнение с позиции, заданной разрешением orig2.
  ?COMP DP A@ BRANCH,
  >ORESOLVE
  >MARK 2
; IMMEDIATE

: THEN \ 94
\ Интерпретация: семантика неопределена.
\ Компиляция: ( C: orig -- )
\ Разрешить ссылку вперед orig, используя позицию семантики выполнения.
\ Добавить семантику времени выполнения, данную ниже, к текущему определению.
\ Время выполнения: ( -- )
\ Продолжить выполнение.
  ?COMP \ HERE TO :-SET
  >ORESOLVE
; IMMEDIATE

: BREAK
  POSTPONE EXIT  POSTPONE THEN ; IMMEDIATE

: BEGIN \ 94
\ Интерпретация: семантика неопределена.
\ Компиляция: ( C: -- dest )
\ Положить следующую позицию передачи управления, dest, на управляющий стек.
\ Добавить семантику времени выполнения, данную ниже, к текущему определению.
\ Время выполнения: ( -- )
\ Продолжить выполнение.
  ?COMP
  4 ALIGN-NOP
\  HERE TO :-SET
  <MARK 3
; IMMEDIATE

: UNTIL \ 94
\ Интерпретация: семантика неопределена.
\ Компиляция: ( C: dest -- )
\ Добавить семантику времени выполнения, данную ниже, к текущему определению.
\ Разрешить ссылку назад dest.
\ Время выполнения: ( x -- )
\ Если все биты x нулевые, продолжать выполнение с позиции, заданной dest.
  ?COMP 3 <> IF -2004 THROW THEN \ ABORT" UNTIL ��� BEGIN !"
  ?BRANCH,
  0xFFFFFF80  DP A@ 4 - @  U<
  IF  DP A@ 5 - W@ 0x3F0 + DP A@ 6 - W!   -4 ALLOT
  THEN
; IMMEDIATE


: WHILE \ 94
\ Интерпретация: семантика неопределена.
\ Компиляция: ( C: dest -- orig dest )
\ Положить позицию новой неразрешенной ссылки вперед orig на управляющий стек
\ под имеющимся dest. Добавить семантику времени выполнения, данную ниже, к 
\ текущему определению. Семантика незавершена, пока orig и dest не разрешатся 
\ (например, по REPEAT).
\ Время выполнения: ( x -- )
\ Если все биты x нулевые, продолжать выполнение с позиции, заданной
\ разрешением orig.
  ?COMP [COMPILE] IF
  2SWAP
; IMMEDIATE

: REPEAT \ 94
\ Интерпретация: семантика неопределена.
\ Компиляция: ( C: orig dest -- )
\ Добавить семантику времени выполнения, данную ниже, к текущему определению,
\ разрешив ссылку назад dest. Разрешить ссылку вперед orig, используя 
\ позицию добавленной семантики выполнения.
\ Время выполнения: ( -- )
\ Продолжить выполнение с позиции, заданной dest.
  ?COMP
  3 <> IF -2005 THROW THEN \ ABORT" REPEAT ��� BEGIN !"
  DUP DP A@ 2+ - DUP
  SHORT?
 \ ." QQQ"
  IF \ SetJP
\   ." WWW"
   0xEB C, C, DROP
  ELSE
 [ HERE DROP ] \ ." YYY"
     DROP BRANCH, THEN
  >ORESOLVE
; IMMEDIATE

: AGAIN  \ 94 CORE EXT
\ Интерпретация: семантика неопределена.
\ Компиляция: ( C: dest -- )
\ Добавить семантику времени выполнения, данную ниже, к текущему определению,
\ разрешив ссылку назад dest.
\ Время выполнения: ( -- )
\ Продолжить выполнение с позиции, заданной dest. Если другие управляющие слова
\ не используются, то любой программный код после AGAIN не будет выполняться.
  ?COMP 3 <> IF -2006 THROW THEN \ ABORT" AGAIN ��� BEGIN !"
  DUP DP A@ 2+ - DUP
  SHORT?
  IF \ SetJP
   0xEB C, C, DROP
  ELSE DROP   BRANCH, THEN \ DP @ TO :-SET
; IMMEDIATE

: RECURSE   \ 94
\ Итерпретация: семантика не определена.
\ Компиляция: ( -- )
\ Добавить семантику выполнения текущего определения в текущее определение.
\ Неоднозначная ситуация возникает, если RECURSE используется после DOES>.
  ?COMP
  LAST-NON  DUP 0= 
  IF DROP  LATEST NAME>  THEN _COMPILE,
; IMMEDIATE
