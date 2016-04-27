section .data
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
;COMPLETAR
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp, 8

	xor i, i	; r12 = i + Offset_y = Offset_y


	mov r14, COLS
	mov rbx, FILAS
	mov r15, DST

	.ciclo_filas:
		xor j, j	; r13 = j + Offset_x = Offset_x
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
	.ciclo:

		; no hace nada pero aca habria que hacer la cuenta loca

		inc r13
		cmp r13, 4
	jne .ciclo

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

;pixel* matriz(matriz*, int i, int j, int #filas)
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