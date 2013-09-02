//#include "./cygwin.h"

#define ticDROP ticDROP_V
#define ticDUP ticDUP_V

#define LastCFA  INIT
//#define LastCFA  LWRD

//#define LastNFA  INIT-(4)
#define LastNFA  LASTWORD-(9)
#define reserve Mreserve-main_task
// пїЅпїЅпїЅпїЅ б«®пїЅпїЅ

#define def(name,len,flags,next) \
 .int  .+4+4+1+len+4; \
 .int flags;    \
 .int  next-1; \
 .byte len; \
 .ascii name

#define mdef(name,len,flags,next,xt) \
 .int  .+4+4+1+len+4; \
 .int flags;    \
 .int  next-1;  \
 .byte len; \
 .ascii name;   \
 .globl xt; xt:
DEFLAST=0

#define fordef(name,len,flags,xt) \
 .int  xt; \
 .int flags; \
 .int  DEFLAST; \
 DEFLAST=.; \
 .byte len; \
 .ascii name;

#define fdef(name,len,flags,xt) \
 .int  xt; \
 .int flags;    \
 .int  DEFLAST; \
DEFLAST=.; \
 .byte len; \
 .ascii name;   \
 .globl xt; xt:

#define idef(name,len,flags,xt) \
 .int  xt; \
 .int flags;    \
 .int  DEFLAST; \
DEFLAST=.; \
 .byte len; \
 .ascii name;   \
 .globl xt; xt: \
    lea    -4(%rbp), %rbp; \
    mov     %rax,(%rbp); \
  call _Z##len##xt##v; \
  ret

#define jdef(name,len,flags,xt,xt1) \
 .int  xt; \
 .int flags;    \
 .int  DEFLAST; \
DEFLAST=.; \
 .byte len; \
 .ascii name;   \
 .globl xt; xt: \
  mov %rax,%r12; \
  call xt1; \
  mov %r12,%rax; \
  ret

#define vdef(name,len,flags,xt) jdef(name,len,flags,xt,_Z##len##xt##v)

// пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅвҐЄпїЅпїЅ пїЅ пїЅпїЅпїЅа®ў FORTH пїЅпїЅвҐ¬пїЅ
#define TIB_SIZE 1027
#define PAD_SIZE 1027
#define HERE_SIZE 102400
#define VOCABULARY_POOL 10240000
#define STACK_SIZE 20480

fftst:
   push %rbp
  callq f_tst1
   pop %rbp
   ret

.globl tst0
    shl    $0x20,%rax
tst0:
.globl amain
amain:
        push %rbp
        push %rbx
        mov %rsp,BYELEVEL

        xor %eax,%eax
        mov $_Stekc+STACK_SIZE-0x20,%rbp
        mov %esp,T_R0
        mov $main_task,%r14

        mov     %rsp,%rax
        and $0xffffffff80000000,%rax
        mov     %rax,HSPSAVE

        call    LastCFA
            div     %ecx
            div     %rcx
            mull    (%rbp)
        .byte 0x48, 0xf7, 0x65, 00


MBYE:   mov BYELEVEL,%rsp
        pop %rbx
        pop %rbp
        ret

.data

mdef("TT",2,0,NNN-0x3,TT)
    dec     %rax
1: jmp 1b
  ret


fdef("ZTYPE",5,0,ZTYPE)
    mov    %eax,%edi
    call    LZTYPE
    jmp DROP


fdef("HELLO",5,0,HELLO)
        movl    $5+3, %edx
        mov     $.LC5, %rsi
        movl    $1, %edi
        call    write
        ret
.LC5:  .string "Hello!!!"

fdef("DUP",3 ,0 ,DUP)
        lea    -8(%rbp),%rbp
        mov     %rax,(%rbp)
        ret

fdef("OVER",4,0 ,OVER)
        lea     -8(%rbp),%rbp
        mov     %rax,(%rbp)
        mov     8(%rbp),%rax
        retq

fdef("SWAP",4,0 ,SWAP)
        mov     (%rbp),%rdx
        mov     %rax,(%rbp)
        mov     %rdx,%rax
        retq

fdef("ROT",3,0 ,ROT)
        mov     (%rbp),%rdx
        mov     %rax,(%rbp)
        mov     8(%rbp),%rax
        mov     %rdx,8(%rbp)
        retq

fdef("-ROT",4,0 ,subROT)
        mov     8(%rbp),%rdx
        mov     %rax,8(%rbp)
        mov     (%rbp),%rax
        mov     %rdx,(%rbp)
        retq


fdef("DROP",4,0 ,DROP)
DgreatS:
        mov     (%rbp),%rax
NIP:    lea     8(%rbp), %rbp
        ret

fordef("D>S",3,0 ,DROP)
fordef("NIP",3,0 ,NIP)

fdef("2DUP",4,0 ,_2DUP)
        mov     (%rbp),%rdx
        mov     %rax,-8(%rbp)
        mov     %rdx,-8*2(%rbp)
        lea    -8*2(%rbp), %rbp
        ret

fdef("2DROP",5,0 ,_2DROP)
        mov     8(%rbp),%rax
        lea     8*2(%rbp),%rbp
        retq

fdef("3DROP",5,0 ,_3DROP)
        mov     16(%rbp),%rax
        lea     24(%rbp),%rbp
        retq

fdef("4DROP",5,0 ,_4DROP)
        mov     24(%rbp),%rax
        lea     32(%rbp),%rbp
        retq

fdef("2SWAP",5,0 ,_2SWAP)
        mov 0(%rbp),%rcx
        mov 0x8(%rbp),%rdx
        mov 0x8*2(%rbp),%rbx
        mov %rcx,0x8*2(%rbp)
        mov %rax,0x8(%rbp)
        mov %rbx,0(%rbp)
        mov %rdx,%rax
        retq

