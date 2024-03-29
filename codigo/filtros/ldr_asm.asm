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


	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
ret

