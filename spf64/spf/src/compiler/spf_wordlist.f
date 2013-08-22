( Создание словарых статей и словарей WORDLIST.
  ОС-независимые определения.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999, март 2000
)

: ID. ( NFA[E] -> )
  COUNT TYPE ;

1 CONSTANT &IMMEDIATE \ константа для высечения флажка IMMEDIATE
2 CONSTANT &VOC


\ ���������� wid - ������������� ������ ����, ����������� ��� ����������� 
\ �����, �������������� �����������. ���� ������ ���� ���������� ������ 
\ ���������� � ����� ���������� ������� ������.
: >BODY ( xt -- a-addr ) \ 94
\ a-addr - адрес поля данных, соответствующий xt.
\ Исключительная ситуация возникает, если xt не от слова,
\ определенного через CREATE.
  5 +
;

: +SWORD ( addr u wid -> ) \ добавление заголовка статьи с именем,
         \ заданным строкой addr u, к списку, заданному wid.
         \ Формирует только поля имени и связи с
         \ отведением памяти по ALLOT.
  DUP @ L,       
  HERE LAST !
  HERE SWAP !
   S", 
;

: +WORD ( A1, A2 -> ) \ добавление заголовка статьи с именем,
         \ заданным строкой со счетчиком A1, к списку, заданному
         \ переменной A2. Формирует только поля имени и связи с
         \ отведением памяти по ALLOT. В машинном слове по
         \ адресу A2 расположен адрес поля имени статьи, с
         \ которой начинается поиск в этом списке.
         \ пример: C" SP-FORTH" CONTEXT @ +WORD
  DUP @ L,
  HERE LAST !
  HERE SWAP L!
  ",
;

: IMMEDIATE ( -- ) \ 94
\ Сделать последнее определение словом немедленного исполнения.
\ Исключительная ситуация возникает, если последнее определение
\ не имеет имени.
  LAST A@ NAME>F DUP C@ &IMMEDIATE OR SWAP C!
;
              
: CLASS! ( cls wid -- ) 4 + 4 + 4 +  L! ;
: CLASS@ ( wid -- cls ) 4 + 4 + 4 +  @ ;
: PAR!   ( Pwid wid -- )  4 + 4 +  L! ;
: PAR@   ( wid -- Pwid )  4 + 4 +  @ ;

: VOC ( -- )
\ Пометить последнее определенное слово признаком "словарь".
  LAST A@ NAME>F DUP C@ &VOC OR SWAP C!
;

: WORDLIST ( -- wid ) \ 94 SEARCH
\ Создает новый пустой список слов, возвращая его идентификатор wid.
\ Новый список слов может быть возвращен из предварительно распределенных 
\ списков слов или может динамически распределяться в пространстве данных.
\ Система должна допускать создание как минимум 8 новых списков слов в 
\ дополнение к имеющимся в системе.
  HERE VOC-LIST  A@ L,  VOC-LIST !
  HERE 0 L, \ здесь будет указатель на имя последнего слова списка
       0 L, \ здесь будет указатель на имя списка для именованых
       0 L, \ wid словаря-предка
       0 L, \ класс словаря = wid словаря, определяющего свойства данного
       0 L, \ reserved, для расширений
;

HEX

: ?IMMEDIATE ( NFA -> F )
  NAME>F C@ &IMMEDIATE AND
;

: ?VOC ( NFA -> F )
  NAME>F C@ &VOC AND
;

\ ==============================================
\ ������� - ����� ����� �� ������ � ��� ����


\ ==============================================
\ ������� - ����� ����� �� ������ � ��� ����

: N_UMAX ( nfa nfa1 -- nfa|nfa1 )
 OVER DUP IF NAME> THEN
 OVER DUP IF NAME> THEN U< IF NIP EXIT THEN DROP ;

: WL_NEAR_NFA ( addr wid - addr nfa | addr 0 )
   @
   BEGIN 2DUP DUP IF NAME> THEN U<
   WHILE CDR
   REPEAT
;

0
[IF]

: NEAR_NFA ( addr - nfa addr | 0 addr )
   0 SWAP 
   VOC-LIST
    BEGIN  @ DUP
    WHILE    DUP >R 4 + WL_NEAR_NFA SWAP >R N_UMAX R>  R>
    REPEAT   DROP
;

[ELSE]

: WL_NEAR_NFA_N ( addr nfa - addr nfa | addr 0 )
   BEGIN 2DUP DUP IF NAME> THEN U<
   WHILE CDR
   REPEAT
;

: WL_NEAR_NFA_M (  addr wid - nfa2 addr | 0 addr )
   0 -ROT
   4 + L@
   BEGIN  DUP
   WHILE  WL_NEAR_NFA_N  \  nfa addr nfa1
       SWAP >R 
       DUP  >R  N_UMAX 
       R>  DUP  IF CDR THEN
       R>  SWAP
   REPEAT DROP
;

: NEAR_NFA ( addr - nfa addr | 0 addr )
   0 SWAP 
   VOC-LIST
   BEGIN  L@ DUP
   WHILE  DUP  >R   WL_NEAR_NFA_M
   >R  N_UMAX  R>  R>
   REPEAT DROP
;

[THEN]

: WordByAddr  ( addr -- c-addr u )
\ ����� �����, ���� �������� ����������� ������ �����
   DUP         DP A@ U> IF DROP S" <not in the image>" EXIT THEN
   NEAR_NFA DROP  DUP 0= IF DROP S" <not found>"        EXIT THEN
   COUNT
;

DECIMAL