fdef("PICK",4,0 ,PICK)
        mov (%rbp,%rax,8),%rax
        retq

fdef("TUCK",4,0 ,TUCK)
        lea -8(%rbp),%rbp
        mov 8(%rbp),%rdx
        mov %rax,8(%rbp)
        mov %rdx,(%rbp)
        retq

fdef("L@",2,0,Lload)
/* a-addr -- x */
        mov    (%rax),%eax
        cltq
        ret

fdef("@",1,0,load)
/* a-addr -- x */
        mov    (%rax),%rax
        ret

fdef("A@",2,0,Aload)
/* a-addr -- x */
        mov    (%rax),%rax
        ret

fdef("C@",2,0,Cload)
/* a-addr -- x */
        movzbl  (%rax),%eax
        ret

fdef("W@",2,0,Wload)
        movzwl  (%rax),%eax
        retq

fdef("2@",2,0,_2load)
        mov     8(%rax),%rdx
        lea     -8(%rbp),%rbp
        mov     %rdx,(%rbp)
        mov     (%rax),%rax
        ret

fdef("2!",2,0,_2store)
        mov     (%rbp),%rdx
        mov     %rdx,(%rax)
        mov     8(%rbp),%rdx
        mov     %rdx,8(%rax)
        lea     24(%rbp),%rbp
        mov     -8(%rbp),%rax
        ret
// MOV     EDX , 0 [EBP]
// MOV     [EAX] , EDX
// MOV     EDX , 4 [EBP]
// MOV     4 [EAX] , EDX
// LEA     EBP , C [EBP]
// MOV     EAX , FC [EBP]

fdef("L!",2,0,Lsave)
/* x a-addr --  */
        mov    (%rbp),%edx
        movl    %edx,(%rax)
        mov    8(%rbp),%rax
        lea    8*2(%rbp),%rbp
        ret

fdef("!",1,0,save)
/* x a-addr --  */
        mov    (%rbp),%rdx
        mov     %rdx,(%rax)
        mov    8(%rbp),%rax
        lea    8*2(%rbp),%rbp
        ret

fdef("+!",2,0,addsave)
/* x a-addr --  */
        mov    (%rbp),%edx
        addl    %edx,(%rax)
        mov    8(%rbp),%rax
        lea    8*2(%rbp),%rbp
        ret

fdef("C!",2,0,Csave)
/* c a-addr --  */
        movb    (%rbp),%dl
        movb    %dl,(%rax)
        mov    8(%rbp),%rax
        lea    8*2(%rbp),%rbp
        ret

fdef("W!",2,0,Wsave)
/* w a-addr --  */
        mov     (%rbp),%edx
        mov     %dx,(%rax)
        mov     8(%rbp),%rax
        lea     8*2(%rbp),%rbp
        retq

fdef("0!",2,0,_0save)
/*  a-addr --  */
        movq    $0,(%rax)
        mov     (%rbp),%rax
        lea    8(%rbp),%rbp
        ret

fdef("1+!",3,0,_1addsave)
/*  a-addr --  */
        incq    (%rax)
        mov     (%rbp),%rax
        lea    8(%rbp),%rbp
        ret

fdef("=",1,0,equ)
        xor     (%rbp),%rax
        lea    8(%rbp), %rbp
        sub     $1,%rax
        sbb     %rax,%rax
        ret

fdef("D0=",3,0,D0equ)
        or      (%rbp),%rax
        lea     8(%rbp),%rbp
_0equ:  sub     $1,%rax
        sbb     %rax,%rax
        retq
fordef("0=",2,0,_0equ)

fdef("UMIN",4,0,UMIN)
        cmp     (%rbp),%rax
        ja      DROP
        lea     8(%rbp),%rbp
        retq
fdef("UMAX",4,0,UMAX)
        cmp     (%rbp),%rax
        jb      DROP
        lea     (%rbp),%rbp
        retq
fdef("MIN",3,0,MIN)
        cmp     (%rbp),%rax
        jg      DROP
        lea     8(%rbp),%rbp
        retq
fdef("MAX",3,0,MAX)
        cmp     (%rbp),%rax
        jl      DROP
        lea     8(%rbp),%rbp
        retq

fdef("ABS",3,0,ABS)
        or      %rax,%rax
        js      NEGATE
        retq

fdef("NEGATE",6,0,NEGATE)
        neg     %rax
        retq

fdef("INVERT",6,0,INVERT)
        not     %rax
        retq

fdef("1+",2,0,_1add)
CHARadd:
        inc     %rax
        ret
fordef("CHAR+",5,0,_1add)

fdef("1-",2,0,_1sub)
        lea     -1(%rax),%rax
        retq

fdef("2-",2,0,_2sub)
        lea -0x2(%rax),%rax
        retq

fdef("2+",2,0,_2add)
        lea 0x2(%rax),%rax
        retq

fdef("CELLS",5,0,CELLS)
        lea     (,%rax,8),%rax
        retq
fdef("CELL-",5,0,CELLsub)
        lea     -8(%rax),%rax
        retq
fdef("CELL+",5,0,CELLadd)
        lea     8(%rax),%rax
        retq

fdef("QCELL+",6,0,QCELLadd)
        lea     8(%rax),%rax
        retq

fdef("COUNT",5,0,COUNT)
        lea    -8(%rbp), %rbp
        lea    1(%rax), %rdx
        movzbq  (%rax),%rax
        mov     %rdx, (%rbp)
        ret

fdef("U>D",3,0,UgreatD)
        lea     -8(%rbp),%rbp
        mov     %rax,(%rbp)
        xor     %rax,%rax
        retq

fdef("S>D",3,0,SgreatD)
        cqto
        lea     -8(%rbp),%rbp
        mov     %rax,(%rbp)
        mov     %rdx,%rax
        retq

