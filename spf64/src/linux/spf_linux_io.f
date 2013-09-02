( Файловый ввод-вывод.
  Системо-зависимые слова.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)
USER-CREATE FILE-BUFF
256 4 + USER-ALLOT

\ : ERR ;

CREATE SA 12 Q, 0 Q, 1 Q,

: DELETE-FILE ( c-addr u -- ior ) \ 94 FILE
\ Закрыть файл, заданный fileid.
\ ior - определенный реализацией код результата ввода/вывода.
   TRUE  ABORT" $$$$"
;


: Z\TO/  ( Z-addr --  Z-addr  )
  DUP
  BEGIN COUNT DUP
  WHILE  [CHAR] \ = IF [CHAR] / OVER 1- C! THEN
  REPEAT 2DROP

;

: OPEN-FILE ( c-addr u fam -- fileid ior )
  >R  FILE-BUFF  ASCII-Z Z\TO/
  R>  ZOPEN-FILE
;


: CREATE-FILE ( c-addr u fam -- fileid ior ) \ 94 FILE
  DUP O_CREATGet OR  OPEN-FILE
;


USER lpNumberOfBytesRead

HEX

CREATE LT 0A C, 0A C, 0A C, 0A C, \ line terminator
CREATE LTL 1 Q,   \ line terminator length

: DOS-LINES ( -- )
  0A0D LT W! 2 LTL !
;
: UNIX-LINES ( -- )
  0A0A LT W! 1 LTL !
;

DECIMAL

USER _fp1
USER _fp2
USER _addr 4 USER-ALLOT
USER _dos

: READ-LINE ( c-addr u1 fileid -- u2 flag ior ) \ 94 FILE
\ Прочесть следующую строку из файла, заданного fileid, в память
\ по адресу c-addr. Читается не больше u1 символов. До двух
\ определенных реализацией символов "конец строки" могут быть
\ прочитаны в память за концом строки, но не включены в счетчик u2.
\ Буфер строки c-addr должен иметь размер как минимум u1+2 символа.
\ Если операция успешна, flag "истина" и ior ноль. Если конец строки
\ получен до того как прочитаны u1 символов, то u2 - число реально
\ прочитанных символов (0<=u2<=u1), не считая символов "конец строки".
\ Когда u1=u2 конец строки уже получен.
\ Если операция производится, когда значение, возвращаемое
\ FILE-POSITION равно значению, возвращаемому FILE-SIZE для файла,
\ идентифицируемого fileid, flag "ложь", ior ноль, и u2 ноль.
\ Если ior не ноль, то произошла исключительная ситуация и ior -
\ определенный реализацией код результата ввода-вывода.
\ Неопределенная ситуация возникает, если операция выполняется, когда
\ значение, возвращаемое FILE-POSITION больше чем значение, возвращаемое
\ FILE-SIZE для файла, идентифицируемого fileid, или требуемая операция
\ пытается прочесть незаписанную часть файла.
\ После завершения операции FILE-POSITION возвратит следующую позицию
\ в файле после последнего прочитанного символа.
  _dos 0!
  DUP >R
  FILE-POSITION IF 2DROP 0 0 THEN _fp1 ! _fp2 !
  LTL @ +
  OVER _addr !
  R@ READ-FILE   ?DUP  IF NIP RDROP 0 0 ROT EXIT THEN
  DUP >R 0= IF RDROP RDROP 0 0 0 EXIT THEN \ были в конце файла
  _addr @ R@ LT LTL @ SEARCH
  IF   \ найден разделитель строк
     OVER 1- C@ 13 = _dos !
     DROP _addr @ -
     DUP
     LTL @ + S>D _fp2 @ _fp1 @ D+
      RDROP R> REPOSITION-FILE DROP
  ELSE \ не найден разделитель строк
     2DROP
     R>  RDROP  \ если строка прочитана не полностью - будет разрезана
  THEN
  _dos @ + 0 MAX
  TRUE 0
;

\EOF

USER lpNumberOfBytesWritten

: WRITE-FILE ( c-addr u fileid -- ior ) \ 94 FILE
\ Записать u символов из c-addr в файл, идентифицируемый fileid,
\ в текущую позицию.
\ ior - определенный реализацией код результата ввода-вывода.
\ После завершения операции FILE-POSITION возвращает следующую
\ позицию в файле за последним записанным в файл символом, и
\ FILE-SIZE возвращает значение большее или равное значению,
\ возвращаемому FILE-POSITION.
  OVER >R 2 PICK >R >R NIP DUP \ u1 u1
  write <> 3RDROP
  ( если записалось не столько, сколько требовалось, то тоже ошибка )
;
