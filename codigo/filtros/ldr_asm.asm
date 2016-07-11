section .rodata
	;max: dd 0x004A6A4B

DEFAULT REL

section .text

global ldr_asm

 %define i r12
 %define j r13
 %define SRC rdi
 %define DST rsi
 %define COLS rdx
 %define FILAS rcx
 %define ALPHA [rbp+16]


;						rdi		 rsi 			rdx
;aplicarFiltroldr(src_rgba_t*, src_row_size, ALPHA)
%macro aplicarFiltroldr 0
	
	xor r14, r14
	mov r14d, edx
	mov r13, rdi
	lea r12, [r13 - 8]					; r12 <- I(i,j-2)
	mov r9, rsi 								
	add r9, r9                  ; r9 <- src_row_size*2 

	sub r12, r9 								; r12 <- I(i-2,j-2)
	
	xor r8, r8
	pxor xmm14, xmm14
	pxor xmm0, xmm0

	.ciclo1:
		movdqu xmm0, [r12]				; pongo en xmm0 los 128b de los 4 pixeles - xmm0 = p[i-2,j-2] | p[i-2,j-1] | p[i-2,j] | p[i-2,j+1] 

		pxor xmm7, xmm7
		movdqu xmm15, xmm0				; xmm15 = p0 | p1 | p2 | p3

		punpcklbw xmm0, xmm7			; xmm0 = 0 | a7 | . . . | 0 | a0
		punpckhbw xmm15, xmm7			; xmm15 = 0 | a15 | . . . | 0 | a8

		sumarPixeles
		paddd xmm14, xmm0					; xmm14 = R0+G0+B0 + R1+G1+B1 | 0 | 0 | 0 

		movups xmm0, xmm15
		sumarPixeles					; xmm0 = R2+G2+B2 + R3+G3+B3 | 0 | 0 | 0 
		paddd xmm14, xmm0					; xmm14 = sumaP0 + .. + sumaP3  | 0 | 0 | 0 

		add r12, rsi

		inc r8
		cmp r8, 5
	jne .ciclo1

	xor r8, r8

	lea r12, [r13 + 8]					
	sub r12, r9									; r12 <- I(i-2,j+2)

	.ciclo_2:

		movd xmm0, [r12]					; pongo en xmm0 los 4Bytes del pixel - xmm0 = p[i+2,j-2] | . | . | .

		pxor xmm7, xmm7
		punpcklbw xmm0, xmm7			; xmm0 = 0 | a7 | . . . | 0 | a0
		sumarPixel
		paddd xmm14, xmm0					; xmm14 = SUMAVECINOS  | 0 | 0 | 0

		add r12, rsi

		inc r8
		cmp r8, 5
	jne .ciclo_2


	;xmm14 = SUMAVECINOS  | 0 | 0 | 0
	pxor xmm1, xmm1
	pxor xmm3, xmm3
	movd xmm3, [r13] 			; xmm3 = R | G | B | A

	mov rdi, 0x004A6A4B
	movq xmm1, rdi				; xmm1 = max
	pxor xmm0, xmm0
	movd xmm0, r14d				; xmm0 = alpha

	pxor xmm2, xmm2
	pxor xmm4, xmm4						

	CVTDQ2PS xmm2, xmm14	; xmm2 = SUMAVECINOS | 0 | 0 | 0 donde SUMAVECINOS es FLOAT.
	CVTDQ2PS xmm4, xmm0		; xmm4 = ALPHA | 0 | 0 | 0 donde ALPHA es FLOAT .
	pxor xmm0, xmm0
	CVTDQ2PS xmm0, xmm1		; xmm0 = MAX | 0 | 0 | 0 donde MAX es FLOAT.

	pxor xmm3, xmm3
	movups xmm3, xmm0			; xmm3 = MAX | 0 | 0 | 0
	pslldq xmm3, 4        ; xmm3 =  0 | MAX | 0 | 0
	paddb	xmm0, xmm3			; xmm0 = MAX | MAX | 0 | 0
	pslldq xmm3, 4        ; xmm3 =  0 | 0 | MAX | 0
	paddb	xmm0, xmm3			; xmm0 = MAX | MAX | MAX | 0
	pslldq xmm3, 4        ; xmm3 =  0 | 0 | 0 | MAX
	paddb	xmm0, xmm3			; xmm0 = MAX | MAX | MAX | MAX

	mulss xmm2, xmm4 			; xmm2 = SUMA*ALPHA | 0 | 0 | 0

	pxor xmm3, xmm3
	movups xmm3, xmm2			; xmm3 = SUMA*ALPHA | 0 | 0 | 0
	pslldq xmm3, 4        ; xmm3 =  0 | SUMA*ALPHA | 0 | 0
	paddb	xmm2, xmm3			; xmm2 = SUMA*ALPHA | SUMA*ALPHA | 0 | 0
	pslldq xmm3, 4        ; xmm3 =  0 | 0 | SUMA*ALPHA | 0
	paddb	xmm2, xmm3			; xmm2 = SUMA*ALPHA | SUMA*ALPHA | SUMA*ALPHA | 0
	
	pxor xmm3, xmm3
	movd xmm3, [r13]			; xmm3 = R | G | B | A | 0..<11 times more>
	pxor xmm7, xmm7
	punpcklbw xmm3, xmm7	
	pxor xmm7, xmm7
	punpcklwd xmm3, xmm7
	pxor xmm5, xmm5 
	CVTDQ2PS xmm5, xmm3   ; xmm5 = R | G | B | A donde son todos FLOAT(db)

	mulps	xmm2, xmm5			; xmm2 = SUMA*ALPHA*R | SUMA*ALPHA*G | SUMA*ALPHA*B | 0
 
	divps xmm2, xmm0 			; xmm2 = (SUMA*ALPHA*R)/ MAX | (SUMA*ALPHA*G)/ MAX | (SUMA*ALPHA*B)/ MAX | 0

	pxor xmm7, xmm7
	CVTPS2DQ xmm7, xmm2		; xmm7 = (SUMA*ALPHA*R)/ MAX | (SUMA*ALPHA*G)/ MAX | (SUMA*ALPHA*B)/ MAX | 0 donde son todos ENTEROS (tam double).

	pxor xmm3, xmm3
	movd xmm3, [r13] 			; xmm3 = R | G | B | A
	pxor xmm5, xmm5
	punpcklbw xmm3, xmm5
	pxor xmm5, xmm5
	punpcklwd xmm3, xmm5 ; xmm3 = R | G | B | A

	paddd xmm7, xmm3			; xmm7 = R+(SUMA*ALPHA*R)/ MAX | G+(SUMA*ALPHA*G)/ MAX | B+(SUMA*ALPHA*B)/ MAX | A+0
	
	packusdw xmm7, xmm2		; doubles -> words
	packuswb xmm7, xmm2		; words -> bytes (con saturacion y signo)

	pxor xmm5, xmm5
	mov rdi, 0xFFFFFFFF 	; mascara para setear todo en 0 menos las sumas. 
	movq xmm5, rdi				; xmm7 = 1 1 1 1 0 0 0 0
	pand xmm7, xmm5				; xmm7 = RFINAL | GFINAL | BFINAL | AFINAL | 0 | 0 | 0 | 0
	
	movups xmm0, xmm7
