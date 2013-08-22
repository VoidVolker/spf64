( Процедуры времени выполнения для CONSTANT, VARIABLE, etc.
  ОС-независимые слова.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)

CODE _CREATE-CODE
     LEA  EBP, -4 [EBP]
     MOV  [EBP], EAX
     POP EAX
     RET
END-CODE

CODE _CONSTANT-CODE
     LEA  EBP, -4 [EBP]
     MOV  [EBP], EAX
     POP EAX
     MOV  EAX, [EAX]
     RET
END-CODE

CODE _USER-CODE
     LEA  EBP, -4 [EBP]
     MOV  [EBP], EAX
     POP EAX
     MOV EAX, [EAX]
     LEA EAX, [EDI] [EAX]
     RET
END-CODE

CODE USER+ ( offs -- addr )
     LEA EAX, [EDI] [EAX]
     RET
END-CODE

CODE _USER-VALUE-CODE
     LEA  EBP, -4 [EBP]
     MOV  [EBP], EAX
     POP EAX
     MOV EAX, [EAX]
     LEA EAX, [EDI] [EAX]
     MOV EAX, [EAX]
     RET
END-CODE

CODE _USER-VECT-CODE
     POP  EBX
     MOV  EBX, [EBX]
     LEA  EBX, [EDI] [EBX]
     MOV  EBX, [EBX]
     JMP  EBX
     RET
END-CODE

CODE _VECT-CODE
     POP EBX
     JMP [EBX]
END-CODE

CODE _TOVALUE-CODE
     POP EBX
     LEA EBX, -9 [EBX]
     MOV [EBX], EAX
     MOV EAX, [EBP]
     LEA EBP, 4 [EBP]
     RET             
END-CODE

CODE _TOUSER-VALUE-CODE
     POP EBX
     LEA EBX, -9 [EBX]
     MOV EBX, [EBX]
     LEA EBX, [EDI] [EBX]
     MOV [EBX], EAX
     MOV EAX, [EBP]
     LEA EBP, 4 [EBP]
     RET             
END-CODE

CODE _SLITERAL-CODE
      LEA   EBP, -8 [EBP]
      MOV   4 [EBP], EAX
      POP   EBX
      MOVZX EAX, BYTE [EBX]
      LEA   EBX, 1 [EBX]
      MOV   [EBP], EBX
      LEA   EBX, [EBX] [EAX]
      LEA   EBX, 1 [EBX]
      JMP   EBX
END-CODE

CODE _CLITERAL-CODE
     LEA   EBP, -4 [EBP]
     MOV   [EBP], EAX
     POP   EAX
     MOVZX EBX, BYTE [EAX]
     LEA   EBX, [EBX] [EAX]
     LEA   EBX, 2 [EBX]
     JMP   EBX
     RET
END-CODE

' _CLITERAL-CODE VALUE CLITERAL-CODE
'   _CREATE-CODE VALUE   CREATE-CODE
'     _USER-CODE VALUE     USER-CODE
' _CONSTANT-CODE VALUE CONSTANT-CODE
'  _TOVALUE-CODE VALUE  TOVALUE-CODE

