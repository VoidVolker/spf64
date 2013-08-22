
REQUIRE MGW  qtf/stdlib.f        // Небольшая библиотека для совместимости 
REQUIRE HYPE qtf/hype3.f         // Поддержка объектов, без них тоскливо
REQUIRE csz  qtf/CS.F            // Работа со строками   

if=W REQUIRE MGW stdlib.f             // Небольшая библиотека для совместимости 
if=W REQUIRE HYPE ~day\hype3\hype3.f  // Поддержка объектов, без них тоскливо
if=W REQUIRE csz  ~day\common\CS.F    // Работа со строками

REQUIRE [IFNDEF] _nn/lib/ifdef.f

[IFNDEF] HEAP-COPY
: HEAP-COPY ( addr u -- addr1 )
\ ����������� ������ � ��� � ������� �� ����� � ����
  DUP 0< IF 8 THROW THEN
  DUP CHAR+ ALLOCATE THROW DUP >R
  SWAP DUP >R CHARS MOVE
  0 R> R@ + C! R>
;
[THEN]

[IFNDEF] +ModuleDirName
: +ModuleDirName ;
[THEN]

[IFNDEF] OPEN-FILE-SHARED
: OPEN-FILE-SHARED OPEN-FILE ;
[THEN]

[IFNDEF] INCLUDE-PROBE
: INCLUDE-PROBE ( addr u -- ... 0 | ior )
  R/O OPEN-FILE-SHARED ?DUP
  IF NIP EXIT THEN
  INCLUDE-FILE 0
;
[THEN]


\ TRUE TO ?GUI                     // Только графика
DIS-OPT                          // Отключить оптимизатор

if=L S" libc.so.6" LoadDLL libc

if=L S" strlen" libc : strlen 1 LITERAL CDECL-CALL ;
if=L S" index"  libc : index  2 LITERAL CDECL-CALL ; // Подцепим С функцию index
if=L S" strdup" libc : strdup 1 LITERAL CDECL-CALL ; // Подцепим С функцию strdup
if=L S" strchr" libc : strchr 2 LITERAL CDECL-CALL ; // strchr
if=L S" strcpy" libc : strcpy 2 LITERAL CDECL-CALL ; // strcpy
if=L S" strcat" libc : strcat 2 LITERAL CDECL-CALL ; // strcat
if=L // Файловые операции ввода/вывода
if=L S" fopen"  libc : fopen  2 LITERAL CDECL-CALL ; // Name Attr -- File
if=L S" fclose" libc : fclose 1 LITERAL CDECL-CALL ; // File -- 0/N
if=L S" fgets"  libc : fgets  3 LITERAL CDECL-CALL ; // AStr Nкол File -- AStr/0=EOF
if=L S" sprintf" libc : sprintf3 3 4 LITERAL CDECL-CALL ;
if=L S" sprintf" libc : sprintf      LITERAL CDECL-CALL ;

// Обработка строк
: CONST$   // ( n -- ) Создать константу, под строку в n байт в памяти
   HERE SWAP ALLOT CREATE , DOES> @ 
   ;
: A>CS     // ( addr u cs -- ) Скопировать строку adr u в буфер cs
       2DUP C! 2DUP + 1+ C0! 1+ SWAP CMOVE
   ;
: CS+A     // ( cs addr u -- ) Склеить строки
       ROT DUP >R ROT OVER COUNT + ROT DROP >R OVER R> SWAP CMOVE            
       R@ C@ + R@ C! R> COUNT + C0!
   ;
   
: dlopen    // ( filename -- h/0 ) Подготовим немного модифиц вариант, для наглядности
if=L     DLOPEN-FLAG              // флаги для работы dlopen()
if=L     SWAP 2                   // порядок аргументов на стеке обратный и их 2 штуки
if=L     dlopen-adr @ CDECL-CALL  // вызов dlopen("filename", DLOPEN-FLAG);
if=W     LoadLibraryA             // Загрузка библ для Windows
    ;
: dlsym     // ( procname h -- a/0 ) Найти адрес функции в DLL
if=L     2                        // 2 аргумента, порядок обратный	
if=L     dlsym-adr @ CDECL-CALL   // вызов dlsym(h, "procname");
if=W     GetProcAddress           // 
     ;

256 CONST$ str_usd    // Строка для сбора распечатки стека с строке состояния   
256 CONST$ str_eval   // Строка от evaluate для распечатки в окне
256 CONST$ str_debug  // Строка для работы отладчика