fdef("H-STDOUT",8,0,HsubSTDOUT)
        call    DUP
        mov     $1,%rax
        ret

fdef("UM/MOD",6,0,UMrslMOD)
        mov     %rax,%rcx
        mov     (%rbp),%rdx
        mov     8(%rbp),%rax
        div     %rcx
        lea     8(%rbp),%rbp
        mov     %rdx,(%rbp)
        retq

fdef("U/",2,0,Ursl)
        mov %rax,%rcx
        mov 0(%rbp),%rax
        xor %rdx,%rdx
        lea 8(%rbp),%rbp
        div %rcx
        retq

fdef("UM*",3,0,UMmul)
        mulq    (%rbp)
        mov     %rax,(%rbp)
        mov     %rdx,%rax
        retq

fdef("*",1,0,mul)
        imull   (%rbp)
        lea     8(%rbp),%rbp
        retq

fdef("/",1,0,rsl)
        mov %rax,%rcx
        mov (%rbp),%rax
        cqto
        idiv %rcx
        lea 8(%rbp),%rbp
        ret

fdef("2/",2,0,one_rshift)
        shr     $1,%rax
        ret
fdef("2*",2,0,one_lshift)
        shl     $1,%rax
        ret

fdef("*/",2,0,mul_rsl)
        mov     %rax,%rcx
        mov     8(%rbp),%rax
        imull   (%rbp)
        cqto
        idiv    %rcx
        lea     16(%rbp),%rbp
        ret

fdef("MOD",3,0,MOD)
        mov     %rax,%rcx
        mov     (%rbp),%rax
        cqto
        idiv    %rcx
        lea     8(%rbp),%rbp
        mov     %rdx,%rax
        retq

fdef("/MOD",4,0,rslMOD)
        mov     %rax,%rcx
        mov     (%rbp),%rax
        cqto
        idiv    %rcx
        mov     %rdx,(%rbp)
        ret

fdef("LSHIFT",6,0,LSHIFT)
        mov     %al,%cl
        mov     (%rbp),%rax
        shl     %cl,%rax
        lea     8(%rbp),%rbp
        ret

fdef("RSHIFT",6,0,RSHIFT)
        mov     %al,%cl
        mov     (%rbp),%rax
        shr     %cl,%rax
        lea     8(%rbp),%rbp
        ret

fdef("ARSHIFT",7,0,ARSHIFT)
        mov     %al,%cl
        mov     (%rbp),%rax
        sar     %cl,%rax
        lea     8(%rbp),%rbp
        ret

fdef("?DUP",4,0,queDUP)
        or %rax,%rax
        jne DUP
        retq

fdef(">",1,0,great)
        cmp     (%rbp),%rax
        setge   %al
        and     $1,%rax
        dec     %rax
        lea     8(%rbp),%rbp
        ret
fdef("<",1,0,less)
        cmp     (%rbp),%rax
        setle   %al
        and     $1,%rax
        dec     %rax
        lea     8(%rbp),%rbp
        ret

fdef("<>",2,0,lessgreat)
        xor     (%rbp),%rax
        neg     %rax
        sbb     %rax,%rax
        lea     8(%rbp),%rbp
        ret

fdef("0<>",3,0,_0lessgreat)
        neg     %rax
        sbb     %rax,%rax
        ret

fdef("0>",2,0,_0great)
        neg     %rax
_0less: sar     $63,%rax
        retq
fordef("0<",2,0,_0less)

fdef("U>",2,0,Ugreat)
        cmp     (%rbp),%rax
        sbb     %rax,%rax
        lea     8(%rbp),%rbp
        retq

fdef("U<",2,0,Uless)
        cmp     %rax,(%rbp)
        sbb     %rax,%rax
        lea     8(%rbp),%rbp
        retq

fdef("WITHIN",6,0,WITHIN)
    mov     8(%rbp),%rdx
    sub     (%rbp),%rax
    sub     (%rbp),%rdx
    sub     %rax,%rdx
    sbb     %rax,%rax
    lea     8*2(%rbp),%rbp
    ret

fdef("OR",2,0,OR)
        or      (%rbp),%rax
        lea     8(%rbp),%rbp
        ret

fdef("AND",3,0,AND)
        and     (%rbp),%rax
        lea     8(%rbp),%rbp
        ret

fdef("XOR",3,0,XOR)
        xor     (%rbp),%rax
        lea     8(%rbp),%rbp
        ret

fdef("-",1,0,sub)
//sub:
        neg     %rax
add:    add     (%rbp),%rax
        lea     8(%rbp),%rbp
        ret
fordef("+",1,0,add)

fdef("DNEGATE",7,0,DNEGATE)
        mov (%rbp),%rdx
        neg %rax
        neg %rdx
        sbb $0,%rax
        mov %rdx,(%rbp)
        retq

fdef("D+",2,0,Dadd)
        mov (%rbp),%rdx
        add %rdx,0x8*2(%rbp)
        adc 0x8(%rbp),%rax
        lea 0x8*2(%rbp),%rbp
        retq

fdef("D-",2,0,Dsub)
        mov (%rbp),%rdx
        sub %rdx,16(%rbp)
        sbb %rax,8(%rbp)
        mov 8(%rbp),%rax
        lea 16(%rbp),%rbp
        retq

fdef("D=",2,0,Dequ)
        mov (%rbp),%rdx
        xor 8(%rbp),%rax
        xor 16(%rbp),%rdx
        or  %rdx,%rax
        sub $1,%rax
        sbb %rax,%rax
        lea 24(%rbp),%rbp
        retq

fdef("D>",2,0,D_m)
        mov 16(%rbp),%rdx
        cmp %rdx,(%rbp)
        sbb 8(%rbp),%rax
        mov $0,%rax
        jge dmexit
        dec %rax
