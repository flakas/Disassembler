LOCALS @@

.MODEL SMALL
bufferioDydis EQU 255
poslinkis EQU 0h
.STACK 100h
.DATA
    nl db 0Dh, 0Ah, 0
    space db ' ', 0
    kablelis db ", ", 0
    pagalbosTekstas db "Author: Tautvidas", 13, 10
                    db "Usage: disasm data_file result_file$"
    trukstaFailuPavadinimuTekstas db "Please supply 2 filenames$"
    klaidaAtidarytiSkaitymasTekstas db "Cannot open file for reading$"
    klaidaAtidarytiRasymasTekstas db "Cannot open file for writing$"
    klaidaUzdarytiSkaitymasTekstas db "Cannot close file for reading$"
    klaidaUzdarytiRasymasTekstas db "Cannot close file for writing$"
    neatpazintasTekstas db "Unrecognized byte", 13, 10, 0
    lskliausk db '[', 0
    lskliausd db ']', 0
    pliusas db '+', 0
    dvitaskis db ':', 0

    fIn db 255 dup (0)
    fOut db 255 dup (0)
    hFin dw 0
    hFout dw 0
    readBuffer db bufferioDydis dup (0)
    readBytes dw 0
    paramReadStatus db 0h ;1h - read fin, 2h - found separator, 3h - reading fout
    IPpoz dw 0
    IPposl dw 0
    buffPoz dw 0
    hexCode db 0, 50 dup (0)
    parseBuffer db bufferioDydis dup (0) ;Hex code being parsed
    parseBufferIndex db 0
    codeBuffer db bufferioDydis dup (0)
    codeBufferIndex db 0
    printBuffer db bufferioDydis dup (0)
    printBufferIndex db 0
    abMod db 0
    abReg db 0
    abR_m db 0
    opWord db 0
    eilute dw 0
    betDydis16 db 0
    addIP db 0
    jmpIP dw 0
    bytePtr db "byte ptr ", 0
    wordPtr db "word ptr ", 0
    segmentas dw 0
    segmentoPoslinkis db 0
    reikiaBaito db 0

OPKRow STRUC
    fByte db 0
    mnem dw 0
    reg db 0
    op1 db 0
    op2 db 0
    w db 0
OPKRow ENDS

regTable STRUC
   tReg0 dw 0
   tReg1 dw 0
   tR_m00 dw 0
   tR_m01 dw 0
regTable ENDS

OPKRowSize equ 7h

include opcodes.asm


.CODE
Start:
    MOV ax, @data
    MOV ds, ax
    MOV cl, es:[80h]
    MOV ch, 01h ;We will ignore spaces
    MOV bx, 82h
    ;Are there any arguments?
    CMP ch, cl
    JGE Pagalba
    ;Is it the help argument?
    MOV dx, word ptr es:[bx]
    XCHG dl, dh
    CMP dx, "/?"
    JE tikrinti83
    JMP ruostiParamApdorojimui

tikrinti83: ;Is only /? entered? /*{{{*/
    PUSH bx
    MOV bx, 84h
    CMP byte ptr es:[bx], 0Dh ;Carriage return to be entered
    JE Pagalba
    POP bx
    JMP RuostiParamApdorojimui;/*}}}*/

Pagalba:;/*{{{*/
    MOV ah, 09h
    MOV dx, offset pagalbosTekstas
    INT 21h
    JMP Pabaiga;/*}}}*/

RuostiParamApdorojimui:;/*{{{*/
    MOV ax, 82h ;offset for reading
    MOV bx, offset fIn
    JMP ApdorotiParametrus;/*}}}*/

KeistiOut:;/*{{{*/
    MOV bx, offset fOut
    PUSH cx
    MOV cl, 1h
    MOV paramReadStatus, cl
    POP cx
    INC ax
    JMP ApdorotiParametrus;/*}}}*/

ApdorotiParametrus:;/*{{{*/
    CMP ch, cl
    JGE arAbu
    INC ch
    PUSH bx
    MOV bx, ax
    MOV dl, es:[bx]
    POP bx
    CMP dl, ' '
    JE KeistiOut
    MOV [bx], dl
    JMP KeistiSkaitliuka;/*}}}*/

KeistiSkaitliuka:;/*{{{*/
    INC ax
    INC bx
    JMP ApdorotiParametrus
;/*}}}*/
arAbu:;/*{{{*/
    MOV cl, paramReadStatus
    CMP cl, 1h
    JNE Pagalba
    JMP AtidarytiFailus;/*}}}*/

AtidarytiFailus:;/*{{{*/
    MOV ah, 3Dh
    MOV al, 00h
    MOV dx, offset fIn
    INT 21h
    JC KlaidaAtidarytiSkaitymas
    MOV hFin, ax

    MOV ah, 3Ch
    MOV al, 00h
    MOV cx, 0000h
    MOV dx, offset fOut
    INT 21h
    JC KlaidaAtidarytiRasymas
    MOV hFout, ax

    JMP DarytiPoslinki
    JMP UzdarytiFailus;/*}}}*/