// 256 CONST$ str_w   // Строка от .W для расп чисел в окне
256 CONST$ SaveUSD    // область для сохранения стека данных
VARIABLE  uSaveUSD    // Указатель для сохранения и востановления стека

: save_USD     // Сохранить стек данных в буфере SaveUSD
    DEPTH 0<> 
    IF
        DEPTH SaveUSD ! SaveUSD CELL + uSaveUSD !
        DEPTH 0 DO uSaveUSD @ ! CELL uSaveUSD +! LOOP
    ELSE
        0 SaveUSD !
    THEN
    ;
: restore_USD  // Востановить стек данных
    SaveUSD @ 0<>
    IF 
        SaveUSD @ CELLS SaveUSD + uSaveUSD !
        0 SaveUSD @ SWAP DO uSaveUSD @ @ CELL NEGATE uSaveUSD +! LOOP
    THEN
    ;

VARIABLE APP                // Ссылка на QApplication 

256 CONST$ s   // Буфер под строку 255 байт

: @CALL @ CDECL-CALL ;      // Что бы не писать это постоянно, причем внутри определения не работает ...

// -----------------------------------------------

: LoadDLL      // Загрузка SO и DLL в память ( 0/As -- H/creat )
	DROP                     // скинем длину строки
if=W    LoadLibraryA             // Грузанем DLL в Windows
if=L    DLOPEN-FLAG              // флаги для работы dlopen()
if=L    SWAP 2                   // порядок аргументов на стеке обратный и их 2 штуки
if=L    dlopen-adr @ CDECL-CALL  // вызов dlopen("filename", DLOPEN-FLAG);
        DUP 0 = IF S" Error load DLL" TYPE CR BYE THEN 
        CREATE , DOES>  OVER IF @ SWAP DROP 
if=W    GetProcAddress           // Найдем точку входа
if=L    2                        // 2 аргумента, порядок обратный	
if=L    dlsym-adr @ CDECL-CALL   // вызов dlsym(h, "procname");
        DUP 0 = IF S" Error find function" TYPE CR BYE THEN
        ELSE @ SWAP DROP THEN 
    ;

// -----------------------------------------------


// Для поиска разд библиот в Linux необ дать команду, для разреш поиска *.so в тек каталоге
// LD_LIBRARY_PATH=`pwd`; export LD_LIBRARY_PATH
if=W    S" fqt.dll" LoadDLL libfqt       // Грузанем библиотеку fqt в память
if=L    S" fqt.so.2.0.0" LoadDLL libfqt  // Грузанем библиотеку fqt в память

// --- Точки входа -----------------------