dmexit: lea 24(%rbp),%rbp
        retq

fdef("D<",2,0,D_b)
        mov (%rbp),%rdx
        cmp %rdx,16(%rbp)
        sbb %rax,8(%rbp)
        mov $0,%rax
        jge dbexit
        dec %rax
dbexit: lea 24(%rbp),%rbp
        retq

fdef("D2/",3,0,Dhalf)
        sar $1,%rax
        mov (%rbp),%rdx
        rcr $1, %rdx
        mov %rdx,(%rbp)
        retq

fdef("2OVER",5,0,DOVER)
        mov 16(%rbp),%rdx
        mov %rax,-8(%rbp)
        mov %rdx,-16(%rbp)
        mov 8(%rbp),%rax
        lea -16(%rbp),%rbp
        retq

fdef("PF.",3,0,PFdot)
        call    DUP
        mov %rsp,%rbx
//  and $-0x10,%rbx
        and $8,%rbx
        je  F_dot1
        push    %rbx
        call F_dot_STR
        pop     %rbx
        ret
F_dot1:
        jmp F_dot_STR

fdef("ZTOFLOAT",8,0,ZTOFLOAT)
        movl    %eax,%edi
        call    ZTO_FLOAT
        ret

jdef("F+",2,0,Fadd,f_plus)
jdef("F-",2,0,Fsub,f_minus)
jdef("F*",2,0,Fmul,f_star)
jdef("F/",2,0,Frsl,f_slash)
jdef("1e",2,0,_1e,x1e)

fdef("F!",2,0,Fsave)
        movl    %eax,%edi
        call    f_store
        ret

fdef("F@",2,0,Fload)
        movl    %eax,%edi
        call    f_fetch
        ret

fdef("F>D",3,0,FgreatD)
        lea     -8*2(%rbp),%rbp
        mov     %eax,8(%rbp)
        call    f_to_d
        mov     %rax,(%rbp)
        shr     $32,%rax
        ret

fdef("D>F",3,0,DgreatF)
            movl    (%rbp), %edi
        shl     $32,%rax
        or      %rax, %rdi
        lea     8*2(%rbp), %rbp
        jmp     d_to_f

//sub:


fdef("R@",2,0,Rload)
        lea     -8(%rbp),%rbp
        mov     %rax,(%rbp)
        mov     8(%rsp),%rax
        retq

fdef("R>",2,0,Rgreat)
        mov     (%rsp),%rbx
        lea    -8(%rbp), %rbp
        mov     %rax,(%rbp)
        mov     8(%rsp),%rax
        lea     0x10(%rsp),%rsp
        jmpq    *%rbx

fdef(">R",2,0,greatR)
        pop     %rbx
        push    %rax
        mov     (%rbp),%rax
        lea     8(%rbp), %rbp
        jmpq    *%rbx

fdef("2R>",3,0,_2Rgreat)
        mov     (%rsp),%rbx
        mov     %rax,-8(%rbp)
        mov     0x10(%rsp),%rcx
        mov     8(%rsp),%rax
        mov     %rcx,-8*2(%rbp)
        lea     -8*2(%rbp),%rbp
        lea     0x18(%rsp),%rsp
        jmpq    *%rbx

fdef("2>R",3,0,_2greatR)
        pop     %rbx
        pushq   (%rbp)
        push    %rax
        lea     8*2(%rbp),%rbp
        mov     -8(%rbp),%rax
        jmpq *%rbx

fdef("2R@",3,0,_2Rload)
        mov     %rax,-8(%rbp)
        mov     8(%rsp),%rax
        mov     0x10(%rsp),%rbx
        mov     %rbx,-8*2(%rbp)
        lea     -8*2(%rbp),%rbp
        retq

fdef("SP@",3,0,SPload)
        lea     -8(%rbp),%rbp
        mov     %rax,(%rbp)
        mov     %rbp,%rax
        retq

fdef("SP!",3,0,SPsave)
        lea     8(%rax),%rbp
        mov     -8(%rbp),%rax
        retq

fdef("RP@",3 ,0 ,RPload)
        lea    -8(%rbp), %rbp
        mov     %rax,(%rbp)
        lea    8(%rsp), %rax
        ret

fdef("RP!",3,0,RPsave)
        pop %rbx
        or HSPSAVE,%rax
        mov %rax,%rsp
        mov (%rbp),%rax
        lea 8(%rbp),%rbp
        jmpq *%rbx

fdef("UP@",3,0,UPGet)
    lea    -8(%rbp),%rbp
    mov     %r14,%rax
    ret

fdef("UP!",3,0,UPSet)
    mov %rax,%r14
    jmp DROP

fdef("CDR",3,0,CDR)
 // ( NFA1 -> NFA2 )
        or      %eax,%eax
        jz      cdr1
        mov     -4(%rax),%eax
cdr1:   ret

fdef("NAME>",5,0,NAMEgreat)
        mov     -0xC(%rax),%eax
        retq

fdef("NAME>F",6,0,NAMEgreatF)
        lea     -8(%rax),%rax
        retq

fdef("FILL",4,0,FILL)
        mov     (%rbp),%rcx
        mov     8(%rbp),%rdi
        cld
        mov     %rcx,%rbx
        and     $7,%rbx
        jne     FILL1
        mov     %rax,%rbx
        shl     $8,%rax
        or      %rbx,%rax
        mov     %rax,%rbx
        shl     $16,%rax
        or      %rbx,%rax
        mov     %rax,%rbx
        shl     $32,%rax
        or      %rbx,%rax
        mov     %rcx,%rbx
        sar     $0x3,%rcx
        rep     stos %rax,%es:(%rdi)
        mov     %rbx,%rcx
        and     $0x7,%rcx
