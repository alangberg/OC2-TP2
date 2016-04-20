
global ldr_asm

 %define i r12
 %define j r13
 %define SRC rdi
 %define DST rsi
 %define COLS rdx
 %define FILAS rcx

section .data

section .text
;void ldr_asm    (
	;unsigned char *src,
	;unsigned char *dst,
	;int filas,
	;int cols,
	;int src_row_size,
	;int dst_row_size,
	;int alpha)

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
	mov rbx, r8

	mov r10, COLS
	mov r11, FILAS

	xor i, i	; r12 = i = 0
	mov i, 2	; i = 2
	sub FILAS, 2
	sub COLS, 2

	.ciclo_filas:
		xor j, j	; r13 = j = 0
		mov j, 2	; j = 2
		
		.ciclo_columnas:

			mov rdi, r14
			mov rsi, i
			mov rcx, j
			mov rdx, r10

			call matriz 

			mov rdi, rax
			mov rsi, rbx

			call aplicarFiltroldr

			inc j
			cmp j, COLS
		jne .ciclo_columnas

		inc i
		cmp i, FILAS
	jne .ciclo_filas

	add rsp, 8
	pop r12
	pop r13
	pop r14
	pop r15
	pop rbx
	pop rbp
ret


;aplicarFiltroldr(src_rgba_t*, src_row_size)
aplicarFiltroldr:

	lea rdx, [rdi - 8]					; rdx <- I(i,j-2)
	mov r9, rsi 								
	add r9, r9                  ; r9 <- src_row_size*2 

	sub rdx, r9 								; rdx <- I(i-2,j-2)
	
	xor r8, r8
	pxor xmm14, xmm14

	.ciclo:
		movdqu xmm0, [rdx]				; pongo en xmm0 los 128b de los 4 pixeles - xmm0 = p[i-2,j-2] | p[i-2,j-1] | p[i-2,j] | p[i-2,j+1] 

		pxor xmm7, xmm7
		movdqu xmm15, xmm0				; xmm15 = p0 | p1 | p2 | p3

		punpcklbw xmm0, xmm7			; xmm0 = 0 | a7 | . . . | 0 | a0
		punpckhbw xmm15, xmm7			; xmm15 = 0 | a15 | . . . | 0 | a8

		call sumarPixeles
		paddd xmm14, xmm0					; xmm14 = R0+G0+B0 + R1+G1+B1 | 0 | 0 | 0 | 0 | 0 | 0 | 0

		movups xmm0, xmm15
		call sumarPixeles
		paddd xmm14, xmm0					; sumo el resultado en xmm14 (ojo! porq esta en dw) xmm14 = sumaP0 + .. + sumaP3  | 0 | 0 | 0

		add rdx, rsi

		inc r8
		cmp r8, 5
	jne .ciclo

	xor r8, r8

	lea rdx, [rdi + 8]					
	sub rdx, r9									; rdx <- I(i-2,j+2)

	.ciclo_2:
		movd xmm0, [rdx]					; pongo en xmm0 los 4Bytes del pixel - xmm0 = p[i+2,j-2] | . | . | .
		pxor xmm7, xmm7
		punpcklbw xmm0, xmm7			; xmm0 = 0 | a7 | . . . | 0 | a0
		call sumarPixel
		paddd xmm14, xmm0					; sumo el resultado en xmm14 (ojo! porq esta en dw) xmm14 = sumaP0 + .. + sumaP3  | 0 | 0 | 0

		add rdx, rsi

		inc r8
		cmp r8, 5
	jne .ciclo_2


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

;pixel* matriz(matriz*, int i, int j, int #filas)
matriz:
	push rbp
	mov rbp, rsp
	push r12
	sub rsp, 8

	mov r12, rdi
	mov rdi, rdx

	call multiplicar

	add rax, rcx

	lea rax, [r12 + rax*4]

	add rsp, 8
	pop r12
	pop rbp
ret

; Asumo que tengo los dos pixeles en xmm0 con los valores en word, lo que voy a hacer es R1+G2+B1 + R2+G2+B2 
sumarPixeles:

	movups xmm1, xmm0					; xmm0 = R0 | G0 | B0 | A0 | R1 | G1 | B1 | A1
								   					; xmm1 = R0 | G0 | B0 | A0 | R1 | G1 | B1 | A1
							    
	psrldq xmm1, 2						; shifteo xmm1 =  G0 | B0 | A0 | R1 | G1 | B1 | A1 | .

	paddw xmm0, xmm1					; xmm0 = R0+G0 | . | . | . | R1+G1 | . | . | .

	psrldq xmm1, 2						; shifteo xmm1 = B0 | A0 | R1 | G1 | B1 | A1 | . | .
	paddw xmm0, xmm1					; xmm0 = R0+G0+B0 | . | . | . | R1+G1+B1 | . | . | .

	pxor xmm7, xmm7
	mov r12, 0xFFFF 					; mascara para setear todo en 0 menos las sumas. 
	movq xmm7, r12						; xmm7 = 1 0 0 0 0 0 0 0
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
	mov r12, 0xFFFF 					; mascara para setear todo en 0 menos las sumas. 
	movq xmm7, r12						; xmm7 = 1 0 0 0 0 0 0 0
	pand xmm0, xmm7						; xmm0 = R0+G0+B0 + R1+G1+B1 | 0 | 0 | 0 | 0 | 0 | 0 | 0
ret

sumarPixel:
		movups xmm1, xmm0				; xmm1 = R0 | G0 | B0 | A0 | . | . | . | .
		psrldq xmm1, 2					; shifteo xmm1 =  G0 | B0 | A0 | . | . | . | . | .
		paddw xmm0, xmm1				; xmm0 = R0+G0 | . | . | . | . | . | . | .
		psrldq xmm1, 2					; shifteo xmm1 = B0 | A0 | . | . | . | . | . | .
		paddw xmm0, xmm1				; xmm0 = R0+G0+B0 | . | . | . | . | . | . | .
		
		pxor xmm7, xmm7
		mov r12, 0xFFFF 				; mascara para setear todo en 0 menos las sumas. 
		movq xmm7, r12					; xmm7 = 1 0 0 0 0 0 0 0
		pand xmm0, xmm7					; xmm0 = R0+G0+B0 | 0 | 0 | 0 | 0 | 0 | 0 | 0
ret