S" QT_App"                            libfqt  CONSTANT  aQT_App
S" app_exec"                          libfqt  CONSTANT  aapp_exec
S" QT_QWidget"                        libfqt  CONSTANT  aQWidget
S" QT_QWidget_show"                   libfqt  CONSTANT  aQWidget_show
S" QT_QWidget_move"                   libfqt  CONSTANT  aQWidget_move
S" QT_QWidget_setLayout"              libfqt  CONSTANT  aQWidget_setLayout
// ---------------------------
S" QT_QWidget_resize"                 libfqt  CONSTANT  aQWidget_resize
S" QT_QWidget_onresize"               libfqt  CONSTANT  aQWidget_onresize
S" QT_QWidget_setwindowtitle"         libfqt  CONSTANT  aQWidget_setwindowtitle
// ---------------------------
S" QT_QTextEdit"                      libfqt  CONSTANT  aQTextEdit
S" QT_QTextEdit_clear"                libfqt  CONSTANT  aQTextEdit_clear
S" QT_QTextEdit_append"               libfqt  CONSTANT  aQTextEdit_append
// ---------------------------
S" QT_QString"                        libfqt  CONSTANT  aQString
S" QT_QString_set"                    libfqt  CONSTANT  aQString_set
S" QT_QString_text"                   libfqt  CONSTANT  aQString_text
S" NameCodec"                         libfqt  CONSTANT  aNameCodec
// ---------------------------
S" QT_QLineEdit"                      libfqt  CONSTANT  aQLineEdit
S" QT_QLineEdit_onreturnPressed"      libfqt  CONSTANT  aQLineEdit_onreturnPressed
S" QT_QLineEdit_text"                 libfqt  CONSTANT  aQLineEdit_text
S" QT_QLineEdit_setfocus"             libfqt  CONSTANT  aQLineEdit_setfocus
S" QT_QLineEdit_clear"                libfqt  CONSTANT  aQLineEdit_clear
// ---------------------------
S" QT_QMessageBox"                    libfqt  CONSTANT  aQMessageBox
S" QT_QMessageBox_infb"               libfqt  CONSTANT  aQMessageBox_infb
// ---------------------------
S" QT_add3"                           libfqt  CONSTANT  aQadd3
// ---------------------------
S" QT_QVBoxLayout"                    libfqt  CONSTANT  aQT_QVBoxLayout
S" QT_QHBoxLayout"                    libfqt  CONSTANT  aQT_QHBoxLayout
S" QT_QBoxLayout_addWidget"           libfqt  CONSTANT  aQT_QBoxLayout_addWidget
S" QT_QBoxLayout_addLayout"           libfqt  CONSTANT  aQT_QBoxLayout_addLayout
// ---------------------------
S" QT_QStatusBar"                     libfqt  CONSTANT  aQT_QStatusBar
S" QT_QStatusBar_setMes"              libfqt  CONSTANT  aQT_QStatusBar_setMes
// ---------------------------
S" QT_QMainWindow"                    libfqt  CONSTANT  aQT_QMainWindow
S" QT_QMainWindow_setCentralWidget"   libfqt  CONSTANT  aQT_QMainWindow_setCentralWidget
S" QT_QMainWindow_setStatusBar"       libfqt  CONSTANT  aQT_QMainWindow_setStatusBar
S" QT_QMainWindow_setMenuBar"         libfqt  CONSTANT  aQT_QMainWindow_setMenuBar

// Базовый класс QWidget (основа так сказать), на него замыкаются другие виджеты
CLASS fQWidget
   1 CELLS PROPERTY adr_fQWidget   // Запомним адрес объекта
: create     // Инициализация класса
   0 1 aQWidget CDECL-CALL adr_fQWidget !
   ;
: show  // Показать 
   adr_fQWidget @ 1 aQWidget_show  // CDECL-CALL DROP NOOP
   ;
: showw  // Показать 
   adr_fQWidget @ 1 aQWidget_show 
   DEPTH .SN CR NOOP CDECL-CALL DROP
   ;
: move  // ( x y -- ) Переместить
   adr_fQWidget @ 3 aQWidget_move
   ;
: resize   // ( w h -- ) Изменить размер
   SWAP adr_fQWidget @ 3 aQWidget_resize
   ;
: onresize // ( Adr -- ) Установить обраб собтия изм размера
   adr_fQWidget @ 2 aQWidget_onresize
   ;
: setwindowtitle  // ( Qstr -- ) Заголовок на окно
    adr_fQWidget @ 2 aQWidget_setwindowtitle
   ;
: setlayout  // ( Alayuot -- ) Выравниватель вставить в окно
    adr_fQWidget @ 2 aQWidget_setLayout
   ;
: @ // ( Adr -- A ) Отдай непосредственный адрес объекта
   adr_fQWidget @
   ;
;CLASS

// Окно редактора - Наследует QWidget
fQWidget SUBCLASS fQTextEdit  
: create     // Инициализация класса
   0 1 aQTextEdit CDECL-CALL SUPER adr_fQWidget !
   ;
: append     // ( Qstr -- ) добавить строку в TextEdit
   SUPER adr_fQWidget @ 2 aQTextEdit_append
   ;
;CLASS

// QString - класс строк
CLASS fQString
   1 CELLS PROPERTY qs
: create     // Инициализация класса
   0 aQString CDECL-CALL qs !
   ;
: set    // ( Astr -- )  Установить значение 
   qs @ 2 aQString_set
   ;
: text   // ( Astr -- ) Вернуть значение 
   qs @ 2 aQString_text
   ;
: @
  qs @ 
  ;
;CLASS   

// QLineEdit - редактор строки
fQWidget SUBCLASS fQLineEdit
: create     // Инициализация класса
   0 1 aQLineEdit CDECL-CALL SUPER adr_fQWidget !
   ;
// : set    // ( Astr -- )  Установить значение 
//    qs @ 2 aQString_set
//   ;
: text   // ( Astr -- ) Вернуть значение 
   SUPER adr_fQWidget @ 2 aQLineEdit_text
   ;
