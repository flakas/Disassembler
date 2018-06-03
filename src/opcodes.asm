;Registers
s_AL db "AL", 0
s_AH db "AH", 0
s_BL db "BL", 0
s_BH db "BH", 0
s_CL db "CL", 0
s_CH db "CH", 0
s_DL db "DL", 0
s_DH db "DH", 0
s_SI db "SI", 0
s_DI db "DI", 0
s_AX db "AX", 0
s_BX db "BX", 0
s_CX db "CX", 0
s_DX db "DX", 0
s_SP db "SP", 0
s_BP db "BP", 0
s_ES db "ES", 0
s_CS db "CS", 0
s_DS db "DS", 0
s_SS db "SS", 0

;EA
s_000 db "BX+SI", 0
s_001 db "BX+DI", 0
s_010 db "BP+DI", 0
s_011 db "BP+SI", 0

;Instruction mnemonics
m_MOV db "MOV", 0
m_PUSH db "PUSH", 0
m_POP db "POP", 0
m_ADD db "ADD", 0
m_INC db "INC", 0
m_SUB db "SUB", 0
m_DEC db "DEC", 0
m_CMP db "CMP", 0
m_MUL db "MUL", 0
m_DIV db "DIV", 0
m_CALL db "CALL", 0
m_RET db "RET", 0
m_AND db "AND", 0
m_OR db "OR", 0
m_JMP db "JMP", 0
; Conditional jumps
m_JO db "JO", 0
m_JNO db "JNO", 0
m_JNAE db "JNAE", 0
m_JAE db "JAE", 0
m_JE db "JE", 0
m_JNE db "JNE", 0
m_JBE db "JBE", 0
m_JA db "JA", 0
m_JS db "JS", 0
m_JNS db "JNS", 0
m_JP db "JP", 0
m_JNP db "JNP", 0
m_JL db "JL", 0
m_JGE db "JGE", 0
m_JLE db "JLE", 0
m_JG db "JG", 0
; Conditional jumps end
m_LOOP db "LOOP", 0
m_INT db "INT", 0

RegTableSize EQU 8h
label RegR_MTable regTable
    regTable <s_AL, s_AX, s_000, s_000> ;000
    regTable <s_CL, s_CX, s_001, s_001> ;001
    regTable <s_DL, s_DX, s_010, s_010> ;010
    regTable <s_BL, s_BX, s_011, s_011> ;011
    regTable <s_AH, s_SP, s_SI, s_SI>   ;100
    regTable <s_CH, s_BP, s_DI, s_DI>   ;101
    regTable <s_DH, s_SI, 0, s_BP>      ;110
    regTable <s_BH, s_DI, s_BX, s_BX>   ;111


;Optypes
NoOp equ 00h
OpMem equ 01h
OpAL equ 02h
OpCL equ 03h
OpDL equ 04h
OpBL equ 05h
OpAH equ 06h
OpCH equ 07h
OpDH equ 08h
OpBH equ 09h
OpAX equ 0Ah
OpCX equ 0Bh
OpDX equ 0Ch
OpBX equ 0Dh
OpSP equ 0Eh
OpBP equ 0Fh
OpSI equ 10h
OpDI equ 11h
OpES equ 12h
OpCS equ 13h
OpSS equ 14h
OpDS equ 15h

OpBet8b equ 16h
OpBet16b equ 17h

OpReg8b equ 18h
OpReg16b equ 19h
OpR_m8b equ 1Ah
OpR_m16b equ 1Bh