%endmacro

; Asumo que tengo los dos pixeles en xmm0 con los valores en word, lo que voy a hacer es R1+G2+B1 + R2+G2+B2 
%macro sumarPixeles 0

	movups xmm1, xmm0					; xmm0 = R0 | G0 | B0 | A0 | R1 | G1 | B1 | A1
								   					; xmm1 = R0 | G0 | B0 | A0 | R1 | G1 | B1 | A1
							    
	psrldq xmm1, 2						; shifteo xmm1 =  G0 | B0 | A0 | R1 | G1 | B1 | A1 | .

	paddw xmm0, xmm1					; xmm0 = R0+G0 | . | . | . | R1+G1 | . | . | .

	psrldq xmm1, 2						; shifteo xmm1 = B0 | A0 | R1 | G1 | B1 | A1 | . | .
	paddw xmm0, xmm1					; xmm0 = R0+G0+B0 | . | . | . | R1+G1+B1 | . | . | .

	pxor xmm7, xmm7
	mov rdi, 0xFFFF 					; mascara para setear todo en 0 menos las sumas. 
	movq xmm7, rdi						; xmm7 = 1 0 0 0 0 0 0 0
	movups xmm8, xmm7					; xmm8 = 1 0 0 0 0 0 0 0
	pslldq xmm7, 8						; xmm7 = 0 0 0 0 1 0 0 0
	addps xmm7, xmm8					; xmm7 = 1 0 0 0 1 0 0 0							
	pand xmm0, xmm7						; xmm0 = R0+G0+B0 | 0 | 0 | 0 | R1+G1+B1 | 0 | 0 | 0
	movups xmm1, xmm0					; xmm1 = R0+G0+B0 | 0 | 0 | 0 | R1+G1+B1 | 0 | 0 | 0

	psrldq xmm1, 8						; shifteo xmm1 = R1+G1+B1 | 0 | 0 | 0 | 0 | 0 | 0 | 0

	pxor xmm7, xmm7
	punpcklwd xmm0, xmm7			; xmm0 = R0+G0+B0 | 0 | R1+G1+B1 | 0  
	punpcklwd xmm1, xmm7			; xmm1 = R1+G1+B1 | 0 | 0 | 0 

	paddd xmm0, xmm1					; xmm0 = R0+G0+B0 + R1+G1+B1 | 0 | R1+G1+B1 | 0 
	
	pxor xmm7, xmm7
	mov rdi, 0xFFFF 					; mascara para setear todo en 0 menos las sumas. 
	movq xmm7, rdi						; xmm7 = 1 0 0 0 0 0 0 0
	pand xmm0, xmm7						; xmm0 = R0+G0+B0 + R1+G1+B1 | 0 | 0 | 0 |