FILL1:  rep     stos %al,%es:(%rdi)
        lea     24(%rbp),%rbp
        mov     -8(%rbp),%rax
        retq

fdef("CELLS-FILL",10,0,CELLS_FILL)   // ( addr cells num -- )
        mov     (%rbp),%rcx
        mov     8(%rbp),%rdi
        cld
        rep     stos %rax,%es:(%rdi)
        lea     24(%rbp),%rbp
        mov     -8(%rbp),%rax
        retq

fdef("CELLS-ERASE",11,0,CELLS_ERASE)   // ( addr cells -- )
        mov     %rax,%rcx
        mov     $0,%rax
        mov     (%rbp),%rdi
        cld
        rep     stos %rax,%es:(%rdi)
        lea     16(%rbp),%rbp
        mov     -8(%rbp),%rax
        retq

fdef("CMOVE>",6,0,CMOVEgreat)
        mov     %rax,%rcx
        mov     (%rbp),%rdi
        mov     8(%rbp),%rsi
        std
        add     %rcx,%rdi
        add     %rcx,%rsi
        dec     %rsi
        dec     %rdi
        rep movsb %ds:(%rsi),%es:(%rdi)
        cld
        lea     24(%rbp),%rbp
        mov     -8(%rbp),%rax
        retq

fdef("CMOVE",5,0,CMOVE)
        mov     %rax,%rcx
        mov     (%rbp),%rdi
        mov     8(%rbp),%rsi
        cld
        rep movsb %ds:(%rsi),%es:(%rdi)
        lea     24(%rbp),%rbp
        mov     -8(%rbp),%rax
        retq

fdef("ASCIIZ>",7,0,ASCIIZgreat)
        lea     -8(%rbp),%rbp
        mov     %rax,%rdx
ASCg:   mov     (%rax),%cl
        lea     1(%rax),%rax
        or      %cl,%cl
        jne     ASCg
        lea     -1(%rax),%rax
        sub     %rdx,%rax
        mov     %rdx,(%rbp)
        retq

fdef("EXECUTE",7,0,EXECUTE)
        mov     %rax,%rdx
        mov     (%rbp),%rax
        lea     8(%rbp),%rbp
        jmpq    *%rdx

fdef("_SLITERAL-CODE",14 ,0 ,_SLITERALsubCODE)
        lea    -8*2(%rbp), %rbp
        mov     %rax, 8(%rbp)
        pop     %rbx
        movzbl  (%rbx),%eax
        inc     %rbx
        mov     %rbx,(%rbp)
        add     %rax,%rbx
        inc     %rbx
        jmp     %rbx

HHdot:
        movl    %eax,%edi
        call    HPOINT
        call    DROP
        ret

fdef("NOOP",0x4 ,0 ,NOOP)
        ret


fdef("I",1 ,0 ,I)
        lea -8(%rbp),%rbp
        mov %rax,(%rbp)
        mov 8(%rsp),%rax
        sub 16(%rsp),%rax
        retq

fdef("ADD[ESP],TOS",12 ,0 ,ADDxESPycomTOS)
        add %eax,8(%rsp)
        mov (%rbp),%rax
        lea 8(%rbp),%rbp
        ret

fdef("XDO",3 ,0 ,XDO)
    mov     $0x80000000,%edx
    sub     (%rbp),%edx
    lea     (%rdx,%rax,1),%ebx
    mov     8(%rbp),%rax
    mov     %edx,%edx
    lea     8*2(%rbp),%rbp
    ret


fdef("QBRANCH",7 ,0 , QBRANCH)
        or %eax,%eax
        mov (%rbp),%rax
        lea 8(%rbp),%rbp
        ret

fdef("XLIT",4 ,0 , XLIT)
        lea -8(%rbp),%rbp
    mov     %rax,(%rbp)
    pop     %rdx
    mov     (%rdx),%eax
    cltq
    add     $4,%rdx
    jmpq    *%rdx

fdef("ACCEPT1",7,0 ,ACCEPT1)
        mov    (%rbp),%rsi
        mov    %eax,%edx
        xor    %edi,%edi
        call    read
        lea     8(%rbp),%rbp
        retq

fdef("WRITE-FILE",0xA ,0 ,WRITEsubFILE)
        mov    8(%rbp), %rsi
        mov    (%rbp), %edx
        mov    %eax, %edi
        call    write
        addq    $8*2, %rbp
        ret

fdef("READ-FILE",9,0 ,READsubFILE)
        mov    8(%rbp),%rsi
        mov    (%rbp),%edx
        mov    %eax,%edi
        call    read

        mov    (%rbp),%edx
        mov     %rax,8(%rbp)

        cmp     (%rbp),%eax
        setle   %al
        and     $1,%eax
        dec     %eax

        lea     8(%rbp),%rbp
        retq

fdef("REPOSITION-FILE",15,0 ,REPOSITIONsubFILE)
        mov     8(%rbp),%rsi
//      mov     8(%rbp),%edx
        mov     %eax,%edi

        call    rmlseek

        mov     %eax,8(%rbp)

        cmp     %esi,%eax
        setle   %al
        and     $1,%eax
        dec     %eax

        lea     8*2(%rbp),%rbp
        retq


fdef("ZOPEN-FILE",10,0 ,ZOPENsubFILE)
        mov     (%rbp),%rdi
        mov     %eax,%esi
        callq   LOPEN
        mov     %rax,(%rbp)
        inc     %eax
        sbb     %eax,%eax
        not     %eax
        retq

fdef("CLOSE-FILE",10,0 ,CLOSEsubFILE)
        mov    %eax,%edi
        call    close
        retq

fdef("FILE-POSITION",13,0 ,FILEsubPOSITION)
        mov    %eax,%edi
        lea     -8*2(%rbp),%rbp
        call    mtell
        cmp     $-1,%eax
        je      FILEP
        mov     %eax,8(%rbp)
        movl    $0,(%rbp)
        xor     %eax,%eax
        ret