KlaidaAtidarytiSkaitymas:;/*{{{*/
    MOV ah, 09h
    MOV dx, offset klaidaAtidarytiSkaitymasTekstas
    INT 21h
    JMP Pabaiga;/*}}}*/

KlaidaAtidarytiRasymas:;/*{{{*/
    MOV ah, 09h
    MOV dx, offset klaidaAtidarytiRasymasTekstas
    INT 21h
    JMP Pabaiga;/*}}}*/

KlaidaUzdarytiSkaitymas:;/*{{{*/
    MOV ah, 09h
    MOV dx, offset klaidaUzdarytiSkaitymasTekstas
    INT 21h
    JMP Pabaiga
;/*}}}*/
KlaidaUzdarytiRasymas:;/*{{{*/
    MOV ah, 09h
    MOV dx, offset klaidaUzdarytiRasymasTekstas
    INT 21h
    JMP Pabaiga;/*}}}*/

UzdarytiFailus:;/*{{{*/
    ;Uzdaryti skaityma
    MOV ah, 3Eh
    MOV bx, hFin
    INT 21h
    JC KlaidaUzdarytiSkaitymas
    ;Uzdaryti rasyma
    MOV ah, 3Eh
    MOV bx, hFout
    INT 21h
    JC KlaidaUzdarytiRasymas
    JMP Pabaiga
;/*}}}*/
DarytiPoslinki:;/*{{{*/
    MOV ax, poslinkis
    ;MOV bx, 10h
    ;MUL bx
    MOV dx, ax
    MOV ah, 42h
    MOV al, 00h
    MOV cx, 0000h
    MOV bx, hFin
    INT 21h
    JC KlaidaUzdarytiRasymas
    ;Error handler is needed
    JMP Skaityti;/*}}}*/

Skaityti:
    CALL Nuskaityti
    JMP ApdorotiBufferi

TestiSkaityma:
    CMP readBytes, bufferioDydis
    JB UzdarytiFailus
    JMP Skaityti

Nuskaityti PROC;/*{{{*/
    ;Reads "bufferioDydis" number of bytes from data file
    PUSH bx
    PUSH cx
    PUSH dx
    MOV bx, hFin
    MOV cx, bufferioDydis
    MOV dx, offset readBuffer
    MOV ax, 3F00h
    INT 21h
    MOV readBytes, ax
    POP dx
    POP cx
    POP bx
    RET
Nuskaityti ENDP;/*}}}*/

ApdorotiBufferi:
    MOV buffPoz, 0000h
    CALL Apdoroti
    JMP TestiSkaityma

Apdoroti PROC;/*{{{*/
    @@aPradzia:
        MOV parseBufferIndex, 00h
        MOV bx, buffPoz
        CMP bx, readBytes
        JG @@iPabaiga

        MOV segmentoPoslinkis, 00h
        CALL getBuffByte
        ;Is it segment changing prefix?
        CALL checkSegment
        CALL printIP
        CALL ieskotiOPK
        CMP printBufferIndex, 0h
        JA @@Atpazinta
        JMP @@Neatpazinta

    @@iPabaiga:
        JMP @@aPabaiga

    @@Atpazinta:
        ;Bytes have been recognized, processed and parsed. Can print the parsed bytes and command text
        CALL printParseBuffer
        MOV ch, 00h
        MOV cl, printBufferIndex
        MOV dx, offset printBuffer
        CALL printAscii
        JMP @@KitaKomanda

    @@Neatpazinta:
        ;Not recognized. Printing parsed byte and "Not recognized" message
        CALL printParseBuffer
        MOV cx, 0013h
        MOV dx, offset neatpazintasTekstas
        CALL printAscii
        JMP @@KitaKomanda

    @@KitaKomanda:
        MOV segmentas, 0000h
        ;Adding instruction's offset to IP
        MOV bx, IPposl
        ADD bx, IPpoz
        MOV IPpoz, bx
        MOV IPposl, 00h

        MOV cx, 0002h
        MOV dx, offset nl
        CALL printAscii

        MOV cx, bufferioDydis
        MOV dx, offset printBuffer
        CALL cleanBuffer

        MOV printBufferIndex, 00h

        MOV dx, offset parseBuffer
        CALL cleanBuffer
        MOV parseBufferIndex, 00h

        MOV reikiaBaito, 00h

        ;Spausdinti
        JMP @@CikloTesimas

    @@CikloTesimas:
        JMP @@aPradzia

    @@aPabaiga:
        RET
Apdoroti ENDP;/*}}}*/