%endmacro

%macro sumarPixel 0
		movups xmm1, xmm0				; xmm1 = R0 | G0 | B0 | A0 | . | . | . | .
		psrldq xmm1, 2					; shifteo xmm1 =  G0 | B0 | A0 | . | . | . | . | .
		paddw xmm0, xmm1				; xmm0 = R0+G0 | . | . | . | . | . | . | .
		psrldq xmm1, 2					; shifteo xmm1 = B0 | A0 | . | . | . | . | . | .
		paddw xmm0, xmm1				; xmm0 = R0+G0+B0 | . | . | . | . | . | . | .
		
		pxor xmm7, xmm7
		mov rdi, 0xFFFF 				; mascara para setear todo en 0 menos las sumas. 
		movq xmm7, rdi					; xmm7 = 1 0 0 0 0 0 0 0
		pand xmm0, xmm7					; xmm0 = R0+G0+B0 | 0 | 0 | 0 | 0 | 0 | 0 | 0
%endmacro

;void ldr_asm    (
	;unsigned char *src,
	;unsigned char *dst,
	;int filas,
	;int cols,
	;int src_row_size,
	;int dst_row_size,
	;int alpha) rbp +16

ldr_asm:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp, 8

	
	mov r14, SRC
	mov r15, DST
	
	mov r10, r8

	add r8, r8
	add r8, 8

	add r14, r8
	add r15, r8

	mov rbx, r14
	
	sub rcx, 4
	mov rsi, rcx
	mov r9, rcx

 	imul rcx, rsi

 	xor r11, r11

	.ciclo:

		xor rdx, rdx
		mov edx, ALPHA

		mov rdi, rbx
		mov rsi, r10
		
		aplicarFiltroldr

		movd [r15], xmm0

		add rbx, 4
		add r15, 4

		add r11, 1
		sub r9, 8
	 	cmp r11, r9

	 	jne .fin
		 	add r15, 16
		 	add rbx, 16
		 	xor r11, r11

 	.fin:
 	add r9, 8
	sub rcx, 1
	cmp rcx, 0
	jne .ciclo




	; .ciclo_filas:
	; 	xor j, j	; r13 = j = 0
	; 	mov j, 2	; j = 2
		
	; 	.ciclo_columnas:

	; 		mov rdi, r14
	; 		mov rsi, i
	; 		mov rdx, j
	; 		add r10, 2
	; 		mov rcx, r10

	; 		call matriz

	; 		mov rdi, rax
	; 		mov rsi, rbx

	; 		xor rdx, rdx
	; 		mov edx, ALPHA

	; 		call aplicarFiltroldr

	; 		mov rdi, r15
	; 		mov rsi, i
	; 		mov rdx, j
	; 		mov rcx, r10

	; 		call matriz
	; 		mov rdi, rax
	; 		movd [rdi], xmm0
	; 		sub r10, 2
	; 		inc j
	; 		cmp j, r10
	; 	jne .ciclo_columnas

	; 	inc i
	; 	cmp i, r11
	; jne .ciclo_filas

	add rsp, 8
	pop r12
	pop r13
	pop r14
	pop r15
	pop rbx
	pop rbp
