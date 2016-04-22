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

	xor i, i	; r12 = i + Offset_y = Offset_y


	mov r14, SRC
	mov r15, DST

	.ciclo_filas:
		xor j, j	; r13 = j + Offset_x = Offset_x
		.ciclo_columnas:

			mov r10, COLS ;Muevo columnas
			mov rdi, r15 ;Muevo DST*
			mov rsi, i ; i = Fila del pixel
			add esi, OFFSET_Y ;i = i + Offset_y
			mov rdx, j ;j = Columna del pixel
			add edx, OFFSET_X ; j = j + Offset_x
			mov rcx, r10

			call matriz

			mov rbx, rax
			
			xor rsi, rsi
			xor rdx, rdx
			mov rdi, r14
			mov esi, OFFSET_Y
			add esi, TAM_Y
			sub rsi, i
			dec rsi
			mov rdx, j
			add edx, OFFSET_X
			mov rcx, r10
			call matriz

			mov rdi, rax
			mov rsi, rbx

			call copiarPixeles

			mov rdi, r15
			mov rsi, TAM_Y
			dec rsi
			sub rsi, i			
			mov rdx, j
			mov rcx, TAM_X
			call matriz

			mov rbx, rax

			mov rdi, r14
			mov rsi, OFFSET_Y
			add rsi, i
			mov rdx, j
			add rdx, OFFSET_X
			mov rcx, r10
			call matriz

			mov rdi, rax
			mov rsi, rbx

			call copiarPixeles

			inc j
			cmp j, TAM_X
		jne .ciclo_columnas

		inc i
		cmp i, TAM_Y
	jne .ciclo_filas

	add rsp, 8
	pop r12
	pop r13
	pop r14
	pop r15
	pop rbx
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