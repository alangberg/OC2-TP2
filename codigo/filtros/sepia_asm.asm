section .rodata
	val050302: dd 0.2, 0.3, 0.5

DEFAULT REL

section .text
global sepia_asm


 %define i r12
 %define j r13
 %define SRC rdi
 %define DST rsi
 %define COLS rdx
 %define FILAS rcx

sepia_asm:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp, 8

	xor i, i	; r12 = i = 0


	mov r14, COLS
	mov rbx, FILAS
	mov r15, DST

	.ciclo_filas:
		xor j, j	; r13 = j = 0
		.ciclo_columnas:
			mov rdi, r15
			mov rsi, i
			mov rdx, j
			mov rcx, r14

			call matriz
			mov rdi, rax

			call aplicarSepia

			add j, 4
			cmp j, r14
		jne .ciclo_columnas

		inc i
		cmp i, rbx
	jne .ciclo_filas

	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
ret

aplicarSepia:
	push rbp
	mov rbp, rsp
	push r13
	push r12

	xor r12, r12
	xor r13, r13

	pxor xmm0, xmm0
	pxor xmm1, xmm1					; pongo todos estos registros en 0
	pxor xmm7, xmm7

	movdqa xmm0, [rdi]			; pongo en xmm0 los 128b de los 4 pixeles - xmm0 = p0 | p1 | p2 | p3

	movdqu xmm8, xmm0				; xmm8 = p0 | p1 | p2 | p3

	punpcklbw xmm0, xmm7		; xmm0 = 0 | a7 | . . . | 0 | a0
	punpckhbw xmm8, xmm7		; xmm1 = 0 | a15 | . . . | 0 | a8

	call sepiaEnDosPixeles 	; xmm0 = pix0Final | pix1Final | 0 | 0
	movups xmm9, xmm0           

	movups xmm0, xmm8
	call sepiaEnDosPixeles  ; xmm0 = pix2Final | pix3Final | 0 | 0
	pslldq xmm0, 3

	addpd xmm0, xmm9

	movdqa [rdi], xmm0

	pop r12
	pop r13
	pop rbp
ret

; void multiplicar(int a, int b)
multiplicar:
	push rbp
	mov rbp, rsp
	push r12

	xor rax, rax
	cmp rsi, 0
	je .fin

	cmp rdi, 0
	je .fin

	xor r12, r12

	.ciclo:
		add rax, rdi		
		inc r12
		cmp r12, rsi
	jne .ciclo

	.fin:
	pop r12
	pop rbp
ret

;pixel* matriz(matriz*, int i, int j, int #columnas)
matriz:
	push rbp
	mov rbp, rsp
	push r12
	sub rsp, 8

	mov r12, rdi
	mov rdi, rcx

	call multiplicar

	add rax, rdx

	lea rax, [r12 + rax*4]

	add rsp, 8
	pop r12
	pop rbp
ret


sepiaEnDosPixeles:					; asumo que en xmm0 tengo los dos pixeles desenpaquetados
														; aca arranco la sumatoria de R + G + B. Lo que me importa es el 1er numero en xmm0, ahi va a estar el resultado
	movups xmm1, xmm0					; xmm0 = R0 | G0 | B0 | A0 | R1 | G1 | B1 | A1
														; xmm1 = R0 | G0 | B0 | A0 | R1 | G1 | B1 | A1
							    
	psrldq xmm1, 2						; shifteo xmm1 =  G0 | B0 | A0 | R1 | G1 | B1 | A1 | .

	addps xmm0, xmm1					; xmm0 = R0+G0 | . | . | . | R1+G1 | . | . | .

	psrldq xmm1, 2						; shifteo xmm1 = B0 | A0 | R1 | G1 | B1 | A1 | . | .
	addps xmm0, xmm1					; xmm0 = R0+G0+B0 | . | . | . | R1+G1+B1 | . | . | .

	pxor xmm7, xmm7
	mov r12, 0xFFFF 					; mascara para setear todo en 0 menos las sumas. 
	movq xmm7, r12						; xmm7 = 1 0 0 0 0 0 0 0
	movups xmm8, xmm7					; xmm8 = 1 0 0 0 0 0 0 0
	pslldq xmm7, 8						; xmm7 = 0 0 0 0 1 0 0 0
	addps xmm7, xmm8					; xmm7 = 1 0 0 0 1 0 0 0							
	pand xmm0, xmm7						; xmm0 = R0+G0+B0 | 0 | 0 | 0 | R1+G1+B1 | 0 | 0 | 0
	movups xmm1, xmm0					; xmm1 = R0+G0+B0 | 0 | 0 | 0 | R1+G1+B1 | 0 | 0 | 0

	pslldq xmm0, 2				
	paddw xmm0, xmm1
	pslldq xmm1, 2
	paddw xmm0, xmm1					; xmm0 = SUMA0 | SUMA0 | SUMA0 | 0 | SUMA1 | SUMA1 | SUMA1 | 0

	pxor xmm7, xmm7
	movupd xmm7, [val050302]	; xmm7 = 0.5 | 0.3 | 0.2
	pxor xmm1, xmm1						

	movups xmm3, xmm0					; xmm3 = SUMA0 | SUMA0 | SUMA0 | 0 | SUMA1 | SUMA1 | SUMA1 | 0 |
	psrldq xmm3, 3						; xmm3 = SUMA1 | SUMA1 | SUMA1 | . | . | . | . | . |


	punpcklwd xmm0, xmm1			; xmm0 = SUMA0 | SUMA0 | SUMA0 | .	
	pxor xmm2, xmm2						
	
	CVTDQ2PS xmm2, xmm0				; xmm2 = SUMA0 | SUMA0 | SUMA0 | . donde SUMA0 es FLOAT.
	mulps xmm2, xmm7					; xmm2 = SUMA0*0.5 | SUMA0*0.3 | SUMA0*0.2 | .

	pxor xmm7, xmm7
	CVTPS2DQ xmm7, xmm2				; xmm7 = SUMA0*0.5 | SUMA0*0.3 | SUMA0*0.2 | . donde son todos ENTEROS (tam double).

	packusdw xmm7, xmm2				; doubles -> words
	;packuswb xmm7, xmm2				; words -> bytes (con saturacion)

	movups xmm0, xmm7					; xmm0 <- final(pix0 y pix1)


	pxor xmm1, xmm1
	pxor xmm7, xmm7
	movupd xmm7, [val050302]  ; xmm7 = 0.5 | 0.3 | 0.2 

	punpcklwd xmm3, xmm1			; xmm3 = SUMA1 | SUMA1 | SUMA1 | .
	pxor xmm2, xmm2
	
	CVTDQ2PS xmm2, xmm3				; xmm3 = SUMA1 | SUMA1 | SUMA1 | . donde SUMA1 es FLOAT.
	mulps xmm2, xmm7					; xmm2 = SUMA1*0.5 | SUMA1*0.3 | SUMA1*0.2 | .

	pxor xmm7, xmm7						
	CVTPS2DQ xmm7, xmm2				; xmm7 = SUMA1*0.5 | SUMA1*0.3 | SUMA1*0.2 | . donde son todos ENTEROS (tam double).

	packusdw xmm7, xmm2				; doubles -> words
	;packuswb xmm7, xmm2				; words -> bytes

	movups xmm1, xmm7					; xmm1 <- final (pix2 y pix3)

	packuswb xmm0, xmm1				; xmm0 = pix0 | pix1 | . | .

	mov r12, 0xFFFFFFFFFFFFFFFF		; me guardo los primeros 8 numeros (bytes) el resto esta en 0
	movq xmm1, r12
	pand xmm0, xmm1
ret