: onreturnPressed  //  ( Adr -- ) Установить обработчик прерывания
   SUPER adr_fQWidget @ 2 aQLineEdit_onreturnPressed
   ;
: clear   //  Вернуть значение 
   SUPER adr_fQWidget @ 1 aQLineEdit_clear
   ;
: setfocus   //  Установить фокус
   SUPER adr_fQWidget @ 1 aQLineEdit_setfocus
   ;
: @
  SUPER adr_fQWidget @ 
   ;
;CLASS   

// fQMessageBox NEW box1
// box1 create
// 0 0 0 5 0 box1 msgbox CDECL-CALL

// fQMessageBox - MsgBox - диалог модальное окно с загол и сообщением
fQWidget SUBCLASS fQMessageBox
: create     // Инициализация класса
   0 aQMessageBox CDECL-CALL SUPER adr_fQWidget !
   ;
: msgbox     // ( Aqstr_soob Aqstr_zag Nkn Ntip Aparent -- rez )
   SUPER adr_fQWidget @ 6 aQMessageBox_infb
   ;
;CLASS   

// S" QT_QVBoxLayout"                    libfqt  CONSTANT  aQT_QVBoxLayout
// S" QT_QHBoxLayout"                    libfqt  CONSTANT  aQT_QHBoxLayout
// S" QT_QBoxLayout_addWidget"           libfqt  CONSTANT  aQT_QBoxLayout_addWidget
// S" QT_QBoxLayout_addLayout"           libfqt  CONSTANT  aQT_QBoxLayout_addLayout

// Выравниватели по горизонтали и вертикали
CLASS fQLayout
   1 CELLS PROPERTY adr_fQLayout
: createV     // Инициализация класса QVBoxLayout
   0 aQT_QVBoxLayout CDECL-CALL adr_fQLayout !
   ;
: createH     // Инициализация класса QHBoxLayout
   0 aQT_QVBoxLayout CDECL-CALL adr_fQLayout !
   ;
: addWidget   // ( Aqwid -- )  Добавить выравниватель виджет
   adr_fQLayout @ 2 aQT_QBoxLayout_addWidget
   ;
: addLayout   // ( Alayuot -- ) Добавить вырвниватель в выравниватель
   adr_fQLayout @ 2 aQT_QBoxLayout_addLayout
   ;
: @
   adr_fQLayout @ 
   ;
;CLASS   

// СтатусСтрока Наследует QWidget
fQWidget SUBCLASS fQStatusBar
: create     // ( Aqwid --  ) Инициализация класса
   1 aQT_QStatusBar CDECL-CALL SUPER adr_fQWidget !
   ;
: setMes     // ( Qstr -- ) добавить строку в StatusBar
   SUPER adr_fQWidget @ 2 aQT_QStatusBar_setMes
   ;
;CLASS

// MainWindow Наследует QWidget -- Главное окно проекта (SDI или MDI)
fQWidget SUBCLASS fQMainWindow
: create     // ( Aqwid --  ) Инициализация класса
   0 aQT_QMainWindow CDECL-CALL SUPER adr_fQWidget !
   ;
: setCentralWidget     // ( Aqwidg -- ) добавить центральный виджет в Главное окно
   SUPER adr_fQWidget @ 2 aQT_QMainWindow_setCentralWidget
   ;
: setStatusBar     // ( Aqstatbar -- ) добавить статус строку в Главное окно
   SUPER adr_fQWidget @ 2 aQT_QMainWindow_setStatusBar
   ;
: setMenuBar     // ( Aqmenubar -- ) добавить меню в Главное окно
   SUPER adr_fQWidget @ 2 aQT_QMainWindow_setMenuBar
   ;
;CLASS


fQMainWindow   NEW wc1
fQTextEdit     NEW te1
fQString       NEW qs1
fQString       NEW qs_debug
fQString       NEW qs_debug1
fQLineEdit     NEW le1
fQWidget       NEW wincon   // Создадим главный виджет окно
fQStatusBar    NEW sb1

fQLayout       NEW l1
fQTextEdit     NEW te2
fQLineEdit     NEW le2

// Вывод в окно текста ---------------------
: TYPE_W   // ( As Nstr -- ) Вывести строку в окно
   DROP qs1 set     CDECL-CALL DROP  
   qs1 @ te1 append CDECL-CALL DROP
   ;

