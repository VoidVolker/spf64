( константы, необходимые при в/в.)

: R/O ( -- fam ) \ 94 FILE
  DUP ROGet ;

: W/O ( -- fam ) \ 94 FILE
  DUP WOGet ;

: R/W ( -- fam ) \ 94 FILE
  DUP RWGet ;