checkSegment PROC;/*{{{*/
    ;Checks if this is segment changing prefix
    ;If yes - prints it out and sets appropriate variables
    PUSH ax
    PUSH bx
    PUSH cx
    PUSH dx
    CMP ax, 26h
    JE @@ES
    CMP ax, 2Eh
    JE @@CS
    CMP ax, 36h
    JE @@SS
    CMP ax, 3Eh
    JE @@DS
    JMP @@Pabaiga
    @@ES:
        MOV bx, offset s_ES
        MOV segmentas, bx
        MOV segmentoPoslinkis, 01h
        CALL getBuffByte
        JMP @@Pabaiga
    @@CS:
        MOV bx, offset s_CS
        MOV segmentas, bx
        MOV segmentoPoslinkis, 01h
        CALL getBuffByte
        JMP @@Pabaiga
    @@SS:
        MOV bx, offset s_SS
        MOV segmentas, bx
        MOV segmentoPoslinkis, 01h
        CALL getBuffByte
        JMP @@Pabaiga
    @@DS:
        MOV bx, 0000h
        MOV segmentas, bx
        MOV segmentoPoslinkis, 01h
        CALL getBuffByte
        JMP @@Pabaiga

    @@Pabaiga:
        POP dx
        POP cx
        POP bx
        POP ax
        RET
checkSegment ENDP;/*}}}*/

ieskotiOPK PROC;/*{{{*/
    ;Iesko OPKodo pagal parseBuffer
    PUSH ax
    PUSH bx
    PUSH cx
    PUSH dx
    MOV bx, offset parseBuffer
    PUSH dx
    ;First may be segment changing prefix, reordering...
    MOV dl, parseBufferIndex
    SUB dl, 01h
    MOV dh, 00h
    ADD bx, dx
    POP dx
    MOV dx, offset Opcodes
    MOV cx, OpTableSize
    @@tikrintiOpk:
        MOV al, [bx]
        XCHG bx, dx
        CMP al, (OPKRow[bx]).fByte ;is this the right opcode?
        JE @@tikrintiReg
        XCHG bx, dx
        ADD dx, OPKRowSize
        LOOP @@tikrintiOpk
        JMP @@iopkPabaiga

    @@reikiaReg:
      ;Is reg an opcode extension?
      MOV ax, buffPoz
      PUSH dx
      MOV dx, offset readBuffer
      ADD dx, ax
      MOV si, dx
      MOV al, [si]
      AND al, 38h
      SHR al, 3h
      POP dx
      CMP (OPKRow[bx]).reg, al
      JE @@radauOPK
      JMP @@neMusu

    @@neMusu:
        ;reg field does not match, looking for another command
        CMP cx, 0000h
        JE @@baigti
        ADD bx, OPKRowSize
        DEC cx
        XCHG bx, dx
        JMP @@tikrintiOpk

    @@baigti:
        JMP @@iopkPabaiga

    @@tikrintiReg:
        ;kai reg=0FFh, reg nenaudojamas
        CMP (OPKRow[bx]).reg, 0FFh
        JNE @@reikiaReg
        JMP @@radauOPK

    @@galiButJMP:
        ;Jei tai jump'as - mums reiks pridet IP
        CMP dx, offset m_JG
        JA @@testiRadauOPK
        MOV addIP, 1h
        JMP @@testiRadauOPK

    @@radauOPK:
        MOV dx, (OPKRow[bx]).mnem
        CMP dx, offset m_JMP
        JGE @@galiButJMP

    @@testiRadauOPK:
        MOV cx, 0
        CALL strlen
        CALL movePrintBuffer
        PUSH ax
        MOV al, (OPKRow[bx]).w
        MOV opWord, al
        POP ax
        MOV eilute, bx
        CMP (OPKRow[bx]).op1, OpR_m8b
        JE @@iopk1OpR_m8b
        CMP (OPKRow[bx]).op1, OpR_m16b
        JE @@iopk1OpR_m8b
        CMP (OPKRow[bx]).op1, OpReg8b
        JE @@iopk1OpReg8b
        CMP (OPKRow[bx]).op1, OpReg16b
        JE @@iopk1OpReg8b
        CMP (OPKRow[bx]).op1, OpBet8b
        JE @@iopk1OpBet8b
        CMP (OPKRow[bx]).op1, OpBet16b
        JE @@iopk1OpBet16b
        CMP (OPKRow[bx]).op1, OpDS
        JBE @@Registras
        JMP @@iopkPabaiga

    @@iopk1OpR_m8b:
        MOV dx, offset space
        CALL strlen
        CALL movePrintBuffer
        CALL getBuffByte
        CALL forceParseAddrByte
        CALL getR_m
        JMP @@iAntrasOp

    ;@@iopk1OpR_m16b:
        ;MOV dx, offset space
        ;CALL strlen
        ;CALL movePrintBuffer
        ;CALL getBuffByte
        ;;Perstumiam adresavimo baitui parsint
        ;MOV dx, offset parseBuffer
        ;MOV ax, 0000h
        ;ADD al, parseBufferIndex
        ;SUB al, 1h
        ;ADD dx, ax
        ;CALL parseAddrByte
        ;CALL getR_m
        ;JMP @@iAntrasOp

    @@iopk1OpReg8b:
        MOV dx, offset space
        CALL strlen
        CALL movePrintBuffer
        CALL getBuffByte
        CALL forceParseAddrByte
        CALL getReg
        JMP @@iAntrasOp

    ;@@iopk1OpReg16b:
        ;MOV dx, offset space
        ;CALL strlen
        ;CALL movePrintBuffer
        ;CALL getBuffByte
        ;MOV dx, offset parseBuffer
        ;ADD dx, ax
        ;CALL parseAddrByte
        ;CALL getReg
        ;JMP @@iAntrasOp

      @@iopk1OpBet16b:
        MOV betDydis16, 1h

      @@iopk1OpBet8b:
         MOV dx, offset space
         CALL strlen
         CALL movePrintBuffer
         CALL getBetOp
         JMP @@iopkPabaiga

   @@Registras:
     CMP (OPKRow[bx]).op1, OpMem
     JE @@iopk1OpMem
     CMP (OPKRow[bx]).op1, OpMem
     JB @@iAntrasOp
     CALL arReikiaBaito
      MOV dx, offset space
      CALL strlen
      CALL movePrintBuffer
      MOV bl, (OPKRow[bx]).op1
     CALL Op1Reg
     JMP @@iAntrasOp

     @@iopk1OpMem:
        MOV dx, offset space
        CALL strlen
        CALL movePrintBuffer
        CALL getMemOp

    @@iAntrasOp:
        MOV bx, eilute
        CMP (OPKRow[bx]).op2, OpR_m8b
        JE @@iopk2OpR_m8b
        CMP (OPKRow[bx]).op2, OpR_m16b
        JE @@iopk2OpR_m8b
        CMP (OPKRow[bx]).op2, OpReg8b
        JE @@iopk2OpReg8b
        CMP (OPKRow[bx]).op2, OpReg16b
        JE @@iopk2OpReg16b
        CMP (OPKRow[bx]).op2, OpBet8b
        JE @@iopk2OpBet8b
        CMP (OPKRow[bx]).op2, OpBet16b
        JE @@iopk2OpBet16b
        CMP (OPKRow[bx]).op2, OpDS
        JBE @@Registras2
        JMP @@iopkPabaiga

    @@iopk2OpR_m8b:
        CALL forceParseAddrByte
        CALL opkOpR_m8b
        JMP @@iopkPabaiga

    ;@@iopk2OpR_m16b:
        ;MOV dx, offset kablelis
        ;CALL strlen
        ;CALL movePrintBuffer
        ;CALL getR_m
        ;JMP @@iopkPabaiga

    @@iopk2OpReg8b:
        MOV dx, offset kablelis
        CALL strlen
        CALL movePrintBuffer
        CALL forceParseAddrByte
        CALL getReg
        JMP @@iopkPabaiga

    @@iopk2OpReg16b:
        MOV dx, offset kablelis
        CALL strlen
        CALL movePrintBuffer
        CALL getBuffByte
        CALL forceParseAddrByte
        CALL getReg
        JMP @@iopkPabaiga

      @@iopk2OpBet16b:
         MOV betDydis16, 1h

      @@iopk2OpBet8b:
         MOV dx, offset kablelis
         CALL strlen
         CALL movePrintBuffer
         CALL getBetOp
         JMP @@iopkPabaiga

      ;@@iopk2OpBet16b:
         ;MOV dx, offset kablelis
         ;CALL strlen
         ;CALL movePrintBuffer
         ;CALL getBetOp
         ;JMP @@iopkPabaiga
   @@Registras2:
     CMP (OPKRow[bx]).op2, OpMem
     JBE @@iopkPabaiga
      MOV dx, offset kablelis
      CALL strlen
      CALL movePrintBuffer
      MOV bl, (OPKRow[bx]).op2
     CALL Op1Reg
     JMP @@iopkPabaiga

    @@iopkPabaiga:
        POP dx
        POP cx
        POP bx
        POP ax
        RET