: SPACE_W str_usd S"  " CS+A ;
: .SN_W   // ( n --)   Распечатать n верхних элементов стека
   >R BEGIN
         R@
      WHILE
        SP@ R@ 1- CELLS + @ \ DUP 0< 
\        IF DUP U>D (D.) str_usd ROT ROT CS+A <# S>D #(SIGNED) #> str_usd ROT ROT CS+A SPACE_W
\        ELSE 
  S>D (D.) str_usd ROT ROT CS+A SPACE_W
\ THEN
        R> 1- >R
      REPEAT RDROP
    ;
: .W   // ( n -- ) Число напечатать на окне te1
   S>D (D.) TYPE_W
   ;
: OK1_W  // Подготовить строку с распечаткой стека SD
    str_usd C0!
    DEPTH 6 U< IF
                 DEPTH IF str_usd S"  Ok ( " CS+A DEPTH .SN_W  str_usd S" )" CS+A
                       ELSE str_usd S"  Ok" CS+A
                       THEN
               ELSE str_usd S"  Ok ( [" CS+A DEPTH S>D (D.) str_usd ROT ROT CS+A str_usd S" ].. " CS+A
                    5 .SN_W str_usd S" )" CS+A
               THEN
    ; 
: DUMP_W  // 
    6 0 DO DUP I + C@ .W LOOP DROP 
    ;
// Отладчик: Пример 1 2 3 __ DROP __ // позволяет остановить прогу и показать стек
fQMessageBox NEW box1

: __    // ( Astr N -- ) Отладчик
    DROP qs_debug1 set  CDECL-CALL DROP  // строку в QString
    OK1_W str_usd 1+ qs_debug set CDECL-CALL DROP
    qs_debug @ qs_debug1 @ 1 1 0 box1 msgbox CDECL-CALL DROP 
    ;
: _    // ( -- ) Отладчик без аргумента
    S" Debug" __
    ;

    // Полезные слова
: ?def 
   WORD FIND _ IF S" найдено" ELSE S" НЕ найдено" THEN TYPE_W
   ;
    