ret



; %define tam_4pxs 16


; global ldr_asm

; section .data
; maximo: DD 4876875.0 , 4876875.0 , 4876875.0 , 4876875.0  
; section .text
; ;void ldr_asm    (
; 	;unsigned char *src,		RDI
; 	;unsigned char *dst,		RSI	
; 	;int filas,					RDX
; 	;int cols,					RCX
; 	;int src_row_size,			R8
; 	;int dst_row_size,			R9
; 	;int alpha)					--R10 (Lo vamos a mover nosotros)

; ldr_asm:
; push rbp
; mov rbp,rsp
; push r12
; push r13
; push r14
; push r15

; xor r10,r10
; mov r10d, [rbp+16] ; alpha
; mov r12,2 ;indice fila en 2
; mov r13,2 ; indice col en 2
; mov r14,rcx
; mov r15,rdx
; sub r14,2;TOPE FILA
; sub r15,2;TOPE COL
; mov rcx,rdx
; xor rdx,rdx
; xor r9,r9
; pxor xmm15,xmm15 ;lo voy a usar para desempaquetar
; pxor xmm0,xmm0
; pxor xmm1,xmm1
; pxor xmm2,xmm2
; pxor xmm3,xmm3
; pxor xmm4,xmm4
; pxor xmm5,xmm5
; pxor xmm6,xmm6		
; pxor xmm7,xmm7		
; pxor xmm8,xmm8		
; pxor xmm9,xmm9		
; pxor xmm10,xmm10	
; pxor xmm11,xmm11	
; pxor xmm12,xmm12	
; pxor xmm13,xmm13	
; pxor xmm14,xmm14	
; .ciclo:
	
; 	cmp r12,r14
; 	je .fin
; 	cmp r13,r15
; 	jge .cambioFila

; 	mov r9,r12  ;meto la fila en la que estoy laburando
; 	imul r9,rcx ;indiceFila * #columnas
; 	shl r9,2 ;fila*cols*4
; 	mov rdx, r13
; 	shl rdx, 2 ;j*4
; 	add r9,rdx ;(fila*cols*4)+(j*4)
; 	;[rsi+r9] 4 pixeles a laburar
; 	movdqu xmm0,[rsi+r9]; meto los 4 pxs, quiero laburar con 1 solo
; 	mov r8,-2
; 	.cicloVecinosExterior:
; 		cmp r8,2
; 		jg .finVecExterior
; 		mov r11,-2
; 		.cicloVecinosInterior:
; 			cmp r11,2
; 			jg .finVecInterior
; 			mov r9,r12 ;meto i
; 			add r9,r8 ; i + iaux =filaNueva
; 			imul r9,rcx; (filaNueva)*cols
; 			shl r9,2 ; filaNueva*cols*4
; 			mov rdx,r13; meto el j
; 			add rdx,r11;j+jaux =ColNueva
; 			shl rdx,2 ;ColNueva*4
; 			add r9,rdx

; 			;levanto esos 4 del source
; 			movdqu xmm0,[rdi+r9]
; 			movdqu xmm1,xmm0 ;[a r g b a r g b a r g b a r g b]
; 			movdqu xmm2,xmm0
; 			pslld xmm1,24
; 			psrld xmm1,24 ;[000b 000b 000b 000b]