ieskotiOPK ENDP;/*}}}*/

arReikiaBaito PROC
     CMP (OPKRow[bx]).op1, OpES
     JB @@Pabaiga
     CMP (OPKRow[bx]).op1, OpDS
     JA @@Pabaiga
     CMP (OPKRow[bx]).op2, OpR_m16b
     JNE @@Pabaiga
     MOV reikiaBaito, 1h

   @@Pabaiga:
    RET
arReikiaBaito ENDP

opkOpR_m8b PROC;/*{{{*/
        ;Moved from main procedure due to it being unreachable for jumps
        MOV dx, offset kablelis
        CALL strlen
        CALL movePrintBuffer
        CALL forceParseAddrByte
        CALL getR_m
        RET
opkOpR_m8b ENDP;/*}}}*/

forceParseAddrByte PROC;/*{{{*/
    ;Just to make sure...
    MOV dx, offset parseBuffer
    MOV ax, 0001h
    ADD al, segmentoPoslinkis
    ADD dx, ax
    CALL parseAddrByte
    RET
forceParseAddrByte ENDP;/*}}}*/

op1Reg PROC;/*{{{*/
    ;Operand - register
   PUSH ax
   PUSH bx
   PUSH cx
   PUSH dx
      MOV cl, bl
      CMP cl, OpES
      JE @@ES
      CMP cl, OpCS
      JE @@CS
      CMP cl, OpSS
      JE @@SS
      CMP cl, OpDS
      JE @@DS
      CMP cl, OpAX
      JGE @@col2
      SUB cl, OpAL
      MOV ch, 00h
      JMP @@findReg
   @@ES:
        MOV dx, offset s_ES
        JMP @@radauReg
    @@CS:
        MOV dx, offset s_CS
        JMP @@radauReg
    @@SS:
        MOV dx, offset s_SS
        JMP @@radauReg
    @@DS:
        MOV dx, offset s_DS
        JMP @@radauReg
   @@col2:
      SUB cl, OpAX
      MOV ch, 02h

   @@findReg:
      ;Find it based on offset in the table
      MOV al, cl
      MOV ah, regTableSize
      MUL ah
      ADD al, ch
      MOV bx, offset RegR_mTable
      ADD bx, ax
      MOV dx, [bx]

      JMP @@radauReg

    @@darBaitas:
        CALL getBuffByte
        JMP @@pabaiga

    @@radauReg:
      CALL strlen
      CALL movePrintBuffer
      CMP reikiaBaito, 1h
      JE @@darBaitas


    @@pabaiga:
   POP dx
   POP cx
   POP bx
   POP ax
   RET