FILEP:  mov     %eax,8(%rbp)
        mov     %rax,(%rbp)
        ret

fdef("FILE-SIZE",9,0 ,FILEsubSIZE)
        mov    %eax,%edi
        lea     -8*2(%rbp),%rbp
        call    mtell
        cmp     $-1,%eax
        je      FILES
        mov     %eax,8(%rbp)
        movl    $0,(%rbp)
        xor     %eax,%eax
        ret
FILES:  mov     %eax,8(%rbp)
        mov     %rax,(%rbp)
        ret

fdef("HALT",4,0 ,HALT)
        mov     %eax,%edi
        jmp     exit

fdef("ALLOCATE",8,0 ,ALLOCATE)
        mov    %eax,%edi
        call    malloc
        lea     -8(%rbp),%ebp
        mov     %rax,(%rbp)
        cmp     $0,%rax
        je      ALL770
        mov     $0,%eax
        ret
ALL770: mov     $-300,%eax
        ret

fdef("FREE",4,0 ,FREE)
        mov     %rax,%rdi
        call    free
        mov     $0,%eax
        ret

fdef("ZCD",3,0 ,ZCD)
        mov    %eax,%edi
        jmp     chdir@plt


fdef("VECT-CODE",9,0,VECTsubCODE)
 call _VALUEsubCODE
 .int _VECTsubCODE
 call _TOVALUEsubCODE

fdef("'DUP_V",6,0,ticDUP_V )
 call _VALUEsubCODE
 .int DUP
 call _TOVALUEsubCODE

fdef("'DROP_V",7,0,ticDROP_V )
 call _VALUEsubCODE
 .int DROP
 call _TOVALUEsubCODE

fdef("'(ABORT'')",10,0,ticcABORTdticcend)
 call _VALUEsubCODE
 .int cABORTdticcend
 call _TOVALUEsubCODE

fdef("'TYPE",5,0,ticTYPE )
 call _VALUEsubCODE
 .int TYPE
 call _TOVALUEsubCODE

fdef("_QTOUSER-VALUE-CODE",19 ,0 , _QTOUSERsubVALUEsubCODE)
        pop     %rbx
        sub     $4+5,%rbx
        mov     (%rbx),%ebx
        add     %r14,%rbx
        mov     %rax,(%rbx)
        mov     (%rbp),%rax
        lea     8(%rbp),%rbp
        retq

fdef("_QUSER-VALUE-CODE",17 ,0 ,_QUSERsubVALUEsubCODE)
        lea     -8(%rbp),%rbp
        mov     %rax,(%rbp)
        popq    %rax
        mov     (%rax),%eax
        add     %r14,%rax
        mov     (%rax),%rax
        retq

fdef("_QUSER-VECT-CODE",16 ,0 ,_QUSERsubVECTsubCODE)
        popq    %rbx
        mov     (%rbx),%ebx
        add     %r14,%rbx
        mov     (%rbx),%rbx
        jmp     %rbx

fdef("_QCONSTANT-CODE",15 ,0 ,_QCONSTANTsubCODE)
    .short 0xdb88  // mov    %bl,%bl  flag for TO
    lea -8(%rbp),%rbp
    mov %rax,(%rbp)
    pop %rax
    mov (%rax),%rax
    retq

fdef("W-CNT",0x5 ,0 , WsubCNT)
 call _USERsubCODE
 .int 0xD2C
fdef(">OUT",0x4 ,0 , greatOUT)
 call _USERsubCODE
 .int T_greatOUT-main_task
fdef("CONTEXT",0x7 ,0 , CONTEXT)
 call _USERsubVALUEsubCODE
 .int T_CONTEXT-main_task
 call _TOUSERsubVALUEsubCODE

fdef("S-O",0x3 ,0 ,SsubO)
 call _USERsubCODE
 .int T_SsubO-main_task
fdef("CURRENT",0x7 ,0 ,CURRENT)
 call _USERsubCODE
 .int T_CURRENT-main_task

fdef("BASE",0x4 ,0 ,BASE)
 call _USERsubCODE
 .int T_BASE-main_task
fdef("CURSTR",0x6 ,0 , CURSTR)
 call _USERsubCODE
 .int T_CURSTR-main_task
fdef("SOURCE-ID",0x9 ,0 ,SOURCEsubID)
 call _USERsubVALUEsubCODE
 .int T_SOURCEsubID-main_task
 call _TOUSERsubVALUEsubCODE

fdef("PAD",0x3 ,0 ,PAD)
 call _USERsubCODE
 .int T_PAD-main_task
fdef("ATIB",0x4 ,0 ,ATIB)
 call _USERsubCODE
 .int T_ATIB-main_task

fdef("TIB",0x3 ,0 ,TIB)
 call _QUSERsubVALUEsubCODE
 .int T_TIB-main_task
 call _QTOUSERsubVALUEsubCODE
fdef(">IN",0x3 ,0 ,greatIN)
 call _USERsubCODE
 .int T_greatIN-main_task
fdef("#TIB",0x4 ,0 ,nTIB)
 call _USERsubCODE
 .int T_nTIB-main_task
fdef("DOES>A",0x6 ,0 ,DOESgreatA)
 call _USERsubCODE
 .int T_DOESgreatA-main_task
fdef("ER-U",0x4 ,0 ,ERsubU)
 call _USERsubCODE
 .int T_ERsubU-main_task
fdef("ER-A",0x4 ,0 ,ERsubA)
 call _USERsubCODE
 .int T_ERsubA-main_task
fdef("HANDLER",0x7 ,0 ,HANDLER)
 call _USERsubCODE
 .int T_HANDLER-main_task
