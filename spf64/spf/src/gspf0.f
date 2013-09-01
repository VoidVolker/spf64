HERE TO TSAVE_LIMIT
USER-HERE-SET TO RESERVE
USER-HERE-SET USER-OFFS !
\ TRUE WARNING ! \ ����� ����
\ ==============================================================
\ ������ ������ ����-�������
S" _mak/CompIF1.f"              INCLUDED

CR .( S" src/spf_forthproc.f"              INCLUDED)

\ S" src/spf_forthproc.f"              INCLUDED


S" src/spf_forthproc_hl.f"           INCLUDED

S" src/spf_floatkern.f"              INCLUDED

S" src/linux/spf_linux_const.f"          INCLUDED 

S" src/compiler/spf_immed_lit.f"     INCLUDED
S" src/compiler/spf_defwords.f"      INCLUDED
S" src/compiler/spf_immed_loop.f"    INCLUDED
S" src/compiler/spf_error.f"         INCLUDED

S" src/compiler/spf_translate.f"     INCLUDED

S" src/compiler/spf_immed_transl.f"  INCLUDED
S" src/compiler/spf_literal.f"       INCLUDED

S" src/compiler/spf_wordlist.f"      INCLUDED
S" src/compiler/spf_find.f"          INCLUDED
S" src/compiler/spf_words.f"         INCLUDED
S" src/compiler/spf_compile0.f"       INCLUDED

S" src/spf_except.f"                 INCLUDED

S" src/spf_print.f"                  INCLUDED

S" src/linux/spf_linux_con_io.f"         INCLUDED
S" src/spf_con_io.f"                 INCLUDED
S" src/linux/spf_linux_io.f"             INCLUDED
\ S" src/linux/spf_linux_memory.f"         INCLUDED
S" src/compiler/spf_compile.f"       INCLUDED
S" src/compiler/spf_immed_control.f" INCLUDED
: ZZZZRR IF THEN ;

\ ==============================================================
\ ������ ��������� ������ ����-��������
S" src/compiler/spf_parser.f"        INCLUDED
S" src/compiler/spf_read_source.f"   INCLUDED
S" src/spf_init.f"              INCLUDED
S" src/compiler/spf_modules.f"       INCLUDED

S" src/spf_last.f"              INCLUDED

CR .( =============================================================)
CR .( Done.
CR .( =============================================================)
\ MM_SIZE H.