op1Reg ENDP;/*}}}*/

getR_m PROC;/*{{{*/
   PUSH dx
   PUSH bx
   PUSH cx
   PUSH ax
   MOV dx, 0000h
   MOV ax, 0000h
   PUSH ax
   MOV bx, offset RegR_mTable
   CMP abMod, 00h;mod=00
   JE @@posl2
   CMP abMod, 01h;mod=01
   JE @@posl3
   CMP abMod, 02h;mod=10
   JE @@posl3
   ;mod=11
   CMP opWord, 01h
   JE @@posl1
   JMP @@loopint ;No need for offset

   @@posl1:;wordas
      ADD bx, 0002h
      JMP @@loopint

   @@posl2:;mod=00
      POP ax
      MOV ax, 0001h
      PUSH ax
      PUSH dx
      PUSH cx
      ;May need byte/word ptr
      CALL getPtrText
      ;May need segment changing prefix
      CALL getSegment
      ;Need angled brackets
      MOV dx, offset lskliausk
      CALL strlen
      CALL movePrintBuffer
      POP cx
      POP dx
      ;Offset within the table
      ADD bx, 0004h
      ;Direct addressing?
      CMP abR_m, 06h
      JE @@tiesioginis
      JMP @@loopint

   @@posl3:;mod=01/10
      ADD bx, 0006h
      POP ax
      MOV ax, 0001h
      PUSH ax
      PUSH dx
      PUSH cx
      CALL getPtrText
      CALL getSegment
      MOV dx, offset lskliausk
      CALL strlen
      CALL movePrintBuffer
      POP cx
      POP dx
      CALL getBuffByte
      CMP abMod, 02h
      JE @@2Bposl
      JMP @@loopint

   @@2Bposl:
      CALL getBuffByte
      JMP @@loopint

   @@loopint:
        ;Find based on offset
      MOV al, abR_m
      MOV ah, 00h
      MOV cx, RegTableSize
      MUL cx
      ADD bx, dx
      ADD bx, ax
      MOV dx, [bx]
      CALL strlen
      CALL movePrintBuffer
      CMP abMod, 01h
      JE @@darytiPosl1b
      CMP abMod, 02h
      JE @@darytiPosl2b
      JMP @@Pabaiga

    @@tiesioginis:
        CALL getBuffByte
        CALL getBuffByte
        MOV dx, offset parseBuffer
        MOV bh, 00h
        MOV bl, parseBufferIndex
        SUB bx, 0002h
        MOV cx, 0002h
        ADD dx, bx
        ; Swap bet. op. for printing
        MOV bx, dx
        MOV ax, word ptr [bx]
        XCHG ah, al
        MOV word ptr [bx], ax

        CALL printHex
        ; Swap bet. op. back
        XCHG ah, al
        MOV word ptr [bx], ax
        MOV dx, offset hexCode + 1h
        MOV cl, hexCode
        MOV ch, 00h
        CALL movePrintBuffer
        JMP @@Pabaiga

    @@darytiPosl1b:
        MOV dx, offset pliusas
        CALL strlen
        CALL movePrintBuffer

        MOV dx, offset parseBuffer
        MOV bh, 00h
        MOV bl, parseBufferIndex
        SUB bx, 0001h
        ADD dx, bx
        MOV cx, 0001h
        CALL printHex
        MOV dx, offset hexCode + 1h
        MOV cl, hexCode
        MOV ch, 00h
        CALL movePrintBuffer
        JMP @@Pabaiga

    @@darytiPosl2b:
        MOV dx, offset pliusas
        CALL strlen
        CALL movePrintBuffer

        MOV dx, offset parseBuffer
        MOV bh, 00h
        MOV bl, parseBufferIndex
        SUB bx, 0002h
        MOV cx, 0002h
        ADD dx, bx
        ; Swap bet. op. for printing
        MOV bx, dx
        MOV ax, word ptr [bx]
        XCHG ah, al
        MOV word ptr [bx], ax

        CALL printHex
        ; Swap bet. op. back
        XCHG ah, al
        MOV word ptr [bx], ax
        MOV dx, offset hexCode + 1h
        MOV cl, hexCode
        MOV ch, 00h
        CALL movePrintBuffer
        JMP @@Pabaiga

   @@baigtiSkliausti:
      MOV dx, offset lskliausd
      CALL strlen
      CALL movePrintBuffer
      MOV ax, 0000h
      PUSH ax

   @@Pabaiga:
      POP ax
      CMP ax, 0001h
      JE @@baigtiSkliausti
      POP ax
      POP cx
      POP bx
      POP dx
      RET
