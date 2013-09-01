( Определяющие слова, создающие словарные статьи в словаре.
  ОС-независимые определения.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)

USER LAST-CFA
USER-VALUE LAST-NON

VARIABLE YDP
VARIABLE YDP0
0 VALUE YDP_FL

: YDP><DP
  YDP @ DP @
  YDP ! DP ! ;
    
: ?YDP><DP
 YDP_FL \ IS-TEMP-WL 0= AND
 IF  YDP @ DP @
   YDP ! DP !
 THEN ;


: YSHEADER ( addr u -- )
  ?YDP><DP
DBG\ CURSTR A@ , DBG_CURFILE L,
	HERE 0 L, ( cfa )
	DUP LAST-CFA !
	0 L,     ( flags )
	-ROT WARNING @
	IF 2DUP GET-CURRENT SEARCH-WORDLIST
	   IF (  NOUNIQUE ) DROP 2DUP TYPE ."  isn't unique" CR THEN
	THEN
	 CURRENT @ +SWORD
	?YDP><DP
	ALIGN
    HERE SWAP L! ( ......... cfa )
;
\ VECT SHEADER

\ ' YSHEADER TO SHEADER

: HEADER ( "name" -- )  PARSE-WORD SHEADER ;

: CREATED ( addr u -- )
\ Создать определение для c-addr u с семантикой выполнения, описанной ниже.
\ Если указатель пространства данных не выровнен, зарезервировать место
\ для выравнивания. Новый указатель пространства данных определяет
\ поле данных name. CREATE не резервирует место в поле данных name.
\ name Выполнение: ( -- a-addr )
\ a-addr - адрес поля данных name. Семантика выполнения name может
\ быть расширена с помощью DOES>.
  SHEADER
  HERE DOES>A ! ( ��� DOES )
  CREATE-CODE COMPILE,
;

: CREATE ( "<spaces>name" -- ) \ 94
   PARSE-WORD CREATED
;


: DOES>  \ 94
\ Интерпретация: семантика неопределена.
\ Компиляция: ( C: clon-sys1 -- colon-sys2 )
\ Добавить семантику времени выполнения, данную ниже, к текущему
\ определению. Будет или нет текущее определение сделано видимо
\ для поиска в словаре при компиляции DOES>, зависит от реализации.
\ Поглощает colon-sys1 и производит colon-sys2. Добавляет семантику
\ инициализации, данную ниже, к текущему определению.
\ Время выполнения: ( -- ) ( R: nest-sys1 -- )
\ Заменить семантику выполнения последнего определения name, на семантику
\ выполнения name, данную ниже. Возвратить управление в вызывающее опреде-
\ ление, заданное nest-sys1. Неопределенная ситуация возникает, если name
\ не было определено через CREATE или определенное пользователем слово,
\ вызывающее CREATE.
\ Инициализация: ( i*x -- i*x a-addr ) ( R: -- nest-sys2 )
\ Сохранить зависящую от реализации информацию nest-sys2 о вызывающем
\ определении. Положить адрес поля данных name на стек. Элементы стека
\ i*x представляют аргументы name.
\ name Выполнение: ( i*x -- j*x )
\ Выполнить часть определения, которая начинается с семантики инициализации,
\ добавленной DOES>, которое модифицировало name. Элементы стека i*x и j*x
\ представляют аргументы и результаты слова name, соответственно.
  <'> (DOES1) COMPILE,
  <'> R> COMPILE,  \ ['] (DOES2) COMPILE,  \   ['] C-R>    MACRO, 
; IMMEDIATE

: (DOES1) \ та часть, которая работает одновременно с CREATE (обычно)
  R> DOES>A A@  CFL + -
  DOES>A A@  1+ L! ;

: VARIABLE ( "<spaces>name" -- ) \ 94
\ Пропустить ведущие пробелы. Выделить name, ограниченное пробелом.
\ Создать определение для name с семантикой выполнения, данной ниже.
\ Зарезервировать одну ячейку пространства данных с выровненным адресом.
\ name используется как "переменная".
\ name Выполнение: ( -- a-addr )
\ a-addr - адрес зарезервированной ячейки. За инициализацию ячейки отвечает 
\ программа
  CREATE
  0 L, 0 L,
;
0
[IF]
: CONSTANT ( x "<spaces>name" -- ) \ 94
\ Пропустить ведущие пробелы. Выделить name, ограниченное пробелом.
\ Создать определение для name с семантикой выполнения, данной ниже.
\ name используется как "константа".
\ name Выполнение: ( -- x )
\ Положить x на стек.
  HEADER
  CONSTANT-CODE COMPILE, ,
;
[THEN]
: VALUE ( x "<spaces>name" -- ) \ 94 CORE EXT
\ Пропустить ведущие пробелы. Выделить name, ограниченное пробелом. Создать 
\ определение для name с семантикой выполнения, определенной ниже, с начальным 
\ значением равным x.
\ name используется как "значение".
\ Выполнение: ( -- x )
\ Положить x на стек. Значение x - то, которое было дано, когда имя создавалось,
\ пока не исполнится фраза x TO name, задав новое значение x, 
\ ассоциированное с name.
  HEADER
  QVALUE-CODE  COMPILE, 0 L,
  QTOVALUE-CODE COMPILE, Q,
;
: VECT ( -> )
  ( создать слово, семантику выполнения которого можно менять,
    записывая в него новый xt по TO)
  HEADER
  VECT-CODE COMPILE, ['] NOOP L,
  TOVALUE-CODE COMPILE,
;

: ->VARIABLE ( x "<spaces>name" -- ) \ 94
  HEADER
  CREATE-CODE COMPILE,
  L,
;

: : ( C: "<spaces>name" -- colon-sys ) \ 94
  HEADER ]
  HIDE
;

: VOCABULARY ( "<spaces>name" -- )
\ Создать список слов с именем name. Выполнение name заменит первый список
\ в порядке поиска на список с именем name.
  WORDLIST DUP
  CREATE
  L,
  LATEST OVER 4 + L! ( ссылка на имя словаря )
  GET-CURRENT SWAP PAR! ( словарь-предок )
\  FORTH-WORDLIST SWAP CLASS! ( класс )
  VOC
  ( DOES> не работает в этом ЦК)
  (DOES1) \ (DOES2) \ так сделал бы DOES>, определенный выше
 R>  @ CONTEXT L!
;

: USER-ALLOT ( n -- )
  USER-OFFS +!
;

: USER-HERE ( -- n )
  USER-OFFS @
;


: USER-ALIGNED ( -- a-addr n )
   USER-HERE 3 + 2 RSHIFT ( 4 / ) 4 * DUP
   USER-HERE -
;

: USER-CREATE ( "<spaces>name" -- )
  HEADER
  HERE DOES>A ! ( ��� DOES )
  USER-CODE COMPILE,
  USER-ALIGNED
  USER-ALLOT  L,
;
: USER ( "<spaces>name" -- ) \ ��������� ���������� ������
  USER-CREATE
  8 USER-ALLOT
;
\EOF

: USER-VALUE ( "<spaces>name" -- ) \ 94 CORE EXT
  HEADER
  USER-VALUE-CODE
   COMPILE,
  USER-ALIGNED SWAP L,
  4 + USER-ALLOT
  TOUSER-VALUE-CODE
   COMPILE,
;