fdef("CURFILE",0x7 ,0 ,CURFILE)
 call _USERsubCODE
 .int T_CURFILE-main_task
fdef("BLK",0x3 ,0 ,BLK)
 call _USERsubCODE
 .int T_BLK-main_task
fdef("STATE",0x5 ,0 ,STATE)
 call _USERsubCODE
 .int T_STATE-main_task
fdef("WARNING",0x7 ,0 ,WARNING)
 call _USERsubCODE
 .int T_WARNING-main_task
fdef("R0",0x2 ,0 ,R_0)
 call _USERsubCODE
 .int T_R0-main_task
fdef("S0",0x2 ,0 ,S0)
 call _USERsubCODE
 .int T_S0-main_task

fdef("TOVALUE-CODE",0xC, 0, TOVALUEsubCODE)
 call _VALUEsubCODE
 .int _TOVALUEsubCODE
 call _TOVALUEsubCODE
 fdef("VALUE-CODE",10, 0, VALUEsubCODE)
 call _VALUEsubCODE
 .int _VALUEsubCODE
 call _TOVALUEsubCODE

fdef("QTOVALUE-CODE",0xD, 0, QTOVALUEsubCODE)
 call _VALUEsubCODE
 .int _QTOVALUEsubCODE
 call _TOVALUEsubCODE
 fdef("QVALUE-CODE",11, 0, QVALUEsubCODE)
 call _VALUEsubCODE
 .int _QVALUEsubCODE
 call _TOVALUEsubCODE

fdef("CONSTANT-CODE",0xD ,0 ,CONSTANTsubCODE)
 call _VALUEsubCODE
 .int _CONSTANTsubCODE
 call _TOVALUEsubCODE
fdef("USER-CODE",9 ,0 ,USERsubCODE)
 call _VALUEsubCODE
 .int _USERsubCODE
 call _TOVALUEsubCODE
fdef("CREATE-CODE",0xB ,0 ,CREATEsubCODE)
 call _VALUEsubCODE
 .int _CREATEsubCODE
 call _TOVALUEsubCODE
fdef("CLITERAL-CODE",0xD ,0 ,CLITERALsubCODE)
 call _VALUEsubCODE
 .int _CLITERALsubCODE
 call _TOVALUEsubCODE
fdef("_CLITERAL-CODE",0xE ,0 ,_CLITERALsubCODE)
   lea  -8(%rbp),%rbp
   mov %rax,(%rbp)
   pop %rax
   movzbl (%rax),%ebx
   lea 0x2(%rbx,%rax,1),%ebx
   jmpq *%rbx
fdef("SLITERAL-CODE",0xD ,0 , SLITERALsubCODE)
 call _VALUEsubCODE
 .int _SLITERALsubCODE
 call _TOVALUEsubCODE
fdef("_TOUSER-VALUE-CODE",0x12 ,0 ,_TOUSERsubVALUEsubCODE)
        pop     %rbx
        sub     $9,%ebx
        mov     (%rbx),%ebx
        add     %r14d,%ebx
        mov     %eax,(%rbx)
        mov     (%rbp),%rax
        lea     8(%rbp),%rbp
        retq
fdef("_TOVALUE-CODE",0xD ,0 ,_TOVALUEsubCODE)
        pop     %rbx
        lea     -9(%rbx),%ebx
        mov     %eax,(%rbx)
        mov     (%rbp),%rax
        lea     8(%rbp),%rbp
        retq

fdef("_QTOVALUE-CODE",0xE ,0 ,_QTOVALUEsubCODE)
        pop     %rbx
        lea     (%rbx),%rbx
        mov     %rax,(%rbx)
        mov     (%rbp),%rax
        lea     8(%rbp),%rbp
        retq

fdef("_VECT-CODE",0xA ,0 ,_VECTsubCODE)
        pop     %rbx
        mov     (%ebx),%ebx
        jmp     %rbx

fdef("_USER-VALUE-CODE",0x10 ,0 ,_USERsubVALUEsubCODE)
       lea  -8(%rbp),%rbp
        mov %rax,(%rbp)
        pop %rax
        mov (%rax),%eax
        add %r14,%rax
        mov (%rax),%eax
        retq
fdef("USER+",0x5 ,0 ,USERadd)
 .byte 0x3 ,0xC7
 .byte 0xC3
fdef("_USER-CODE",0xA ,0 ,_USERsubCODE)
       lea  -8(%rbp),%rbp
        mov %rax,(%rbp)
        mov %rax,(%rbp)
        mov %rax,(%rbp)
        pop %rax
        mov (%rax),%eax
        add %r14,%rax
        retq
 fdef("_CONSTANT-CODE",0xE ,0 ,_CONSTANTsubCODE)
   lea  -8(%rbp),%rbp
    mov %rax,(%rbp)
    pop %rax
    mov (%rax),%eax
    cltq
    retq

fdef("_VALUE-CODE",0xB ,0 ,_VALUEsubCODE)
   lea  -8(%rbp),%rbp
    mov %rax,(%rbp)
    pop %rax
    mov (%rax),%eax
    cltq
    retq

fdef("_QVALUE-CODE",0xC ,0 ,_QVALUEsubCODE)
   lea  -8(%rbp),%rbp
    mov %rax,(%rbp)
    pop %rax
    mov 4+5(%rax),%rax
    retq

fdef("_CREATE-CODE",0xC ,0 ,_CREATEsubCODE)
   lea  -8(%rbp),%rbp
    mov %rax,(%rbp)
    pop %rax
    retq

fdef("VOC-LIST",0x8 ,0 ,VOCsubLIST)
 call _CREATEsubCODE
 .quad T_FORTH

fdef("BYE",0x3 ,0 ,BYE)
    call MBYE