getR_m ENDP;/*}}}*/

getPtrText PROC;/*{{{*/
    PUSH ax
    PUSH bx
    PUSH cx
    PUSH dx
    MOV bx, eilute
    CMP (OPKRow[bx]).op1, OpR_m8b
    JL @@Pabaiga
    CMP (OPKRow[bx]).op1, OpR_m16b
    JG @@Pabaiga
    CMP (OPKRow[bx]).op2, OpBet8b
    JL @@Pabaiga
    CMP (OPKRow[bx]).op2, OpBet16b
    JG @@Pabaiga
    CMP (OPKRow[bx]).op2, OpBet8b
    JE @@baitas
    JMP @@wordas

    @@baitas:
        MOV dx, offset bytePtr
        CALL strlen
        CALL movePrintBuffer
        JMP @@Pabaiga

    @@wordas:
        MOV dx, offset wordPtr
        CALL strlen
        CALL movePrintBuffer
        JMP @@Pabaiga

    @@Pabaiga:
        POP dx
        POP cx
        POP bx
        POP ax
        RET
getPtrText ENDP;/*}}}*/

getSegment PROC;/*{{{*/
    ;Prints prefix for segment change
    PUSH ax
    PUSH bx
    PUSH cx
    PUSH dx
        CMP segmentas, 0000h
        JE @@Pabaiga
        MOV dx, segmentas
        CALL strlen
        CALL movePrintBuffer
        MOV dx, offset dvitaskis
        CALL strlen
        CALL movePrintBuffer
    @@Pabaiga:
        POP dx
        POP cx
        POP bx
        POP ax
        RET
getSegment ENDP;/*}}}*/

getReg PROC;/*{{{*/
    ;Gets register when one is specified in the table
   PUSH dx
   PUSH bx
   PUSH cx
   PUSH ax
   MOV dx, 0000h
   MOV cx, RegTableSize
   MOV bx, offset RegR_mTable
   CMP opWord, 01h
   JE @@posl1
   JMP @@loopint ;No need for offset

   @@posl1:
      ADD bx, 0002h
      JMP @@loopint

   @@loopint:
      MOV al, abReg
      MOV ah, 00h
      MUL cx
      ADD bx, ax
      ADD bx, dx
      MOV dx, [bx]
      CALL strlen
      CALL movePrintBuffer

   @@Pabaiga:
      POP ax
      POP cx
      POP bx
      POP dx
      RET
getReg ENDP;/*}}}*/

getBetOp PROC;/*{{{*/
    ;Gets direct 1B/2B operand
    PUSH ax
    PUSH bx
    PUSH cx
    PUSH dx
    CMP betDydis16, 1h
    JE @@wordas
    JMP @@baitas

    @@wordas:
      CALL getBuffByte
      CALL getBuffByte


    @@testiWorda:
      MOV dx, offset parseBuffer
      MOV bh, 00h
      MOV bl, parseBufferIndex
      SUB bx, 0002h
      MOV cx, 0002h
      ADD dx, bx
      CALL addSegmentAddr
      ; Swap bet. op. for printing
      MOV bx, dx
      MOV ax, word ptr [bx]
      XCHG ah, al
      MOV word ptr [bx], ax

      CALL printHex
      ; Swap bet. op. back
      XCHG ah, al
      MOV word ptr [bx], ax
      MOV dx, offset hexCode + 1h
      MOV cl, hexCode
      MOV ch, 00h
      CALL movePrintBuffer

      JMP @@Pabaiga


    @@pridetiIP:
        ;If we can use it to get the offset, should we add IP?
        MOV bx, dx
        MOV di, offset jmpIP
        MOV cx, 0000h
        ADD cl, [bx]
        ADD cx, IPPoz
        ADD cx, IPPosl
        MOV jmpIP, cx
        MOV bx, jmpIP
        XCHG bh, bl
        MOV jmpIP, bx
        MOV dx, offset jmpIP
        MOV cx, 0002h
        JMP @@testiIP

    @@baitas:
      CALL getBuffByte
      MOV dx, offset parseBuffer
      MOV bl, parseBufferIndex
      MOV bh, 00h
      SUB bx, 0001h
      MOV cx, 0001h
      ADD dx, bx
      CMP addIP, 1h
      JE @@pridetiIP
    @@testiIP:
      CALL printHex
      MOV dx, offset hexCode + 1h
      MOV cl, hexCode
      MOV ch, 00h
      CALL movePrintBuffer
   
   @@Pabaiga:
       MOV addIP, 0h
       MOV betDydis16, 0h
       POP dx
       POP cx
       POP bx
       POP ax
       RET