OpTableSize EQU 102h
;Opcode table
label Opcodes OPKRow
    OPKRow <00h, m_ADD, 0FFh, OpR_m8b, OpReg8b, 0> ;00h
    OPKRow <01h, m_ADD, 0FFh, OpR_m16b, OpReg16b, 1> ;01h
    OPKRow <02h, m_ADD, 0FFh, OpReg8b, OpR_m8b, 0> ;02h
    OPKRow <03h, m_ADD, 0FFh, OpReg16b, OpR_m16b, 1> ;03h

    OPKRow <04h, m_ADD, 0FFh, OpAL, OpBet8b, 0> ;04h
    OPKRow <05h, m_ADD, 0FFh, OpAX, OpBet16b, 0> ;05h


    OPKRow <06h, m_PUSH, 0FFh, OpES, NoOp, 0> ;06h
    OPKRow <0Eh, m_PUSH, 0FFh, OpCS, NoOp, 0> ;07h
    OPKRow <16h, m_PUSH, 0FFh, OpSS, NoOp, 0> ;08h
    OPKRow <1Eh, m_PUSH, 0FFh, OpDS, NoOp, 0> ;09h


    OPKRow <07h, m_POP, 0FFh, OpES, NoOp, 0> ;0Ah
    OPKRow <0Fh, m_POP, 0FFh, OpCS, NoOp, 0> ;0Bh
    OPKRow <17h, m_POP, 0FFh, OpSS, NoOp, 0> ;0Ch
    OPKRow <1Fh, m_POP, 0FFh, OpDS, NoOp, 0> ;0Dh

    OPKRow <08h, m_OR, 0FFh, OpR_m8b, OpReg8b, 0> ;0Eh
    OPKRow <09h, m_OR, 0FFh, OpR_m16b, OpReg16b, 1> ;0Fh
    OPKRow <0Ah, m_OR, 0FFh, OpReg8b, OpR_m8b, 0> ;10h
    OPKRow <0Bh, m_OR, 0FFh, OpReg16b, OpR_m16b, 1> ;11h

    OPKRow <0Ch, m_OR, 0FFh, OpAL, OpBet8b, 0> ;12h
    OPKRow <0Dh, m_OR, 0FFh, OpAX, OpBet16b, 1> ;13h

    OPKRow <20h, m_AND, 0FFh, OpR_m8b, OpReg8b, 0> ;14h
    OPKRow <21h, m_AND, 0FFh, OpR_m16b, OpReg16b, 1> ;15h
    OPKRow <22h, m_AND, 0FFh, OpReg8b, OpR_m8b, 0> ;16h
    OPKRow <23h, m_AND, 0FFh, OpReg16b, OpR_m16b, 1> ;17h

    OPKRow <24h, m_AND, 0FFh, OpAL, OpBet8b, 0> ;18h
    OPKRow <25h, m_AND, 0FFh, OpAX, OpBet16b, 1> ;19h

    OPKRow <28h, m_SUB, 0FFh, OpR_m8b, OpReg8b, 0> ;1Ah
    OPKRow <29h, m_SUB, 0FFh, OpR_m16b, OpReg16b, 1> ;1Bh
    OPKRow <2Ah, m_SUB, 0FFh, OpReg8b, OpR_m8b, 0> ;1Ch
    OPKRow <2Bh, m_SUB, 0FFh, OpReg16b, OpR_m16b, 1> ;1Dh

    OPKRow <2Ch, m_SUB, 0FFh, OpAL, OpBet8b, 0> ;1Eh
    OPKRow <2Dh, m_SUB, 0FFh, OpAX, OpBet16b, 1> ;1Fh

    OPKRow <38h, m_CMP, 0FFh, OpR_m8b, OpReg8b, 0> ;20h
    OPKRow <39h, m_CMP, 0FFh, OpR_m16b, OpReg16b, 1> ;21h
    OPKRow <3Ah, m_CMP, 0FFh, OpReg8b, OpR_m8b, 0> ;22h
    OPKRow <3Bh, m_CMP, 0FFh, OpReg16b, OpR_m16b, 1> ;23h

    OPKRow <3Ch, m_CMP, 0FFh, OpAL, OpBet8b, 0> ;24h
    OPKRow <3Dh, m_CMP, 0FFh, OpAX, OpBet16b, 1> ;25h

    OPKRow <40h, m_INC, 0FFh, OpAX, NoOp, 1> ;26h
    OPKRow <41h, m_INC, 0FFh, OpCX, NoOp, 1> ;27h
    OPKRow <42h, m_INC, 0FFh, OpDX, NoOp, 1> ;28h
    OPKRow <43h, m_INC, 0FFh, OpBX, NoOp, 1> ;29h
    OPKRow <44h, m_INC, 0FFh, OpSP, NoOp, 1> ;2Ah
    OPKRow <45h, m_INC, 0FFh, OpBP, NoOp, 1> ;2Bh
    OPKRow <46h, m_INC, 0FFh, OpSI, NoOp, 1> ;2Ch
    OPKRow <47h, m_INC, 0FFh, OpDI, NoOp, 1> ;2Dh

    OPKRow <48h, m_DEC, 0FFh, OpAX, NoOp, 1> ;2Eh
    OPKRow <49h, m_DEC, 0FFh, OpCX, NoOp, 1> ;2Fh
    OPKRow <4Ah, m_DEC, 0FFh, OpDX, NoOp, 1> ;30h
    OPKRow <4Bh, m_DEC, 0FFh, OpBX, NoOp, 1> ;31h
    OPKRow <4Ch, m_DEC, 0FFh, OpSP, NoOp, 1> ;32h
    OPKRow <4Dh, m_DEC, 0FFh, OpBP, NoOp, 1> ;33h
    OPKRow <4Eh, m_DEC, 0FFh, OpSI, NoOp, 1> ;34h
    OPKRow <4Fh, m_DEC, 0FFh, OpDI, NoOp, 1> ;35h

    OPKRow <50h, m_PUSH, 0FFh, OpAX, NoOp, 1> ;36h
    OPKRow <51h, m_PUSH, 0FFh, OpCX, NoOp, 1> ;37h
    OPKRow <52h, m_PUSH, 0FFh, OpDX, NoOp, 1> ;38h
    OPKRow <53h, m_PUSH, 0FFh, OpBX, NoOp, 1> ;39h
    OPKRow <54h, m_PUSH, 0FFh, OpSP, NoOp, 1> ;3Ah
    OPKRow <55h, m_PUSH, 0FFh, OpBP, NoOp, 1> ;3Bh
    OPKRow <56h, m_PUSH, 0FFh, OpSI, NoOp, 1> ;3Ch
    OPKRow <57h, m_PUSH, 0FFh, OpDI, NoOp, 1> ;3Dh

    OPKRow <58h, m_POP, 0FFh, OpAX, NoOp, 1> ;3Eh
    OPKRow <59h, m_POP, 0FFh, OpCX, NoOp, 1> ;3Fh
    OPKRow <5Ah, m_POP, 0FFh, OpDX, NoOp, 1> ;40h
    OPKRow <5Bh, m_POP, 0FFh, OpBX, NoOp, 1> ;41h
    OPKRow <5Ch, m_POP, 0FFh, OpSP, NoOp, 1> ;42h
    OPKRow <5Dh, m_POP, 0FFh, OpBP, NoOp, 1> ;43h
    OPKRow <5Eh, m_POP, 0FFh, OpSI, NoOp, 1> ;44h
    OPKRow <5Fh, m_POP, 0FFh, OpDI, NoOp, 1> ;45h

    OPKRow <70h, m_JO, 0FFh, OpBet8b, NoOp, 0> ;46h
    OPKRow <71h, m_JNO, 0FFh, OpBet8b, NoOp, 0> ;47h
    OPKRow <72h, m_JNAE, 0FFh, OpBet8b, NoOp, 0> ;48h
    OPKRow <73h, m_JAE, 0FFh, OpBet8b, NoOp, 0> ;49h
    OPKRow <74h, m_JE, 0FFh, OpBet8b, NoOp, 0> ;4Ah
    OPKRow <75h, m_JNE, 0FFh, OpBet8b, NoOp, 0> ;4Bh
    OPKRow <76h, m_JBE, 0FFh, OpBet8b, NoOp, 0> ;4Ch
    OPKRow <77h, m_JA, 0FFh, OpBet8b, NoOp, 0> ;4Dh
    OPKRow <78h, m_JS, 0FFh, OpBet8b, NoOp, 0> ;4Eh
    OPKRow <79h, m_JNS, 0FFh, OpBet8b, NoOp, 0> ;4Fh
    OPKRow <7Ah, m_JP, 0FFh, OpBet8b, NoOp, 0> ;50h
    OPKRow <7Bh, m_JNP, 0FFh, OpBet8b, NoOp, 0> ;51h
    OPKRow <7Ch, m_JL, 0FFh, OpBet8b, NoOp, 0> ;52h
    OPKRow <7Dh, m_JGE, 0FFh, OpBet8b, NoOp, 0> ;53h
    OPKRow <7Eh, m_JLE, 0FFh, OpBet8b, NoOp, 0> ;54h
    OPKRow <7Fh, m_JG, 0FFh, OpBet8b, NoOp, 0> ;55h

    OPKRow <80h, m_ADD, 0h, OpR_m8b, OpBet8b, 0> ;56h
    OPKRow <81h, m_ADD, 0h, OpR_m16b, OpBet16b, 1> ;57h
    OPKRow <82h, m_ADD, 0h, OpR_m8b, OpBet8b, 0> ;TODO: byte ptr 58h
    OPKRow <83h, m_ADD, 0h, OpR_m16b, OpBet8b, 1> ;TODO: word ptr 59h

    OPKRow <80h, m_OR, 1h, OpR_m8b, OpBet8b, 0> ;5Ah
    OPKRow <81h, m_OR, 1h, OpR_m16b, OpBet16b, 1> ;5Bh
    OPKRow <82h, m_OR, 1h, OpR_m8b, OpBet8b, 0> ;TODO: byte ptr 5Ch
    OPKRow <83h, m_OR, 1h, OpR_m16b, OpBet8b, 1> ;TODO: word ptr 5Dh

    OPKRow <80h, m_AND, 4h, OpR_m8b, OpBet8b, 0>; 5Eh
    OPKRow <81h, m_AND, 4h, OpR_m16b, OpBet16b, 1> ;5Fh
    OPKRow <82h, m_AND, 4h, OpR_m8b, OpBet8b, 0> ;TODO: byte ptr 60h
    OPKRow <83h, m_AND, 4h, OpR_m16b, OpBet8b, 1> ;TODO: word ptr 61h

    OPKRow <80h, m_SUB, 5h, OpR_m8b, OpBet8b, 0> ;62h
    OPKRow <81h, m_SUB, 5h, OpR_m16b, OpBet16b, 1> ;63h
    OPKRow <82h, m_SUB, 5h, OpR_m8b, OpBet8b, 0> ;TODO: byte ptr 64h
    OPKRow <83h, m_SUB, 5h, OpR_m16b, OpBet8b, 1> ;TODO: word ptr 65h

    OPKRow <80h, m_CMP, 7h, OpR_m8b, OpBet8b, 0> ;66h
    OPKRow <81h, m_CMP, 7h, OpR_m16b, OpBet16b, 1> ;67h
    OPKRow <82h, m_CMP, 7h, OpR_m8b, OpBet8b, 0> ;TODO: byte ptr 68h
    OPKRow <83h, m_CMP, 7h, OpR_m16b, OpBet8b, 1> ;TODO: word ptr 69h

    OPKRow <88h, m_MOV, 0FFh, OpR_m8b, OpReg8b, 0> ;6Ah
    OPKRow <89h, m_MOV, 0FFh, OpR_m16b, OpReg16b, 1> ;6Bh
    OPKRow <8Ah, m_MOV, 0FFh, OpReg8b, OpR_m8b, 0> ;6Ch
    OPKRow <8Bh, m_MOV, 0FFh, OpReg16b, OpR_m16b, 1> ;6Dh

    OPKRow <8Ch, m_MOV, 0h, OpR_m16b, OpES, 1> ;6Eh
    OPKRow <8Ch, m_MOV, 1h, OpR_m16b, OpCS, 1> ;6Fh
    OPKRow <8Ch, m_MOV, 2h, OpR_m16b, OpSS, 1> ;70h
    OPKRow <8Ch, m_MOV, 3h, OpR_m16b, OpDS, 1> ;71h
    OPKRow <8Eh, m_MOV, 0h, OpES, OpR_m16b, 1> ;72h
    OPKRow <8Eh, m_MOV, 1h, OpCS, OpR_m16b, 1> ;73h
    OPKRow <8Eh, m_MOV, 2h, OpSS, OpR_m16b, 1> ;74h
    OPKRow <8Eh, m_MOV, 3h, OpDS, OpR_m16b, 1> ;75h

    OPKRow <8Fh, m_POP, 6h, OpR_m16b, NoOp, 1> ;76h

    OPKRow <9Ah, m_CALL, 0FFh, OpBet16b, OpBet16b, 1> ;77h

    OPKRow <0A0h, m_MOV, 0FFh, OpAL, OpBet8b, 0> ;78h
    OPKRow <0A1h, m_MOV, 0FFh, OpAX, OpBet16b, 1> ;79h

    OPKRow <0A2h, m_MOV, 0FFh, OpMem, OpAL, 0> ;7Ah
    OPKRow <0A3h, m_MOV, 0FFh, OpMem, OpAX, 1> ;7Bh

    OPKRow <0B0h, m_MOV, 0FFh, OpAL, OpBet8b, 0> ;7Ch
    OPKRow <0B1h, m_MOV, 0FFh, OpCL, OpBet8b, 0> ;7Dh
    OPKRow <0B2h, m_MOV, 0FFh, OpDL, OpBet8b, 0> ;7Eh
    OPKRow <0B3h, m_MOV, 0FFh, OpBL, OpBet8b, 0> ;7Fh
    OPKRow <0B4h, m_MOV, 0FFh, OpAH, OpBet8b, 0> ;80h
    OPKRow <0B5h, m_MOV, 0FFh, OpCH, OpBet8b, 0> ;81h
    OPKRow <0B6h, m_MOV, 0FFh, OpDH, OpBet8b, 0> ;82h
    OPKRow <0B7h, m_MOV, 0FFh, OpBH, OpBet8b, 0> ;83h

    OPKRow <0B8h, m_MOV, 0FFh, OpAX, OpBet16b, 1> ;84h
    OPKRow <0B9h, m_MOV, 0FFh, OpCX, OpBet16b, 1> ;85h
    OPKRow <0BAh, m_MOV, 0FFh, OpDX, OpBet16b, 1> ;86h
    OPKRow <0BBh, m_MOV, 0FFh, OpBX, OpBet16b, 1> ;87h
    OPKRow <0BCh, m_MOV, 0FFh, OpSP, OpBet16b, 1> ;88h
    OPKRow <0BDh, m_MOV, 0FFh, OpBP, OpBet16b, 1> ;89h
    OPKRow <0BEh, m_MOV, 0FFh, OpSI, OpBet16b, 1> ;8Ah
    OPKRow <0BFh, m_MOV, 0FFh, OpDI, OpBet16b, 1> ;8Bh

    OPKRow <0C2h, m_RET, 0FFh, OpBet16b, NoOp, 0> ;8Ch

    OPKRow <0C3h, m_RET, 0FFh, NoOp, NoOp, 0> ;8Dh

    OPKRow <0C6h, m_MOV, 0FFh, OpR_m8b, OpBet8b, 0> ;8Eh
    OPKRow <0C7h, m_MOV, 0FFh, OpR_m16b, OpBet16b, 1> ;8Fh

    OPKRow <0CDh, m_INT, 0FFh, OpBet8b, NoOp, 0> ;90h

    OPKRow <0E2h, m_LOOP, 0FFh, OpBet8b, NoOp, 0> ;91h

    OPKRow <0E8h, m_CALL, 0FFh, OpBet16b, NoOp, 1> ;92h

    OPKRow <0E9h, m_JMP, 0FFh, OpBet16b, NoOp, 1> ;93h

    OPKRow <0EAh, m_JMP, 0FFh, OpBet16b, OpBet16b, 1> ;94h

    OPKRow <0EBh, m_JMP, 0FFh, OpBet8b, NoOp, 0> ;95h

    OPKRow <0F6h, m_MUL, 4h, OpR_m8b, NoOp, 0> ;96h
    OPKRow <0F7h, m_MUL, 4h, OpR_m16b, NoOp, 1> ;97h

    OPKRow <0F6h, m_DIV, 6h, OpR_m8b, NoOp, 0> ;98h
    OPKRow <0F7h, m_DIV, 6h, OpR_m16b, NoOp, 1> ;99h

    OPKRow <0FEh, m_INC, 0h, OpR_m8b, NoOp, 0> ;9Ah
    OPKRow <0FFh, m_INC, 0h, OpR_m16b, NoOp, 1> ;9Bh

    OPKRow <0FEh, m_DEC, 1h, OpR_m8b, NoOp, 0> ;9Ch
    OPKRow <0FFh, m_DEC, 1h, OpR_m16b, NoOp, 1> ;9Dh

    OPKRow <0FFh, m_CALL, 2h, NoOp, NoOp, 0> ;9Eh
    OPKRow <0FFh, m_CALL, 3h, NoOp, NoOp, 0> ;9Fh

    OPKRow <0FFh, m_CALL, 4h, NoOp, NoOp, 0> ;100h
    OPKRow <0FFh, m_CALL, 5h, NoOp, NoOp, 0> ;101h

    OPKRow <0FFh, m_PUSH, 6h, OpR_m16b, NoOp, 1> ;102h
