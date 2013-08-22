( Поиск слов в словарях и управление порядком поиска.
  ОС-независимые определения.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)

VECT FIND

VECT SEARCH-WORDLIST ( c-addr u wid -- 0 | xt 1 | xt -1 ) \ 94 SEARCH
\ Найти определение, заданное строкой c-addr u в списке слов, идентифицируемом 
\ wid. Если определение не найдено, вернуть ноль.
\ Если определение найдено, вернуть выполнимый токен xt и единицу (1), если 
\ определение немедленного исполнения, иначе минус единицу (-1).

: SEARCH-WORDLIST1 ( c-addr u wid --- 0 | xt 1 xt -1)
\ Search the wordlist with address wid for the name c-addr u.
\ Return 0 if not found, the execution token xt and -1 for non-immediate
\ words and xt and 1 for immediate words.
	L@
	BEGIN   DUP \ CR ." S=" DUP H.
	WHILE
	>R 2DUP
		R@ \ DUP H.
	 COUNT \ 2DUP TYPE \ KEY DROP
     COMPARE 0= 
		IF	2DROP
			R@ NAME> 
			R> NAME>F  L@ 1 AND 1- 1 OR \ DUP H.
			 EXIT
		THEN 	R> 4 - L@
	REPEAT
	2DROP DROP 0 \ Not found.
;


' SEARCH-WORDLIST1 TO SEARCH-WORDLIST

: SFIND ( c-addr u -- c-addr u 0 | xt 1 | xt -1 ) \ 94 SEARCH
\ Расширить семантику CORE FIND следующим:
\ Искать определение с именем, заданным строкой addr u.
\ Если определение не найдено после просмотра всех списков в порядке поиска,
\ возвратить addr u и ноль. Если определение найдено, возвратить xt.
\ Если определение немедленного исполнения, вернуть также единицу (1);
\ иначе также вернуть минус единицу (-1). Для данной строки, значения,
\ возвращаемые FIND во время компиляции, могут отличаться от значений,
\ возвращаемых не в режиме компиляции.
  S-O 1- CONTEXT \  CR ." YY=" DUP  H.
  DO 2DUP I L@ SEARCH-WORDLIST1
   DUP  IF    2SWAP 2DROP  UNLOOP  EXIT THEN
   DROP
   I S-O = IF  LEAVE THEN
	-4
  +LOOP
  0
;


: FIND1 ( c-addr -- c-addr 0 | xt 1 | xt -1 ) \ 94 SEARCH
\ Расширить семантику CORE FIND следующим:
\ Искать определение с именем, заданным строкой со счетчиком c-addr.
\ Если определение не найдено после просмотра всех списков в порядке поиска,
\ возвратить c-addr и ноль. Если определение найдено, возвратить xt.
\ Если определение немедленного исполнения, вернуть также единицу (1);
\ иначе также вернуть минус единицу (-1). Для данной строки, значения,
\ возвращаемые FIND во время компиляции, могут отличаться от значений,
\ возвращаемых не в режиме компиляции.
  COUNT SFIND
  DUP 0= IF 2DROP 1- 0 THEN ;

: DEFINITIONS ( -- ) \ 94 SEARCH
\ Сделать списком компиляции тот же список слов, что и первый список в порядке 
\ поиска. Имена последующих определений будут помещаться в список компиляции.
\ Последующие изменения порядка поиска не влияют на список компиляции.
  CONTEXT L@ SET-CURRENT
;

: GET-ORDER ( -- widn ... wid1 n ) \ 94 SEARCH
\ Возвращает количество списков слов в порядке поиска - n и идентификаторы 
\ widn ... wid1, идентифицирующие эти списки слов. wid1 - идентифицирует список 
\ слов, который просматривается первым, и widn - список слов, просматриваемый 
\ последним. Порядок поиска не изменяется.
  CONTEXT 1+ S-O DO I L@ 4 +LOOP
  CONTEXT S-O - 4 / 1+
;

: FORTH ( -- ) \ 94 SEARCH EXT
\ Преобразовать порядок поиска, состоящий из widn, ...wid2, wid1 (где wid1 
\ просматривается первым) в widn,... wid2, widFORTH-WORDLIST.
  FORTH-WORDLIST CONTEXT !
;

: LATEST ( -> NFA )
  CURRENT @ @
;

: ONLY ( -- ) \ 94 SEARCH EXT
\ Установить список поиска на зависящий от реализации минимальный список поиска.
\ Минимальный список поиска должен включать слова FORTH-WORDLIST и SET-ORDER.
  S-O TO CONTEXT
  FORTH
;

: ORDER ( -- ) \ 94 SEARCH EXT
\ Показать списки в порядке поиска, от первого просматриваемого списка до 
\ последнего. Также показать список слов, куда помещаются новые определения.
\ Формат изображения зависит от реализации.
\ ORDER может быть реализован с использованием слов форматного преобразования
\ чисел. Следовательно он может разрушить перемещаемую область, 
\ идентифицируемую #>.
  GET-ORDER ." Context: "
  0 ?DO  VOC-NAME. SPACE LOOP CR
  ." Current: " GET-CURRENT VOC-NAME. CR
;

: SET-ORDER ( widn ... wid1 n -- ) \ 94 SEARCH
\ Установить порядок поиска на списки, идентифицируемые widn ... wid1.
\ Далее список слов wid1 будет просматриваться первым, и список слов widn
\ - последним. Если n ноль - очистить порядок поиска. Если минус единица,
\ установить порядок поиска на зависящий от реализации минимальный список
\ поиска.
\ Минимальный список поиска должен включать слова FORTH-WORDLIST и SET-ORDER.
\ Система должна допускать значения n как минимум 8.
   DUP IF DUP -1 = IF DROP ONLY EXIT THEN
          DUP 1- 4 * S-O + TO CONTEXT
          0 DO CONTEXT I 4 * - L! LOOP
       ELSE DROP S-O TO CONTEXT  CONTEXT 0! THEN
;

: ALSO ( -- ) \ 94 SEARCH EXT
\ Преобразовать порядок поиска, состоящий из widn, ...wid2, wid1 (где wid1 
\ просматривается первым) в widn,... wid2, wid1, wid1. Неопределенная ситуация 
\ возникает, если в порядке поиска слишком много списков.
  GET-ORDER 1+ OVER SWAP SET-ORDER
;
: PREVIOUS ( -- ) \ 94 SEARCH EXT
\ Преобразовать порядок поиска, состоящий из widn, ...wid2, wid1 (где wid1 
\ просматривается первым) в widn,... wid2. Неопределенная ситуация возникает,
\ если порядок поиска был пуст перед выполнением PREVIOUS.
  CONTEXT 4 - S-O MAX TO CONTEXT
;


: VOC-NAME. ( wid -- ) \ напечатать имя списка слов, если он именован
  DUP FORTH-WORDLIST = IF DROP ." FORTH"  EXIT THEN
  DUP 4 + L@ DUP IF ID. DROP ELSE DROP ." <NONAME>:" U. THEN
;


DECIMAL