getBetOp ENDP;/*}}}*/

addSegmentAddr PROC;/*{{{*/
    ;Is it a 4 byte address (2B for segment, 2 for address)?
    PUSH ax
    PUSH bx
    PUSH cx
    PUSH dx
    MOV bx, eilute
    CMP (OPKRow[bx]).op1, OpBet16b
    JNE @@Pabaiga
    CMP (OPKRow[bx]).op2, OpBet16b
    JNE @@Pabaiga
    ;We have two 16b direct ones, here should be a segment address
    CALL getBuffByte
    CALL getBuffByte
    MOV dx, offset parseBuffer
      MOV bh, 00h
      MOV bl, parseBufferIndex
      SUB bx, 0002h
      MOV cx, 0002h
      ADD dx, bx
      CALL addSegmentAddr
      ; Swap bet. op. for printing
      MOV bx, dx
      MOV ax, word ptr [bx]
      XCHG ah, al
      MOV word ptr [bx], ax

      CALL printHex
      ; Swap bet. op. back
      XCHG ah, al
      MOV word ptr [bx], ax
      MOV dx, offset hexCode + 1h
      MOV cl, hexCode
      MOV ch, 00h
      CALL movePrintBuffer
      MOV dx, offset dvitaskis
      CALL strlen
      CALL movePrintBuffer


    @@Pabaiga:
        POP dx
        POP cx
        POP bx
        POP ax
        RET
addSegmentAddr ENDP;/*}}}*/

getMemOp PROC;/*{{{*/
    ;When operand is OpMem
    PUSH ax
    PUSH bx
    PUSH cx
    PUSH dx
    MOV dx, offset lskliausk
    CALL strlen
    CALL movePrintBuffer
    MOV betDydis16, 1h
    CALL getBetOp

    @@Pabaiga:
        MOV dx, offset lskliausd
        CALL strlen
        CALL movePrintBuffer
        POP dx
        POP cx
        POP bx
        POP ax
        RET
getMemOp ENDP;/*}}}*/

doDebug PROC;/*{{{*/
    ;Poor mans debugger
   PUSH dx
   MOV dx, offset pliusas
   CALL strlen
   CALL movePrintBuffer
   POP dx
   RET
doDebug ENDP;/*}}}*/

movePrintBuffer PROC;/*{{{*/
    ;Appends string to print buffer
    ;dx Source string
    ;cx How many bytes?
    PUSH ax
    PUSH bx
    PUSH cx
    PUSH dx
    MOV ah, 00h
    MOV al, printBufferIndex
    MOV bx, offset printBuffer
    ADD bx, ax

    @@Perkelti:
        XCHG bx, dx
        MOV ax, [bx]
        XCHG bx, dx
        MOV [bx], ax
        INC printBufferIndex
        INC bx
        INC dx
        LOOP @@Perkelti

    @@mpbPabaiga:
        POP dx
        POP cx
        POP bx
        POP ax
        RET
movePrintBuffer ENDP;/*}}}*/

printIP PROC;/*{{{*/
    ;Print IP begin
    MOV bx, IPpoz
    XCHG bh, bl
    MOV IPpoz, bx
    PUSH dx
    PUSH cx
    MOV cx, 0002h
    MOV dx, offset IPpoz
    CALL printHex
    CALL printAscii
    MOV cx, 0001h
    MOV dx, offset space
    CALL printAscii
    POP cx
    POP dx
    ;Flip IP back
    MOV bx, IPpoz
    XCHG bh, bl
    MOV IPpoz, bx
    ;Print IP end
    RET
printIP ENDP;/*}}}*/

printParseBuffer PROC;/*{{{*/
    MOV cl, parseBufferIndex
    MOV ch, 00h
    MOV dx, offset parseBuffer
    CALL printHex
    CALL printAscii
    ;Space
    MOV cx, 0001h
    MOV dx, offset space
    CALL printAscii
    RET
printParseBuffer ENDP;/*}}}*/