fdef("FORTH-WORDLIST",14 ,0 ,FORTHsubWORDLIST)
 call _VALUEsubCODE
 .int T_FORTH+4
 call _TOVALUEsubCODE

fdef("LAST",4 ,0 , LAST)
 call _CREATEsubCODE
 .quad LastNFA

fdef("USER-OFFS",9 ,0 ,USERsubOFFS)
 call _CREATEsubCODE
 .quad reserve+MUSEROFFS

fdef("UPPER_V",0x7 ,0 ,UPPER_V)
 call _CREATEsubCODE
 .quad NOOP

fdef("TCYDP0",6 ,0 ,TCYDP0)
 call _VALUEsubCODE
 .int T_YDP0
 call _TOVALUEsubCODE

// ================================================================================================
// Функции из сишных либ будем подключать тут.
// ------------------------------------------------------------------------------------------------
// Сокеты
// c_sock_open (int port,char * iaddr)
// c_sock_lconnect (int port)
// c_getmyip
// c_create_server (int port)
// c_sock_accept
// c_sock_listen

// передача двух параметров сишной функции:
  // mov    0(%rbp),%esi
  // mov    %eax,%edi
  // mov    $0x0,%eax
  // call   s_open
  // lea    8(%rbp), %rbp
  // ret

fdef("SOCK-OPEN",5,0,SOCK_OPEN)
  mov     0(%rbp),%esi
  mov     %eax,%edi
  mov     $0x0,%eax
  call  c_sock_open
  lea     8(%rbp), %rbp
  ret

fdef("GET-LOCALIP",11 ,0 ,GET_LOCALIP)
  call  DUP
  jmp   c_getmyip

fdef("CREATE-SERVER",13 ,0 ,CREATE_SERVER)
  mov   %eax,%edi
  jmp   c_create_server

fdef("SOCK-ACCEPT",11 ,0 ,SOCK_ACCEPT)
  mov   %eax,%edi
  jmp   c_sock_accept

fdef("SOCK-LISTEN",11 ,0 ,SOCK_LISTEN)
  mov   %eax,%edi
  jmp   c_sock_listen
// ------------------------------------------------------------------------------------------------
// Потоки (процессы)
fdef("GET-PID",7 ,0 ,GET_PID)
  call  DUP
  jmp   c_getpid

fdef("GET-PPID",8 ,0 ,GET_PPID)
  call  DUP
  jmp   c_getppid

fdef("FORK",4 ,0 ,FORK)
  call  DUP
  jmp   fork

// fdef("ALLOCATE1",9 ,0 ,_DP)
  // mov   %eax,%edi
  // jmp   malloc

// fdef("CLONE",5 ,0 ,CLONE)
  // mov   %eax,%edi
  // jmp   c_clone

// fdef("EXECVE",6 ,0 ,EXECVE)
  // call  DUP
  // mov   %eax,%edi
  // jmp   c_execve

// ================================================================================================
// Дополнительные ассемблерные команды

// Несколкьо слов для тестирования x64
fdef("qv",2 ,0 ,qv)
        lea     -8(%rbp),%rbp
        mov     $0x0102030405060708,%rax
        retq

fdef("vq",2 ,0 ,vq)
        lea     -8(%rbp),%rbp
        mov     $0x0807060504030201,%rax
        retq

// ================================================================================================

fdef("IMAGE-BEGIN",11 ,0 ,IMAGEBEGIN)
 call _VALUEsubCODE
 .int main
 call _TOVALUEsubCODE

//mdef("DP",0x2 ,0 ,0+1,DP)
//mdef("DP",0x2 ,0 ,RPload-3,DP)
fdef("DP",0x2 ,0 ,DP)
 call _CREATEsubCODE
 .quad DP_BUFF

fdef("NNN",3 ,0 , NNN)
 call _USERsubCODE
 .int T_NNN-main_task

// =================================< пїЅпїЅпїЅпїЅпїЅ FORTH пїЅпїЅиЁ­пїЅ
main_task:
T_R0:       .quad 0
T_S0:       .quad _Stekc+STACK_SIZE-0x28
T_WARNING:  .quad -1
T_STATE:    .quad 0
T_BLK:      .quad 0
T_CURFILE:  .quad 0
T_HANDLER:  .quad 0
T_HLD:      .quad 0
T_BASE:     .quad 0xA
        .space PAD_SIZE,0
T_PAD:      .space PAD_SIZE,0
T_ERsubA:   .quad 0
T_ERsubU:   .quad 0
T_DOESgreatA:   .quad 0
//T_ALIGNsubBYTES:.quad 0
T_nTIB:     .quad 0
T_greatIN:  .quad 0
T_TIB:      .quad T_ATIB,0
T_ATIB:     .space TIB_SIZE,0
T_SOURCEsubID:  .quad 0
T_CURSTR:   .quad 0
T_CURRENT:  .quad T_FORTH+4
T_SsubO:    .int T_FORTH+4,T_FORTH+4,0,0,0,0,0,0,0,0,0,0,0,0
T_CONTEXT:  .quad T_SsubO+4
T_greatOUT: .quad 0
T_WsubCNT:  .quad 0
T_NNN:      .quad 0
Mreserve:   .space 1000,0   // аҐ§пїЅпїЅ

T_FORTH:    .int 0          // пїЅпїЅпїЅ VOC-LIST
        .int LastNFA        // пїЅпїЅпїЅпїЅ пїЅпїЅб«ҐпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ
                .int 0          // пїЅаҐ¤пїЅпїЅ
                .int 0          // пїЅпїЅпїЅпїЅпїЅ

#include "./img.s"
.comm BYELEVEL,8
.comm HSPSAVE,8
.comm T_YDP0,0x4000
.comm DP_BUFF,VOCABULARY_POOL
.comm _Stekc,STACK_SIZE