// Обработка событий ---------------------
: _tmp1  // ( a -- )  // Отдадим строку с QLineEdit в об строку
\ EXIT
  DROP 
  restore_USD // А здесь востановить стек данных
  qs1 @ le1 text CDECL-CALL DROP  // Команду из QLineEdit в QString
  s qs1 text CDECL-CALL DROP      // Команду из QString в форт строку s
  str_eval C0! str_eval S" ---> " CS+A str_eval s COUNT CS+A str_eval COUNT TYPE_W // Команду в окно сонсоли
  s COUNT ['] EVALUATE CATCH // Выполнить команду
  0<> IF   S"  <font color=red>^-- Ошибка выполнения ...</font>" TYPE_W THEN
  OK1_W str_usd 1+ qs1 set CDECL-CALL DROP 
  qs1 @ sb1 setMes CDECL-CALL DROP // Расп стек в СтатусСтрока
  le1 setfocus CDECL-CALL DROP  le1 clear CDECL-CALL DROP // Очистить QLineEdit и передать на него фокус
  save_USD // Вот здесь надо выполнить сохранение стека данных
  0                              // возвращаемое значение (треб SPF)
  ; 
' _tmp1 1 CELLS CALLBACK: onCR     // Сработает на CR в le1:QLineEdit
VARIABLE aonCR
' onCR aonCR !

CLASS tQWidget
   1 CELLS PROPERTY adr_tQWidget   // Запомним адрес объекта
: create     // Инициализация класса
   0 1 aQWidget CDECL-CALL adr_tQWidget !
   ;
: show  // Показать 
   adr_tQWidget @ 1 aQWidget_show CDECL-CALL DROP
   ;
: move  // ( x y -- ) Переместить
   adr_tQWidget @ 3 aQWidget_move
   ;
: resize   // ( w h -- ) Изменить размер
   SWAP adr_tQWidget @ 3 aQWidget_resize
   ;
: onresize // ( Adr -- ) Установить обраб собтия изм размера
   adr_tQWidget @ 2 aQWidget_onresize
   ;
: setwindowtitle  // ( Qstr -- ) Заголовок на окно
    adr_tQWidget @ 2 aQWidget_setwindowtitle
   ;
: setlayout  // ( Alayuot -- ) Выравниватель вставить в окно
    adr_tQWidget @ 2 aQWidget_setLayout
   ;
: @ // ( Adr -- A ) Отдай непосредственный адрес объекта
   adr_tQWidget @
   ;
;CLASS

// ПРоверки и утилиты
  S" lib/ext/help.f" INCLUDED


: HelpMessage  // Краткое руководство
   S" <font color=red size=5> Это прототип графической консоли для SPF с использованием Qt.</font>" TYPE_W
   S" -------------------------------------------------------------" TYPE_W
   S" <font>Защиты от ошибок ввода НЕТ, по этому надо писать правильную команду.</font>" TYPE_W
   S" <font color=blue>Вводим команды форта в нижней строке.</font>" TYPE_W
   ;

: run1    // --------------
   0 SaveUSD !
if=L    ARGV ARGC 2 aQT_App CDECL-CALL APP !   // Инициализация QT

\ DUP >R
\ if=L  ARGV ARGC 2 aQT_App CDECL-CALL APP !  // Инициализация QT
\ DUP >R
if=W   GetCommandLineA ASCIIZ> args SWAP 2 aQT_App  // Готовим параметры (&argc, argv)
if=W    CDECL-CALL   APP !                   // uApp = new QApplication(&argc, argv);
   qs1 create       // создадим QString
   qs_debug create  // QString для отладчика
   qs_debug1 create  // QString для отладчика
   // Проверка лайоутов
   wincon create  // Центральнй виджет для Главного окна
   wc1 create     // Главное окно
   l1 createV     // Вертикальный выравниватель
   te1 create     // Мемо окно, для вывода текст информации
   box1 create
   
//   S" история комманд ..." DROP qs1 set CDECL-CALL DROP  qs1 @ te1 setwindowtitle CDECL-CALL DROP
//   800 60 te1 resize CDECL-CALL DROP
//   te1 show CDECL-CALL DROP
   
   wincon @ sb1 create // создадим СтатусСтрока
   le1 create          // создадим QString
   
   te1 @ l1 addWidget CDECL-CALL DROP  // Мемо поле в вертик выравниватель
   le1 @ l1 addWidget CDECL-CALL DROP  // СтрокВВода в верт выравниватель
//  sb1 @ l1 addWidget CDECL-CALL DROP
   l1 @ wincon setlayout CDECL-CALL DROP // Главный выравниватель в центральный виджет
   sb1 @ wc1 setStatusBar CDECL-CALL DROP
   wincon @ wc1 setCentralWidget CDECL-CALL DROP
   
   S" SPF и Qt ..." DROP qs1 set CDECL-CALL DROP  qs1 @ wc1 setwindowtitle CDECL-CALL DROP
   800 500 wc1 resize CDECL-CALL DROP
   le1 setfocus CDECL-CALL DROP
   HelpMessage
   
   OK1_W str_usd 1+ qs1 set CDECL-CALL DROP qs1 @ sb1 setMes CDECL-CALL DROP

//   wc1 showw // CDECL-CALL DROP
   
//   S" Командная строка SPF" DROP qs1 set CDECL-CALL DROP  qs1 @ le1 setwindowtitle CDECL-CALL DROP
   
//   800 10 le1 resize CDECL-CALL DROP
//   le1 show CDECL-CALL DROP
   
   
   aonCR @ le1 onreturnPressed CDECL-CALL DROP // Поставим обработчик на событие onresize
wc1 show
\ RDROP
 CDECL-CALL DROP
\ RDROP
\ EXIT   

   // Главный цикл программы
   APP @ 1 aapp_exec CDECL-CALL DROP
//  BYE
  ;
  
// S" /usr/lib/libQtGui.so.4" LoadDLL qtgui
// S" _ZN7QWidget14setWindowTitleERK7QString" qtgui CONSTANT title

: run  run1 ;

 run1


// ' run MAINX !
// DIS-OPT
// S" gena7.exe" SAVE 

// S" /usr/lib/libQtGui.so.4" LoadDLL qtgui
// S" _ZN7QWidget14setWindowTitleERK7QString" qtgui CONSTANT title
// S" ** SPF **" DROP qs1 set CDECL-CALL DROP
// le1 @ qs1 @ 1 title THIS-CDECL-CALL
// le1 @ qs1 @ 1 title THIS-CDECL-CALL
// S" This is uQLabel::QLabel" DROP uQString str->qstr uQLabel uQString 1 aProcSetWindowTitle @ THIS-CDECL-CALL
