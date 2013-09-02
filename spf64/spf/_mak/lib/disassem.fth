REQUIRE /STRING lib/include/string.f 
REQUIRE [IF] _mak/CompIF.f
REQUIRE [IFNDEF] _nn/lib/ifdef.f
REQUIRE $! _mak/place.f
REQUIRE CASE  _mak/case.f 

\ REQUIRE WBSPLIT ~mak\Firmware\split.fth


[IFNDEF] >= : >= < 0= ; [THEN]
[IFNDEF] BETWEEN : BETWEEN 1+ WITHIN ; [THEN]
[IFNDEF] ALIAS
: ALIAS         ( xt -<name>- ) \ make another 'name' for 'xt'
    HEADER
   PARSE-NAME SFIND DUP 0= THROW
  1 = IF IMMEDIATE THEN
    0xE9 C, HERE CELL+ - ,  ;
[THEN]

[IFNDEF] >> : >> RSHIFT ; [THEN]
[IFNDEF] << : << LSHIFT ; [THEN]
[IFNDEF] >>A : >>A ARSHIFT ; [THEN]

[IFNDEF] WBSPLIT
: WBSPLIT  ( l -- b.low b.high )
   DUP  0xFF AND  SWAP   8 >>
        0xFF AND
;
[THEN]

[IFNDEF] LOWMASK : LOWMASK  ( #bits -- )  0 SWAP 0 ?DO  1 << 1 +  LOOP  ; [THEN]
[IFNDEF] BWJOIN : BWJOIN  (  b.low b.high -- w )  8 << +  ;	[THEN]
[IFNDEF] WLJOIN	: WLJOIN  ( w.low w.high -- l )  0x10 <<  SWAP  0xFFFF AND  OR  ; [THEN]
[IFNDEF] LWSPLIT
: LWSPLIT ( l -- w.low w.high )  \ split a long into two words
   DUP  0xFFFF AND  SWAP 0x10 >>
;
[THEN]

[IFNDEF] BITS : BITS  ( n bit# #bits -- bits )  -ROT >>  SWAP LOWMASK AND  ;
[THEN]
[IFNDEF] PACK : PACK DUP >R $! R> ; [THEN]
[IFNDEF] 0>= : 0>= 0< 0= ; [THEN]
[IFNDEF] (U.) : (U.) 0 (D.) ; [THEN]
[IFNDEF] (.) : (.) DUP 0< (D.) ; [THEN]
[IFNDEF] ,"
: ," ( addr u -- )
    [CHAR] " PARSE DUP C, CHARS HERE OVER ALLOT
    SWAP CMOVE ; [THEN]
[IFNDEF] +STR : +STR  ( pstr -- adr )  COUNT + ; [THEN]
[IFNDEF] CELL/ : CELL/ 3 RSHIFT ; [THEN]
[IFNDEF] STRING-ARRAY
: STRING-ARRAY  \ name ( -- )
   CREATE
   0 ,    ( the number of strings )
   0 ,    ( the starting address of the pointer table )
   DOES>  ( index pfa )
   2DUP @ ( index pfa  index #strings )
   0 SWAP WITHIN  0= ABORT" String array index out of range"    ( index pfa )
   TUCK  DUP CELL+ @ +      ( pfa index table-address )
   SWAP CELLS +  @ +           ( string-address )
;
: END-STRING-ARRAY ( -- )
   HERE                ( string-end-addr )
   LAST-CFA @ @ >BODY    ( string-end-addr pfa )
   DUP >R                 \ Remember pfa of word for use as the base address
   CELL+ HERE R@ - OVER  !  \ Store table address in the second word of the pf
   CELL+                ( string-end-addr first-string-addr )
   BEGIN               ( string-end-addr this-string-addr )
       2DUP >          ( string-end-addr this-string-addr )
   WHILE
       \ Store string address in table
       DUP R@ - ,      ( string-end-addr this-string-addr )
       \ Find next string address
       +STR            ( string-end-addr next-string-addr )
   REPEAT              ( string-end-addr next-string-addr )
   2DROP               ( )
   \ Calculate and store number of strings
   LAST-CFA @ @ >BODY       ( pfa )
   DUP DUP CELL+ @ +    ( pfa table-addr )
   HERE SWAP - CELL/  ( pfa #strings )
   SWAP  !
   R> DROP
;
[THEN]
[IFNDEF] ". : ". COUNT TYPE ; [THEN]

[IFNDEF] CASE:
:  CASE:QUIT
  BEGIN
    REFILL
  WHILE
      BEGIN    PARSE-NAME DUP
      WHILE    SFIND 0= ABORT" -?"
		DUP ['] ; = IF DROP EXIT THEN  ,
      REPEAT 2DROP
  REPEAT  ;

: CASE:
   CREATE , CASE:QUIT
   DOES>  SWAP 1+ CELLS + @ EXECUTE  ;  
[THEN] 

[IFNDEF] EXIT? VECT EXIT? ' FALSE TO EXIT? [THEN] 
[IFNDEF] H. : H. BASE @ HEX SWAP U. BASE ! ; [THEN] 
[IFNDEF] ON : ON -1 SWAP ! ; [THEN] 
[IFNDEF] OFF : OFF  0! ; [THEN] 

MODULE: DISASSEMBLER

USER INSTRUCTION
VARIABLE END-FOUND
USER PC
USER BRANCH-TARGET
USER DIS-OFFSET

: OP8@   ( -- b )  PC @  DIS-OFFSET @ +  C@  1 PC +!  ;
: OP16@  ( -- w )  OP8@   OP8@   BWJOIN  ;
: OP32@  ( -- l )  OP16@  OP16@  WLJOIN  ;

: BEXT  ( b -- l )  24 <<  24 >>A  ;
: WEXT  ( w -- l )  16 <<  16 >>A  ;

\ change size of data
TRUE VALUE OP32?
: OPV@  ( -- l | w )  OP32?  IF  OP32@  ELSE  OP16@  THEN  ;
TRUE VALUE AD32?
: ADV@  ( -- l | w )  AD32?  IF  OP32@  ELSE  OP16@   THEN  ;
: DIS16  ( -- )  FALSE TO OP32?  FALSE TO AD32?  ;
: DIS32  ( -- )  TRUE  TO OP32?  TRUE  TO AD32?  ;
\ XXX We should also change the register names e.g. from "eax" to "ax"
\ and handle renamed regs, prefix operators,

: GET-OP  ( -- )  OP8@ INSTRUCTION !  ;

: IBITS  ( right-bit #bits -- field )
   INSTRUCTION @ -ROT BITS
;
0 VALUE WBIT
: LOWBITS  ( -- n )  0 3 IBITS  ;
: LOW4BITS ( -- n )  0 4 IBITS  ;
: MIDBITS  ( -- n )  3 3 IBITS  ;
: HIBITS   ( -- n )  6 2 IBITS  ;

: .,  ( -- )  ." ,"  ;


CREATE EA-TEXT	32 ALLOT
: $ADD-TEXT  ( adr len -- )  EA-TEXT $+!  ;

CREATE DISP-BUF	34 ALLOT
: ?+  ( -- )
   EA-TEXT C@ 1 >  IF  S" +" $ADD-TEXT  THEN
;
: ?-  ( disp -- )
   EA-TEXT C@ 1 >  IF  S" -" $ADD-TEXT  NEGATE  THEN
;
: GET-DISP  ( mod -- adr len )
   CASE
   0  OF  S" "  EXIT    ENDOF
   1  OF  OP8@ BEXT     ENDOF
   2  OF  ADV@  AD32? 0=  IF  WEXT  THEN  ENDOF
   ENDCASE
   DUP 0>=  IF  ?+  ELSE  ?-  THEN
   (U.) DISP-BUF PACK  COUNT
;
\ Used when "w" field contains 0
STRING-ARRAY >REG8
," AL" ," CL" ," DL" ," BL" ," AH" ," CH" ," DH" ," BH"
END-STRING-ARRAY

\ Used when the instruction implies a 16-bit register
STRING-ARRAY >REG16
," AX" ," CX" ," DX" ," BX" ," SP" ," BP" ," SI" ," DI"
END-STRING-ARRAY

\ Used when "w" field contains 1, and when there is no "w" field
STRING-ARRAY >REGW
\    0       1       2       3       4       5       6       7
," EAX" ," ECX" ," EDX" ," EBX" ," ESP" ," EBP" ," ESI" ," EDI"
END-STRING-ARRAY

: >REG  ( -- adr len )  >REGW COUNT  OP32? 0=  IF  1 /STRING  THEN  ;
: >AREG  ( -- adr len )  >REGW COUNT  AD32? 0=  IF  1 /STRING  THEN  ;

: >GREG  ( -- adr len )  WBIT  IF  >REG  ELSE  >REG8 COUNT  THEN  ;

: .REG   ( reg -- )  >REG  TYPE  ;
: .REG8  ( reg -- )  >REG8 TYPE  ;

STRING-ARRAY  >SCALE
   ," "  ," *2"  ," *4"  ," *8"
END-STRING-ARRAY

: GET-SCALED  ( -- )
   HIBITS  MIDBITS                       ( scale index-reg )
   DUP 4 =  IF                           ( scale index-reg )
      DROP                               ( scale )
      IF  ?+  S" UNDEF" $ADD-TEXT  THEN   ( )
   ELSE                                  ( scale index-reg )
      ?+  >AREG $ADD-TEXT                ( scale )
      >SCALE COUNT  $ADD-TEXT            ( )
   THEN                                  ( )
;
: .[ S" ["  $ADD-TEXT ;
: .] S" ]"  $ADD-TEXT ;
: ADD-DISP  ( sib? reg mod -- )
   .[                            ( sib? reg mod )
   2DUP 0<>  SWAP 5 <>  OR  IF   ( sib? reg mod )   \ D32
      SWAP >AREG $ADD-TEXT       ( sib? mod )
   ELSE                          ( sib? reg mod )
      2DROP 2                    ( sib? mod=2 )
   THEN                          ( sib? mod )
   SWAP  IF  GET-SCALED  THEN    ( mod )
   GET-DISP  $ADD-TEXT           ( )
   .]                            ( )
;

: .EA32  ( reg mod -- )
   >R                                    ( reg r: mod )
   DUP 4 =  IF                           ( reg )     \ s-i-b
      DROP  GET-OP  TRUE  LOWBITS        ( true reg )
   ELSE                                  ( reg )     \ displaced
      FALSE SWAP                         ( false reg )
   THEN                                  ( sib? reg )
   R> ADD-DISP
;

STRING-ARRAY MODES16
   ," [BX+SI]"
   ," [BX+DI]"
   ," [BP+SI]"
   ," [BP+DI]"
   ," [SI]"
   ," [DI]"
   ," [BP]"
   ," [BX]"
END-STRING-ARRAY

HEX

: ADD-DISP16  ( disp -- )
   FFFF AND  (U.) DISP-BUF PACK COUNT  $ADD-TEXT
;
: +DISP16  ( disp -- )
   DUP 0<  IF
      S" -" $ADD-TEXT  NEGATE
   ELSE
      S" +" $ADD-TEXT
   THEN
   ADD-DISP16
;

: .EA16  ( reg mod -- )
   OVER 6 =  OVER 0= AND  IF             ( reg mod )
      \ DISP16 ONLY, TAKES THE PLACE OF THE [BP] MODE
      2DROP OP16@ .[ ADD-DISP16 .] EXIT
   THEN                                  ( reg mod )
   SWAP MODES16 COUNT $ADD-TEXT          ( mod )
   CASE
      1 OF  OP8@  BEXT +DISP16  ENDOF
      2 OF  OP16@ WEXT +DISP16  ENDOF
   ENDCASE
;
: .EA  ( -- )
   S" "  EA-TEXT  PLACE
   LOWBITS  HIBITS >R                    ( reg ) ( r: mod )
   R@  3 =  IF                           ( reg )     \ register direct
      >GREG $ADD-TEXT                    ( )
      R> DROP  EA-TEXT ". EXIT
   THEN                                  ( reg )
   R> AD32?  IF  .EA32  ELSE  .EA16  THEN
   EA-TEXT ".
;
: ,EA  ( -- )  .,  .EA  ;


\ Display formatting
\ VARIABLE START-COLUMN
: OP-COL  ( -- ) 9 EMIT
\ START-COLUMN @  9 +  #OUT @  -  1 MAX  SPACES 
 ;

STRING-ARRAY >SEGMENT
   ," ES"  ," CS"  ," SS"  ," DS"  ," FS"  ," GS"
END-STRING-ARRAY

STRING-ARRAY >BINOP
   ," ADD"  ," OR"  ," ADC"  ," SBB"  ," AND"  ," SUB"  ," XOR"  ," CMP"
END-STRING-ARRAY

: .BINOP  ( n -- )  >BINOP ". OP-COL  ;

STRING-ARRAY >UNOP
   ," INC"  ," DEC"  ," PUSH"  ," POP"
END-STRING-ARRAY

: .SEGMENT  ( -- )  3 2 IBITS  >SEGMENT ".  ;

STRING-ARRAY >ADJUST
   ," DAA"  ," DAS"  ," AAA"  ," AAS"
END-STRING-ARRAY
: .FESCAPE  ( -- )  ." LATER, DUDE"  ;

0 VALUE REG-FIELD
: GET-EA  ( -- )  GET-OP  MIDBITS TO REG-FIELD  ;

: SREG  ( -- )  REG-FIELD  >SEGMENT ".  ;
: .MM   ( reg# -- )  ." MM" (.) TYPE  ;
: MREG  ( -- )  REG-FIELD  .MM  ;
: .MEA  ( -- )  HIBITS 3 =  IF  LOWBITS .MM  ELSE  .EA  THEN  ;

: GB/V  ( -- )  REG-FIELD  >GREG TYPE  ;
: IB    ( -- )  OP8@ BEXT  (.) TYPE  ;
: ,IB  ( -- )  .,  IB  ;
: IUB   ( -- )  OP8@       (.) TYPE  ;
: IW    ( -- )  OP16@ (.) TYPE  ;
: IV    ( -- )  OPV@ (.) TYPE  ;
: IUV   ( -- )  ADV@ (U.) TYPE  ;
: ,IB/V ( -- )  .,  WBIT  IF  OPV@  ELSE  OP8@  THEN  (U.) TYPE  ;
: AL/X  ( -- )  WBIT  IF  ." EAX"  ELSE  ." AL"  THEN  ;
: ,AL/X ( -- )  .,  AL/X  ;
: ,CL  ( -- )  .,  ." CL"  ;

: .MODE  ( mode -- )
   1 >>
   CASE
      0  OF  GET-EA  .EA   .,  GB/V  ENDOF
      1  OF  GET-EA  GB/V  ,EA       ENDOF
      2  OF          AL/X  ,IB/V     ENDOF
   ENDCASE
;
: .PUSH  ( -- )  ." PUSH" OP-COL  ;
: .POP   ( -- )  ." POP"  OP-COL  ;

STRING-ARRAY >COND
   ," O"  ," NO"  ," B"  ," AE"  ," E"  ," NE"  ," BE"  ," A"
   ," S"  ," NS"  ," PE" ," PO"  ," L"  ," GE"  ," LE"  ," G"
END-STRING-ARRAY

: SHOWBRANCH  ( offset -- )
   PC @  OP32?  IF  ( offset pc )
      +                    ( pc' )
   ELSE                    ( offset pc )
      LWSPLIT  -ROT        ( pc.high offset pc.low )
      + 0xFFFF AND        ( pc.high pc.low' )
      SWAP WLJOIN          ( pc' )
   THEN                    ( pc' )
   DUP BRANCH-TARGET !
   DUP H.
   NEAR_NFA
   IF ."  ( " ID. ."  )"
   ELSE  DROP
   THEN

;
: JB  ( -- )  OP8@ BEXT  SHOWBRANCH  ;
: JV  ( -- )  OPV@  SHOWBRANCH  ;

: .JCC  ( -- )  ." J"  LOW4BITS >COND ".  OP-COL JB  ;
: EA,G  ( -- )  GET-EA  .EA ., GB/V  ;
: G,EA  ( -- )  GET-EA  GB/V ,EA  ;

: DECODE-OP  ( -- high4bits )  GET-OP   0 1 IBITS TO WBIT  4 4 IBITS   ;

STRING-ARRAY >GRP6
   ," SLDT"  ," STR"  ," LLDT"  ," LTR"  ," VERR"  ," VERW"
END-STRING-ARRAY
STRING-ARRAY >GRP7
   ," SGDT" ," SIDT" ," LGDT" ," LIDT" ," SMSW" ," UNIMP" ," LMSW" ," INVLPG"
END-STRING-ARRAY
STRING-ARRAY >GRP8
   ," "  ," "  ," "  ," "  ," BT"  ," BTS"  ," BTR"  ," BTC"
END-STRING-ARRAY

: .UNIMP  ( -- )  ." UNIMP"  ;

: EW  ( -- )  .EA  ;  \ XXX SHOULD PRINT, E.G. BX NOT EBX
: 2B0OP  ( -- )
   LOW4BITS  CASE
      0 OF  GET-EA  MIDBITS >GRP6 ".  OP-COL  EW  ENDOF
      1 OF  GET-EA  MIDBITS >GRP7 ".  OP-COL  EW  ENDOF
      2 OF  ." LAR"  OP-COL  1 TO WBIT  G,EA  ENDOF
      3 OF  ." LSR"  OP-COL  1 TO WBIT  G,EA  ENDOF
      6 OF  ." CLTS"  ENDOF
      8 OF  ." INVD"  ENDOF
      9 OF  ." WBINVD"  ENDOF
         .UNIMP
   ENDCASE
;
: .MOV  ( -- )  ." MOV"  OP-COL  ;
: .BYTE  ( -- )  ." BYTE PTR "  ;
\ Don't bother to say "byte" for register direct addressing mode
: ?.BYTE  ( -- )  HIBITS 3 <>  WBIT 0=  AND  IF  .BYTE  THEN  ;

: .R#  ( -- )  REG-FIELD (.) TYPE  ;
: MOVSPEC  ( -- )
   .MOV
   1 TO WBIT		\ These are always 32 bits
   LOW4BITS  GET-EA  CASE
      \ XXX Warning - the 386 and 486 books disagree about the
      \ operand order of these instructions.
      2 OF   ." CR" .R#  ,EA       ENDOF
      3 OF   ." DR" .R#  ,EA       ENDOF
      6 OF   ." TR" .R#  ,EA       ENDOF
      0 OF   .EA  .,  ." CR" .R#   ENDOF
      1 OF   .EA  .,  ." DR" .R#   ENDOF
      4 OF   .EA  .,  ." TR" .R#   ENDOF
         .UNIMP
   ENDCASE
;
: 2BAOP  ( -- )
   LOW4BITS  CASE
      0 OF  .PUSH  ." FS"  ENDOF
      1 OF  .POP   ." FS"  ENDOF
      2 OF  ." CPUID"      ENDOF
      3 OF  ." BT"   OP-COL             EA,G  ENDOF
      4 OF  ." SHLD" OP-COL  1 TO WBIT  EA,G  ,IB  ENDOF
      5 OF  ." SHLD" OP-COL  1 TO WBIT  EA,G  ,CL  ENDOF
      6 OF  ." CMPXCHG" OP-COL          EA,G  ENDOF
      7 OF  ." CMPXCHG" OP-COL          EA,G  ENDOF
      8 OF  .PUSH  ." GS"  ENDOF
      9 OF  .POP   ." GS"  ENDOF
      A OF  ." RSM"  END-FOUND ON  ENDOF
      B OF  ." BT"   OP-COL             EA,G  ENDOF
      C OF  ." SHRD" OP-COL  1 TO WBIT  EA,G  ,IB  ENDOF
      D OF  ." SHRD" OP-COL  1 TO WBIT  EA,G  ,CL  ENDOF
      F OF  ." IMUL" OP-COL  G,EA  ENDOF
         .UNIMP
   ENDCASE
;
\ Decode operands for lds,..,lgs,lss instructions
: .LFP  ( -- )  OP-COL GET-EA MIDBITS .REG  ,EA   ;

: REG,  ( -- )  OP-COL  GET-EA REG-FIELD .REG  .,  ;
: ?.B/W  ( -- )
   HIBITS 3 <>  IF
      WBIT  IF  ." WORD PTR "  ELSE  .BYTE  THEN
   THEN
;
: 2BBOP  ( -- )
   LOW4BITS  CASE
      2 OF  ." LSS"    .LFP               ENDOF
      3 OF  ." BTR"    OP-COL  EA,G       ENDOF
      4 OF  ." LFS"    .LFP               ENDOF
      5 OF  ." LGS"    .LFP               ENDOF
      6 OF  ." MOVZX"  REG,  ?.B/W  .EA   ENDOF
      7 OF  ." MOVZX"  REG,         .EA   ENDOF
      A OF  GET-EA MIDBITS >GRP8 ".  1 TO WBIT  OP-COL .EA ,IB    ENDOF
      B OF  ." BTC"    OP-COL  EA,G       ENDOF
      C OF  ." BSF"    REG,         .EA   ENDOF
      D OF  ." BSR"    REG,         .EA   ENDOF
      E OF  ." MOVSX"  REG,  ?.B/W  .EA   ENDOF
      F OF  ." MOVSX"  REG,         .EA   ENDOF
         .UNIMP
   ENDCASE
;
: 2BCOP  ( -- )
   LOW4BITS  CASE
      0 OF  ." XADD"  OP-COL  EA,G  ENDOF
      1 OF  ." XADD"  OP-COL  EA,G  ENDOF
         DUP 8 <  IF
            .UNIMP
         ELSE
            ." BSWAP" OP-COL  DUP 8 - .REG
         THEN
   ENDCASE
;
: 2B6OP  ( -- )
   LOW4BITS  CASE
      E OF  ." MOVD"  OP-COL GET-EA  1 TO WBIT  MREG ., .EA  ENDOF
      F OF  ." MOVQ"  OP-COL GET-EA  1 TO WBIT  MREG ., .MEA ENDOF
      .UNIMP
   ENDCASE
;
: 2B7OP  ( -- )
   LOW4BITS  CASE
      7 OF  ." EMMS"  ENDOF
      8 OF  ." SVDC"  OP-COL GET-EA  1 TO WBIT  .EA  ., SREG ENDOF
      9 OF  ." RSDC"  OP-COL GET-EA  1 TO WBIT  SREG ., .EA  ENDOF
      E OF  ." MOVD"  OP-COL GET-EA  1 TO WBIT  .EA  ., MREG ENDOF
      F OF  ." MOVQ"  OP-COL GET-EA  1 TO WBIT  .MEA ., MREG ENDOF
      .UNIMP
   ENDCASE
;
: MSROP  ( -- )
   LOW4BITS CASE
      0 OF  ." WRMSR"  ENDOF
      1 OF  ." RDTSC"  ENDOF
      2 OF  ." RDMSR"  ENDOF
      8 OF  ." SMINT"  ENDOF
      .UNIMP
   ENDCASE
;

: .2BYTE  ( -- )
   DECODE-OP  CASE
      0 OF  2B0OP  ENDOF
      2 OF  MOVSPEC  ENDOF
      3 OF  MSROP    ENDOF
      6 OF  2B6OP    ENDOF
      7 OF  2B7OP    ENDOF
      8 OF  ." J"   LOW4BITS >COND ".  OP-COL  JV  ENDOF
      9 OF  ." SET" LOW4BITS >COND ".  OP-COL  0 TO WBIT  GET-EA  .EA  ENDOF
      A OF  2BAOP  ENDOF
      B OF  2BBOP  ENDOF
      C OF  2BCOP  ENDOF
         .UNIMP
   ENDCASE
;
: .WIERD  ( -- )
   INSTRUCTION @  F =  IF  .2BYTE  EXIT THEN
   INSTRUCTION @  0x21 AND  CASE
      0  OF  .PUSH    .SEGMENT   ENDOF
      1  OF  .POP     .SEGMENT   ENDOF
     20  OF           .SEGMENT  ." :"   ENDOF
     21  OF  3 2 IBITS >ADJUST  ". ENDOF
   ENDCASE
;
: .2OP  ( -- )
   LOWBITS 5 >  IF
      .WIERD
   ELSE
      MIDBITS 
.BINOP  LOWBITS .MODE
   THEN
;
: .1OP  ( -- )
   3 2 IBITS  >UNOP ".  OP-COL  LOWBITS .REG
;

VECT DIS-BODY
: DIS-OP:  ( -- )
   OP32? 0=  TO OP32?
   ['] DIS-BODY CATCH  ( ERROR? )
   OP32? 0=  TO OP32?
   THROW
;
: DIS-AD:  ( -- )
   AD32? 0=  TO AD32?
   ['] DIS-BODY CATCH  ( ERROR? )
   AD32? 0=  TO AD32?
   THROW
;

: .OP6  ( -- )
   LOW4BITS CASE
      0 OF  ." PUSHAD" ENDOF
      1 OF  ." POPAD"  ENDOF
      2 OF  ." BOUND"  OP-COL   GET-EA REG-FIELD .REG ,EA  ENDOF
      3 OF  ." ARPL"   OP-COL   EA,G  ENDOF  \ XXX SHOULD BE W-REG, NOT D-REG
      4 OF  ." FS:"  ENDOF
      5 OF  ." GS:"  ENDOF
      6 OF  ." OP: "  DIS-OP:  ENDOF
      7 OF  ." AD: "  DIS-AD:  ENDOF
      8 OF  .PUSH    IV  ENDOF
      9 OF  ." IMUL" OP-COL G,EA ., IV  ENDOF
      A OF  .PUSH    IB  ENDOF
      B OF  ." IMUL" OP-COL G,EA ,IB    ENDOF
      C OF  ." INSB"  ENDOF
      D OF  ." INSD"  ENDOF
      E OF  ." OUTSB" ENDOF
      F OF  ." OUTSD" ENDOF
   ENDCASE
;

: GRP1OP  ( -- )  GET-EA  MIDBITS .BINOP  ;
: .TEST  ( -- )  ." TEST" OP-COL  ;

: .OP8  ( -- )
   LOW4BITS  CASE
      0 OF  GRP1OP    .BYTE .EA ., IUB  ENDOF
      1 OF  GRP1OP          .EA ., IV   ENDOF
\ The opcode map in the Intel manual says 82 is "movb", but it actually
\ appears to be the same as "80" - the sign extension of the immediate
\ byte is irrelevant to a byte-width operation
\     2 OF  ." MOVB"       AL/X ,IB   ENDOF
      2 OF  GRP1OP    .BYTE .EA ,IB   ENDOF \ OPCODE MAPS SAYS "MOVB"
      3 OF  GRP1OP          .EA ,IB   ENDOF
      4 OF  .TEST           EA,G  ENDOF
      5 OF  .TEST           EA,G  ENDOF
      6 OF  ." XCHG" OP-COL EA,G  ENDOF
      7 OF  ." XCHG" OP-COL EA,G  ENDOF
      8 OF  .MOV            EA,G  ENDOF
      9 OF  .MOV            EA,G  ENDOF
      A OF  .MOV            G,EA  ENDOF
      B OF  .MOV            G,EA  ENDOF
      C OF  .MOV  GET-EA  1 TO WBIT  .EA  ., SREG  ENDOF
      E OF  .MOV  GET-EA  1 TO WBIT  SREG ,EA   ENDOF
      D OF  ." LEA" OP-COL  G,EA         ENDOF
      F OF  .POP  GET-EA  .EA  ENDOF
   ENDCASE
;

: .4X  ( N -- )  BASE @ >R HEX 0 <# # # # # #> TYPE R> BASE ! ;
: AP  ( -- )
   OPV@ ." FAR "
   OP16@  BASE @ >R  (.) TYPE  R> BASE !
   ." :"  OP32?  IF  H.  ELSE  .4X  THEN
   END-FOUND ON
;

STRING-ARRAY >8LINE-OPS
  ," CWDE"  ," CDQ"  ," CALL"  ," WAIT"  ," PUSHFD" ," POPFD" ," SAHF" ," LAHF"
END-STRING-ARRAY

: .OP9  ( -- )
   LOW4BITS                                                       ( low4bits )
   DUP  8 <  IF  ." XCHG"  OP-COL  .REG  ., ." EAX"  EXIT  THEN   ( low4bits )
   DUP 8 -  >8LINE-OPS ".   A =  IF  OP-COL AP  THEN
;

: .OPA  ( -- )
   LOW4BITS CASE
      0 OF  .MOV  AL/X ., ." [" IUV ." ]"  ENDOF
      1 OF  .MOV  AL/X ., ." [" IUV ." ]"  ENDOF
      2 OF  .MOV  ." [" IUV ." ]" ,AL/X  ENDOF
      3 OF  .MOV  ." [" IUV ." ]" ,AL/X  ENDOF
      4 OF  ." MOVSB"  ENDOF
      5 OF  ." MOVSD"  ENDOF
      6 OF  ." CMPSB"  ENDOF
      7 OF  ." CMPSD"  ENDOF
      8 OF  .TEST  AL/X ,IB/V  ENDOF
      9 OF  .TEST  AL/X ,IB/V  ENDOF
      A OF  ." STOSB"  ENDOF
      B OF  ." STOSD"  ENDOF
      C OF  ." LODSB"  ENDOF
      D OF  ." LODSD"  ENDOF
      E OF  ." SCASB"  ENDOF
      F OF  ." SCASD"  ENDOF
   ENDCASE
;
STRING-ARRAY >GRP2-OP
   ," ROL"   ," ROR"  ," RCL"  ," RCR"  ," SHL"  ," SHR"  ," SAL"  ," SAR"
END-STRING-ARRAY
: GRP2OP  ( -- )  GET-EA  MIDBITS >GRP2-OP ". OP-COL  ;
: .RET   ( -- )  ." RET"  OP-COL  END-FOUND ON  ;
: .NEAR  ( -- )  ." NEAR "  ;
: .FAR   ( -- )  ." FAR "  ;

: .OPC  ( -- )
   LOW4BITS CASE
      0 OF  GRP2OP        ?.BYTE .EA ,IB    ENDOF
      1 OF  GRP2OP               .EA ,IB    ENDOF
      2 OF  .RET           .NEAR IW         ENDOF
      3 OF  .RET           .NEAR            ENDOF
      4 OF  ." LES"        .LFP             ENDOF
      5 OF  ." LDS"        .LFP             ENDOF
      6 OF  .MOV           GET-EA  ?.BYTE .EA  ,IB/V  ENDOF
      7 OF  .MOV           GET-EA         .EA  ,IB/V  ENDOF
      8 OF  ." ENTER" OP-COL  IW ,IB        ENDOF
      9 OF  ." LEAVE"                       ENDOF
      A OF  .RET             .FAR  IW       ENDOF
      B OF  .RET             .FAR           ENDOF
      C OF  ." INT"   OP-COL ." 3"          ENDOF
      D OF  ." INT"   OP-COL IUB            ENDOF
      E OF  ." INTO"                        ENDOF
      F OF  ." IRETD"  END-FOUND ON         ENDOF
   ENDCASE
;

VECT .ESC
: NULL.ESC  ( -- )
   ." Coprocessor Escape " INSTRUCTION @ .  OP8@ .
;
' NULL.ESC TO .ESC

: .OPD  ( -- )
   LOW4BITS  CASE
      0 OF  GRP2OP   .BYTE .EA  .,  ." 1"   ENDOF
      1 OF  GRP2OP         .EA  .,  ." 1"   ENDOF
      2 OF  GRP2OP   .BYTE .EA  ,CL  ENDOF
      3 OF  GRP2OP         .EA  ,CL  ENDOF
      4 OF  ." AAM"   OP8@ DROP  ENDOF   \ D4 is always followed by 0A (10)
      5 OF  ." AAD"   OP8@ DROP  ENDOF   \ D5 is always followed by 0A (10)
      6 OF  .UNIMP    ENDOF
      7 OF  ." XLATB" ENDOF
          .ESC
   ENDCASE
;

STRING-ARRAY >LOOPS
   ," LOOPNE"  ," LOOPE"  ," LOOP"  ," JCXZ"
END-STRING-ARRAY

: .IN    ( -- )  ." IN"   OP-COL  ;
: .OUT   ( -- )  ." OUT"  OP-COL  ;
: .CALL  ( -- )  ." CALL" OP-COL  ;
: .JMP   ( -- )  ." JMP"  OP-COL  END-FOUND ON  ;
: DX  ( -- )  ." EDX"  ;

: UB    ( -- )  OP8@  (.) TYPE  ;
: .OPE  ( -- )
   LOW4BITS  DUP  4 <  IF  >LOOPS ".  OP-COL JB   EXIT  THEN   ( low4bits )
   CASE
      4 OF  .IN   AL/X  ., UB   ENDOF
      5 OF  .IN   AL/X  ., UB   ENDOF
      6 OF  .OUT  UB    ,AL/X   ENDOF
      7 OF  .OUT  UB    ,AL/X   ENDOF
      8 OF  .CALL JV            ENDOF
      9 OF  .JMP  JV            ENDOF
      A OF  .JMP  AP            ENDOF
      B OF  .JMP  JB            ENDOF
      C OF  .IN   AL/X  .,  DX  ENDOF
      D OF  .IN   AL/X  .,  DX  ENDOF
      E OF  .OUT  DX    ,AL/X   ENDOF
      F OF  .OUT  DX    ,AL/X   ENDOF
   ENDCASE
;

STRING-ARRAY >FLINE-OPS
   ," LOCK"  ," UNIMP"  ," REPNE"  ," REPE"  ," HLT"   ," CMC"  ," "  ," "
   ," CLC"   ," STC"    ," CLI"    ," STI"   ," CLD"   ," STD"
END-STRING-ARRAY

: ACC-OP  ( -- )  OP-COL  AL/X  ,EA   ;
: .GRP3  ( -- )
   GET-EA
   MIDBITS  CASE
      0 OF   .TEST             ?.BYTE .EA  ,IB/V  ENDOF
      1 OF   .TEST                    .EA  ,IB/V  ENDOF
      2 OF   ." NOT"   OP-COL  ?.BYTE .EA  ENDOF
      3 OF   ." NEG"   OP-COL  ?.BYTE .EA  ENDOF
      4 OF   ." MUL"   ACC-OP              ENDOF
      5 OF   ." IMUL"  ACC-OP              ENDOF
      6 OF   ." DIV"   ACC-OP              ENDOF
      7 OF   ." IDIV"  ACC-OP              ENDOF
   ENDCASE
;
: .GRP4  ( -- )
   GET-EA MIDBITS  DUP 1 >  IF
      DROP .UNIMP
   ELSE
      IF  ." DEC"  ELSE  ." INC"  THEN
      OP-COL  ?.BYTE .EA
   THEN
;
: .EP  ( -- )  ." FAR PTR "  .EA  ;
: .GRP5  ( -- )
   GET-EA  MIDBITS  CASE
      0 OF  ." INC"  OP-COL  .EA   ENDOF
      1 OF  ." DEC"  OP-COL  .EA   ENDOF
      2 OF  .CALL  .EA   ENDOF
      3 OF  .CALL  .EP   ENDOF
      4 OF  .JMP   .EA   INSTRUCTION @  E7 =  END-FOUND !  ENDOF
      5 OF  .JMP   .EP   ENDOF
      6 OF  .PUSH  .EA   ENDOF
         .UNIMP
   ENDCASE
;
: .OPF  ( -- )
   LOW4BITS  LOWBITS  6 <  IF
      >FLINE-OPS ".
   ELSE
      CASE
         6 OF  .GRP3   ENDOF
         7 OF  .GRP3   ENDOF
         E OF  .GRP4   ENDOF
         F OF  .GRP5   ENDOF
      ENDCASE
   THEN
;
: .MOVI ( -- )
   ." MOV" OP-COL  3 1 IBITS  TO WBIT  LOWBITS >GREG TYPE  ,IB/V
;
0x10 CASE: OP-CLASS
   .2OP  .2OP  .2OP  .2OP  .1OP  .1OP  .OP6  .JCC
   .OP8  .OP9  .OPA  .MOVI .OPC  .OPD  .OPE  .OPF
;

: (DIS-BODY)  ( -- )  BRANCH-TARGET OFF  DECODE-OP  OP-CLASS  ;
' (DIS-BODY) TO DIS-BODY
: DIS1  ( -- )
\   ??CR
   PC @ H.  4 SPACES \ #OUT @  START-COLUMN !
   DIS-BODY
;
: DIS2
   PC @   DIS1
   ."    " 9 EMIT  PC @ SWAP  DO I C@ H. LOOP  CR ;

: +DIS  ( -- )
   BASE @ >R  HEX
   END-FOUND OFF
   BEGIN DIS2
     END-FOUND @ 
     EXIT? OR
  UNTIL
   R> BASE !
;

: ^DIS  ( adr -- )
 ." Q - exit" CR
   PC ! 
   BASE @ >R  HEX
   END-FOUND OFF
   BEGIN DIS2 KEY 0x20 OR [CHAR] q =
   UNTIL
   R> BASE !
;

: DIS      ( adr -- ) 
  PC ! 
  +DIS 
 ;

: PC!DIS1  ( ADR -- )   PC !   DIS1  ;

EXPORT

ALIAS PC!DIS1 PC!DIS1
ALIAS +DIS +DIS
ALIAS DIS DIS
ALIAS DIS16 DIS16
ALIAS DIS32 DIS32
: ^DIS ^DIS ;
: SSDD ' ^DIS ;
: SHOW ' DIS ;

;MODULE

