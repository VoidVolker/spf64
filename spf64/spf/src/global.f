: ROGet	ABORT	;
: WOGet	ABORT	;
: RWGet	ABORT	;
: SEEK_SETGet	ABORT	;
: write	ABORT	;
: read	ABORT	;
: open	ABORT	;
: close	ABORT	;
: getch	ABORT	;
: kbhit	ABORT	;
: HPOINT 	ABORT	;
: chsize	ABORT	;
: creat	ABORT	;
: creatnew	ABORT	;
: crlf2nl	ABORT	;
: dos_lock	ABORT	;
: filelength	ABORT	;
: get_dev_info	ABORT	;
: lock	ABORT	;
: tell	ABORT	;
: lseek	ABORT	;
: mlseek	ABORT	;
: malloc	ABORT	;
: free 	ABORT	;
: realloc	ABORT	;
: O_CREATGet	ABORT	;
: putchar	ABORT	;
: NNN	ABORT	;
: LACCEPT	ABORT	;
: LZTYPE	ABORT	;
: LTST	ABORT	;
: LARGV1	ABORT	;
: LARGV		ABORT	;
: LARGC		ABORT	;
: LOPEN	ABORT	;
: LCMOVE	ABORT	;
: LALLOCATE	ABORT	;
: LFREE		ABORT	;
: LARGV1     ABORT   ;

: ZTO_FLOAT	ABORT	;
: ZTYPE		ABORT	;
: WXZTYPE	ABORT	;
: WXEMIT	ABORT	;
: WXSPACE	ABORT	;

: PF. ABORT ;
: f_store ABORT ;
: f_star ABORT ;
: f_plus ABORT ;
: f_minus ABORT ;
: f_slash ABORT ;
: f_zero_less ABORT ;
: f_zero_equal ABORT ;
: f_less_than ABORT ;
: f_to_d ABORT ;
: f_fetch ABORT ;
: d_to_f ABORT ;
: f_to_d1 ABORT ;
: f_to_d2 ABORT ;
: FCELL_ ABORT ;
: wherexy ABORT ;
\ : move ABORT ;
: dlopen ABORT ;
: dlerror ABORT ;
: dlsym  ABORT ;
: calloc  ABORT ;
: ADD[ESP],TOS  ABORT ;
: _QCONSTANT-CODE  ABORT ;



VARIABLE UPPER_V

: ALIGN ( -- ) \ 94
;

: ALIGN-NOP ( n -- )
 DROP	;

: mtell	ABORT	;
: mtelle	ABORT	;

: C_KEY	ABORT	;
: C_KEYQUERY	ABORT	;
: C_ACCEPT	ABORT	;
: L_ACCEPT	ABORT	;

: FCELL_ ABORT ;
: 0e	ABORT	;
: 1e	ABORT	;
: F.	ABORT	;

: dlopen ABORT ;
: dlsym ABORT ;

[IFNDEF] CLIT,
: CLIT, ( a u -- )
 COUNT ['] _CLITERAL-CODE COMPILE,  S", 0 C,
;

[THEN]
: TCYDP0 ABORT ;
\ : QCELL+ ABORT ;
: A! ! ;
: A@ @ ;
: L! ! ;
: L@ @ ;


\ : QUM/MOD ABORT ;
\ : QUM* ABORT ;
\ : QH. ABORT ;
: SEARCH-WORDLIST1  ABORT ; 

' _TOVALUE-CODE TO TOVALUE-CODE 
' _VECT-CODE VALUE VECT-CODE
' TYPE VALUE 'TYPE
' C-DO VALUE 'C-DO
' C-?DO VALUE 'C-?DO
' (ABORT") VALUE '(ABORT") 

