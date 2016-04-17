section .rodata
	val0503: dq 0.5, 0.3
	val02: dq 0.2

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

			inc j
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

	movd xmm0, [rdi]			; pongo en xmm0 los 32b del pixel (RGBA)

	punpcklbw xmm0, xmm7		; separo los numeros asi si alguno se pasa de 255 no me pisa el siguiente

								; aca arranco la sumatoria de R + G + B. Lo que me importa es el 1er numero en xmm0, ahi va a estar el resultado
	movups xmm1, xmm0			; copio en xmm0 en xmm1 R | G | B | A

	psrldq xmm1, 2				; shifteo xmm1, G | B | A

	addps xmm0, xmm1			; xmm0 R + G | G | B | A
	psrldq xmm1, 2				; shifteo xmm1, B | A
	addps xmm0, xmm1			; xmm0 R + G + B | G | B | A

	movups xmm1, xmm0			; copio el resultado en xmm1
	mov r12, 0xFFFF
	movq xmm7, r12
	pand xmm1, xmm7				; y pongo todo el resto del registro en 0

	movups xmm0, xmm1
	pslldq xmm1, 2
	paddw xmm0, xmm1
	pslldq xmm1, 2
	paddw xmm0, xmm1			; lo que hice aca es hacer que xmm0 sea SUMA | SUMA | SUMA

	movdqu xmm7, [val0503]		; esto es para que xmm7 sea 0.5 | 0.3 (lo saque de la ultima clase, creo q entran dos numeros FP por registro)

								; hasta aca llego mi amor

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