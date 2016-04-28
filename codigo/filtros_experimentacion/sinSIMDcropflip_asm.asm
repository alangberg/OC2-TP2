global cropflip_asm

 %define i r12
 %define j r13
 %define TAM_X [rbp + 16]
 %define TAM_Y [rbp + 24]
 %define OFFSET_X [rbp + 32]
 %define OFFSET_Y [rbp + 40]
 %define SRC rdi
 %define DST rsi
 %define COLS rdx
 %define FILAS rcx



section .text
;void cropflip_asm(unsigned char *src,
;                  unsigned char *dst,
;		           int cols, int filas,
;                  int src_row_size,
;                  int dst_row_size,
;                  int tamx, int tamy,
;                  int offsetx, int offsety);

cropflip_asm:
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
 	mov rbx, COLS
 	xor i, i

		.cicloFilas:
 		xor j, j
 		.cicloColumnas:
 		; bgra_t *p_s = (bgra_t*) &src_matrix[tamy+offsety-i-1][(offsetx+j) * 4];

 		mov rdi, r14
 		mov esi, TAM_Y
 		add esi, OFFSET_Y
 		sub rsi, i
 		dec rsi

 		mov edx, OFFSET_X
 		add rdx, j
 
 		mov rcx, rbx
 		call matriz

 		mov r8, rax

 		mov rdi, r15
 		mov rsi, i
 		mov rdx, j
 		mov ecx, TAM_X

 		call matriz

 		mov rsi, rax
 		mov rdi, r8

 		call copiarPixeles

 		add j, 1
 		cmp r13d, TAM_X
 		jne .cicloColumnas

 	inc i
 	cmp r12d, TAM_Y
 	jne .cicloFilas


 	add rsp, 8
 	pop rbx
 	pop r15
 	pop r14
 	pop r13
 	pop r12
 	pop rbp
 	ret

; void copiarPixeles(bgra_t* p_s, bgra_t* p_d)
copiarPixeles:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	
	xor r12, r12
	xor r13, r13
	.ciclo:
		mov r12b, [rdi + r13]
		mov [rsi + r13], r12b

		inc r13
		cmp r13, 4
	jne .ciclo

	pop r13
	pop r12
	pop rbp
ret

; void multiplicar(int a, int b)
multiplicar:
	push rbp
	mov rbp, rsp
	push r12
	sub rsp, 8

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
	add rsp, 8
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