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
	pxor xmm1, xmm1				; pongo todos estos registros en 0
	pxor xmm7, xmm7

	movdqa xmm0, [rdi]			; pongo en xmm0 los 128b de los 4 pixeles

	movdqu xmm8, xmm0

	punpcklbw xmm0, xmm7		; xmm0 = 0 | a7 | . . . | 0 | a0
	punpckhbw xmm8, xmm7		; xmm1 = 0 | a15 | . . . | 0 | a8

	call sepiaEnDosPixeles
	movups xmm9, xmm0

	movups xmm0, xmm8
	call sepiaEnDosPixeles
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


sepiaEnDosPixeles:				; asumo que en xmm0 tengo los dos pixeles desenpaquetados
								; aca arranco la sumatoria de R + G + B. Lo que me importa es el 1er numero en xmm0, ahi va a estar el resultado
	movups xmm1, xmm0			; copio en xmm0 en xmm1 R | G | B | A

	psrldq xmm1, 2				; shifteo xmm1, G | B | A

	addpd xmm0, xmm1			; xmm0 R + G | G | B | A
	psrldq xmm1, 2				; shifteo xmm1, B | A
	addpd xmm0, xmm1			; xmm0 R + G + B | G | B | A

	movups xmm1, xmm0			; copio el resultado en xmm1
	mov r12, 0xFFFF000000000000FFFF
	movq xmm7, r12
	pand xmm1, xmm7				; y pongo todo el resto del registro en 0

	movups xmm0, xmm1
	pslldq xmm1, 2
	paddw xmm0, xmm1
	pslldq xmm1, 2
	paddw xmm0, xmm1			; lo que hice aca es hacer que xmm0 sea SUMA | SUMA | SUMA | .

	pxor xmm7, xmm7
	movupd xmm7, [val050302]		; esto es para que xmm7 sea 0.5 | 0.3 | 0.2 (lo saque de la ultima clase, creo q entran dos numeros FP por registro)
	pxor xmm1, xmm1

	movups xmm3, xmm0
	psrldq xmm3, 3


	punpcklwd xmm0, xmm1
	pxor xmm2, xmm2
	
	CVTDQ2PS xmm2, xmm0
	mulps xmm2, xmm7	

	pxor xmm7, xmm7
	CVTPS2DQ xmm7, xmm2

	packusdw xmm7, xmm2
	packuswb xmm7, xmm2

	movups xmm0, xmm7			; aca tengo el valor final de todo


	pxor xmm1, xmm1
	pxor xmm7, xmm7
	movupd xmm7, [val050302]

	punpcklwd xmm3, xmm1
	pxor xmm2, xmm2
	
	CVTDQ2PS xmm2, xmm3
	mulps xmm2, xmm7	

	pxor xmm7, xmm7
	CVTPS2DQ xmm7, xmm2

	packusdw xmm7, xmm2
	packuswb xmm7, xmm2

	movups xmm1, xmm7

	packuswb xmm0, xmm1

	mov r12, 0xFFFFFFFFFFFFFFFF		; me guardo los primeros 8 numeros (bytes) el resto esta en 0
	movq xmm1, r12
	pand xmm0, xmm1
ret