; 			pslld xmm2,8
; 			psrld xmm2,24 ;[000r000r000r000r]

; 			pslld xmm0,16
; 			psrld xmm0,24

; 			paddd xmm0,xmm1
; 			paddd xmm0,xmm2



; 			cmp r11,-2
; 			je .sonDeLasPrimeras4Cols
; 			jmp .sonDeLasSegundas4Cols

; 			.sonDeLasPrimeras4Cols:

; 			paddd xmm13,xmm0
; 			add r11,4

; 			jmp .cicloVecinosInterior

; 			.sonDeLasSegundas4Cols:

; 			paddd xmm14,xmm0
; 			add r11,4
; 			jmp .cicloVecinosInterior


; 	.finVecExterior:
; 		mov r9,r12  ;meto la fila en la que estoy laburando
; 		mov rax,rcx
; 		mul r9
; 		;imul r9,rcx ;indiceFila * #columnas
; 		mov r9,rax
; 		shl r9,2 ;fila*cols*4
; 		mov rdx, r13
; 		shl rdx, 2 ;j*4
; 		add r9,rdx ;(fila*cols*4)+(j*4)
; 		movdqu xmm0, [rdi+r9] ;con la cuenta saque la posicion de los 4 que voy a modificar
		
; 		movdqu xmm2,xmm0
; 		punpcklbw xmm0,xmm15
; 		punpckhbw xmm2,xmm15
; 		movdqu xmm3,xmm2
; 		movdqu xmm1,xmm0

; 		punpcklwd xmm0,xmm15 ; p0 
; 		punpckhwd xmm1,xmm15 ; p1 
; 		punpcklwd xmm2,xmm15 ; p2-
; 		punpckhwd xmm3,xmm15 ; p3-


; 		movdqu xmm4,xmm13
; 		movdqu xmm6,xmm13
; 		punpckldq xmm4,xmm15
; 		punpckhdq xmm6,xmm15


; 		movdqu xmm5,xmm4
; 		movdqu xmm7,xmm6

; 		punpcklqdq xmm4,xmm15 ;SUMA COL 0
; 		punpckhqdq xmm5,xmm15 ;SUMA COL 1
; 		punpcklqdq xmm6,xmm15 ;SUMA COL 2
; 		punpckhqdq xmm7,xmm15 ;SUMA COL 3

; 		movdqu xmm8,xmm14
; 		movdqu xmm10,xmm14
; 		punpckldq xmm8,xmm15
; 		punpckhdq xmm10,xmm15

; 		movdqu xmm9,xmm8
; 		movdqu xmm11,xmm10

; 		punpcklqdq xmm8,xmm15 ;SUMA COL 4
; 		punpckhqdq xmm9,xmm15 ;SUMA COL 5
; 		punpcklqdq xmm10,xmm15 ;SUMA COL 6
; 		punpckhqdq xmm11,xmm15 ;SUMA COL 7


 
; 		;Pixel 0(col0 a col4)
; 		pxor xmm13,xmm13
; 		paddd xmm13,xmm4
; 		paddd xmm13,xmm5
; 		paddd xmm13,xmm6
; 		paddd xmm13,xmm7
; 		paddd xmm13,xmm8
; 		pshufd xmm13,xmm13, 00000000b

; 		movdqu xmm12,xmm0
; 		movdqu xmm14,xmm0
; 		pmuludq xmm12,xmm13
; 		pshufd xmm14, xmm14, 10010011b
; 		pmuludq xmm14,xmm13
; 		pshufd xmm14, xmm14, 00111001b
; 		paddd xmm12,xmm14

; 		movd xmm13,r10d;meto el alpha
; 		pshufd xmm13, xmm13, 11000000b
; 		cvtdq2ps xmm13,xmm13
; 		cvtdq2ps xmm12,xmm12
; 		mulps xmm12, xmm13
; 		movdqu xmm13,[maximo]
; 		divps xmm12,xmm13
; 		cvtps2dq xmm12,xmm12
; 		paddq xmm0,xmm12



