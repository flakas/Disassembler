.model small
buferioDydis	EQU	121
BSeg SEGMENT
	ORG	100h
	ASSUME ds:BSeg, cs:BSeg, ss:BSeg
Pradzia:
    MOV ax, bx
    MOV bx, [bx]
    MOV bx, [bp-2]
    MOV ds, ax
    MOV byte ptr [si+123], 16h
    MOV ax, 1

	MOV	ah, 9
	MOV	dx, offset ivesk
	INT	21h

	MOV	ah, 0Ah
	MOV	dx, offset bufDydis
	INT	21h

	MOV	ah, 9
	MOV	dx, offset enteris
	INT	21h

;****algoritmas****
	XOR	ch, ch
	SUB	ax, ax
	MOV	cl, nuskaite
	MOV	bx, offset buferis
	MOV	dl, 'A'
	MOV	dh, 'Z'

ciklas1:
	CMP	dl, [es:bx]
	JG	nelygu
	CMP	dh, [ds:bx]
	JL	nelygu
	INC	ax

nelygu:
	INC	bx
	DEC	cx
	CMP	cx, 0
	JG	ciklas1

;****Spausdinimas****
	MOV	dl, 10
	DIV	dl
	MOV	[rezult2 + 2], ah
	ADD	[rezult2 + 2], 030h
	XOR	ah, ah
	DIV	dl
	MOV	[rezult2 + 1], ah
	ADD	[rezult2 + 1], 030h
	MOV	[rezult2], al
	ADD	[rezult2], 030h

	MOV	ah, 9
	MOV	dx, offset rezult
	INT	21h
	
	

	MOV	ah, 4Ch
	MOV	al, 0
	INT	21h

;*******************Atkelta ið duomenø segmento*****************
	bufDydis DB  buferioDydis
	nuskaite DB  ?
	buferis	 DB  buferioDydis dup ('$')
	ivesk	 DB  'Iveskite eilute:', 13, 10, '$'
	rezult	 DB  'Radau tiek didziuju raidziu: '
	rezult2	 DB  3 dup (' ')
	enteris	 DB  13, 10, '$'
	
	PUSH ES
	qqqq     DB  0FFh, 0F7h, 69h
;***************************************************************

;*******************Pridëta*************************************
BSeg ENDS
;***************************************************************
END	Pradzia		