moveCodeBuffer PROC;/*{{{*/
    ;Moves string to codeBuffer
    ;dx string offset
    ;cx bytes to move
    PUSH bx
    PUSH ax
    MOV bx, offset codeBuffer
    @@mcbStart:
        CMP cx, 0000h
        JBE @@mcbEnd
        PUSH bx
        MOV bx, dx
        MOV al, [bx]
        POP bx
        MOV [bx], al
        INC dx
        INC bx
        DEC cx
        JMP @@mcbStart

    @@mcbEnd:
    POP ax
    POP bx
    RET
moveCodeBuffer ENDP;/*}}}*/

getBuffByte PROC;/*{{{*/
    ;Sets ax to BuffByte
    PUSH bx
    ;Read Byte
    MOV bx, buffPoz
    CMP readBytes, bx
    JE @@priskaityti
    JMP @@testi

    @@priskaityti:
        CALL Nuskaityti
        CMP ax, 0000h
        JE @@baigti
        MOV buffPoz, 0000h
        MOV bx, buffPoz
        JMP @@testi

    @@baigti:
        JMP Pabaiga

    @@testi:
        MOV ah, 00h
        MOV al, [offset readBuffer + bx]
        ;Move byte to parse buffer
        MOV bl, parseBufferIndex
        MOV bh, 00h
        MOV [offset parseBuffer + bx], al
        ;Increment stuff
        INC parseBufferIndex
        INC buffPoz
        INC IPposl
        POP bx
        RET
getBuffByte ENDP;/*}}}*/

strlen PROC;/*{{{*/
    ;Sets cx to the length of string
    ;dx - string head address
    MOV cx, 0000h
    PUSH bx
    MOV bx, dx
    @@sCiklas:
        CMP byte ptr [bx], 0
        JE @@sPabaiga
        INC cx
        INC bx
        JMP @@sCiklas
    @@sPabaiga:
    POP bx
        RET
strlen ENDP;/*}}}*/

printHex PROC;/*{{{*/
    ;Print to hFout in hex
    ;dx - buffer offset
    ;cx - bytes to print
    PUSH bx
    PUSH ax
    MOV bx, offset hexCode
    MOV byte ptr [bx], 00h
    @@prhPradzia:
        CMP cx, 0000h
        JLE @@prhPabaiga
        MOV bx, dx
        MOV al, byte ptr [bx]
        MOV bl, 10h
        MUL bl
        PUSH ax
        MOV al, hexCode
        MOV ah, 00h
        MOV bx, offset hexCode + 1h
        ADD bx, ax
        POP ax
        SHR al, 4h
        CMP ah, 9h
        JBE @@prhHSkaitmuo

        SUB ah, 10
        ADD ah, 'A'
        MOV [bx], ah
        INC hexCode
        INC bx
        JMP @@prhLow

    @@prhHSkaitmuo:
        ADD ah, '0'
        MOV [bx], ah
        INC hexCode
        INC bx
        JMP @@prhLow

    @@prhLow:
        CMP al, 9h
        JBE @@prhLSkaitmuo
        SUB al, 10
        ADD al, 'A'
        MOV [bx], al
        JMP @@prhCiklas

    @@prhLSkaitmuo:
        ADD al, '0'
        MOV [bx], al
        JMP @@prhCiklas

    @@prhCiklas:
        INC hexCode
        INC bx
        INC dx
        DEC cx
        JMP @@prhPradzia

    @@prhPabaiga:
        MOV dx, offset hexCode + 1h
        MOV cl, hexCode
        MOV ch, 00h
        ;CALL printAscii
        POP ax
        POP bx
        RET

printHex ENDP;/*}}}*/

printAscii PROC;/*{{{*/
    ;Print to hFout in ASCII
    ;dx - buffer offset
    ;cx - bytes to print
    MOV ah, 40h
    MOV al, 00h
    MOV bx, hFout
    INT 21h
    RET
printAscii ENDP;/*}}}*/

cleanBuffer PROC;/*{{{*/
    ;Do a buffer cleanup
    ;bx - buffer offset
    ;cx - buffer size
    @@cbPradzia:
        CMP cx, 0000h
        JBE @@cbPabaiga
        MOV byte ptr [bx], 00h
        INC bx
        DEC cx
        JMP @@cbPradzia
    @@cbPabaiga:
    RET
cleanBuffer ENDP;/*}}}*/

parseAddrByte PROC;/*{{{*/
    ;dx - offset to addressing byte (what needs to be parsed)
    PUSH bx
    ;MOD
    MOV bx, dx 
    MOV bl, byte ptr [bx] 
    AND bl, 0C0h
    ROL bl, 2
    MOV abMod, bl

    ;REG
    MOV bx, dx
    MOV bl, byte ptr[bx]
    AND bl, 38h
    ROR bl, 3
    MOV abReg, bl

    ;R/M
    MOV bx, dx
    MOV bl, byte ptr [bx]
    AND bl, 07h
    MOV abR_m, bl
    POP bx
    RET
parseAddrByte ENDP;/*}}}*/

Pabaiga:;/*{{{*/
    MOV ax, 4C00h
    INT 21h;/*}}}*/
END Start