; 		;Pixel 1(col1 a col5)
; 		pxor xmm13,xmm13
; 		paddd xmm13,xmm5
; 		paddd xmm13,xmm6
; 		paddd xmm13,xmm7
; 		paddd xmm13,xmm8
; 		paddd xmm13,xmm9
; 		pshufd xmm13,xmm13, 00000000b

; 		movdqu xmm12,xmm1
; 		movdqu xmm14,xmm1
; 		pmuludq xmm12,xmm13
; 		pshufd xmm14, xmm14, 10010011b
; 		pmuludq xmm14,xmm13
; 		pshufd xmm14, xmm14, 00111001b
; 		paddd xmm12,xmm14
; 		movd xmm13,r10d;meto el alpha
; 		pshufd xmm13, xmm13, 11000000b;meto el alpha
; 		cvtdq2ps xmm13,xmm13
; 		cvtdq2ps xmm12,xmm12
; 		mulps xmm12, xmm13
; 		movdqu xmm13,[maximo]
; 		divps xmm12,xmm13
; 		cvtps2dq xmm12,xmm12
; 		paddq xmm1,xmm12

		

; 		;Pixel 2
; 		pxor xmm13,xmm13
; 		paddd xmm13,xmm6
; 		paddd xmm13,xmm7
; 		paddd xmm13,xmm8
; 		paddd xmm13,xmm9
; 		paddd xmm13,xmm10

; 		pshufd xmm13,xmm13, 00000000b

; 		movdqu xmm12,xmm2
; 		movdqu xmm14,xmm2
; 		pmuludq xmm12,xmm13
; 		pshufd xmm14, xmm14, 10010011b
; 		pmuludq xmm14,xmm13
; 		pshufd xmm14, xmm14, 00111001b
; 		paddd xmm12,xmm14

; 		movd xmm13,r10d;meto el alpha
; 		pshufd xmm13, xmm13, 11000000b;meto el alpha
; 		cvtdq2ps xmm13,xmm13
; 		cvtdq2ps xmm12,xmm12
; 		mulps xmm12, xmm13
; 		movdqu xmm13,[maximo]
; 		divps xmm12,xmm13
; 		cvtps2dq xmm12,xmm12
; 		paddq xmm2,xmm12

		

; 		;Pixel 3
; 		pxor xmm13,xmm13
; 		paddd xmm13,xmm7
; 		paddd xmm13,xmm8
; 		paddd xmm13,xmm9
; 		paddd xmm13,xmm10
; 		paddd xmm13,xmm11

; 		pshufd xmm13,xmm13, 00000000b

; 		movdqu xmm12,xmm3
; 		movdqu xmm14,xmm3
; 		pmuludq xmm12,xmm13
; 		pshufd xmm14, xmm14, 10010011b
; 		pmuludq xmm14,xmm13
; 		pshufd xmm14, xmm14, 00111001b
; 		paddd xmm12,xmm14

; 		movd xmm13,r10d;meto el alpha
; 		pshufd xmm13, xmm13, 11000000b;meto el alpha
; 		cvtdq2ps xmm13,xmm13
; 		cvtdq2ps xmm12,xmm12
; 		mulps xmm12, xmm13
; 		movdqu xmm13,[maximo]
; 		divps xmm12,xmm13
; 		cvtps2dq xmm12,xmm12
; 		paddq xmm3,xmm12








; 		;despues de laburar los 4 empaqueto
; 		packusdw xmm0,xmm1
; 	  	packusdw xmm2,xmm3
; 	  	packuswb xmm0,xmm2
; 		movdqu[rsi+r9],xmm0
; 		jmp .volverACiclo


; 	.finVecInterior:
; 	inc r8
; 	mov r11,-2
; 	jmp .cicloVecinosExterior



; 	.volverACiclo:
; 	add r13,4
; 	pxor xmm14,xmm14
; 	pxor xmm13,xmm13
; 	jmp .ciclo

; 	.cambioFila:
; 	inc r12
; 	mov r13,2
; 	jmp .ciclo


; .fin:
; pop r15
; pop r14
; pop r13
; pop r12
; pop rbp
; ret