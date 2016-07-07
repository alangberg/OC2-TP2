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


;pixel* matriz(matriz*, int i, int j, int #columnas)
%macro matriz 0
	mov r12, rdi
	mov rdi, rcx
	
	mov rax, rdi
	imul rax, rsi
	
	add rax, rdx

	lea rax, [r12 + rax*4]
%endmacro


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

	; bgra_t *p_s = (bgra_t*) &src_matrix[tamy+offsety-i-1][(offsetx+j) * 4];
	; X . . .
	; . . . .
	; . . . .
	; . . . .
	; 


	mov rdi, r14
	mov esi, TAM_Y
	add esi, OFFSET_Y
	dec rsi

	mov edx, OFFSET_X
	
	mov rcx, rbx
	matriz

	mov r14, rax
	mov rbx, rax

 	; Uso loop, rcx = tam_x . tam_y
 	mov rsi, TAM_X
 	mov rcx, TAM_Y
 	imul rcx, rsi

 	xor r12, r12
 	xor r13, r13

 	.ciclo:

		movdqu xmm0, [rbx]
		movdqu [r15], xmm0
	 	
	 	add rbx, 16
	 	add r15, 16
	 	sub rcx, 3

	 	add r13, 4
	 	cmp r13, 300 ; pongo 300 porq se q es ese valor lo ideal es poner el src_row_size
	 	
	 	jne .fin

		 	sub r14, 512*4
		 	mov rbx, r14
		 	xor r13, r13

 	.fin
 	loop .ciclo





 	; .cicloFilas:
 	; 	xor j, j
 	; 	.cicloColumnas:
 	; 	; bgra_t *p_s = (bgra_t*) &src_matrix[tamy+offsety-i-1][(offsetx+j) * 4];

 	; 	mov rdi, r14
 	; 	mov esi, TAM_Y
 	; 	add esi, OFFSET_Y
 	; 	sub rsi, i
 	; 	dec rsi

 	; 	mov edx, OFFSET_X
 	; 	add rdx, j
 
 	; 	mov rcx, rbx
 	; 	call matriz

 	; 	mov r8, rax

 	; 	mov rdi, r15
 	; 	mov rsi, i
 	; 	mov rdx, j
 	; 	mov ecx, TAM_X

 	; 	call matriz

 	; 	mov rsi, rax
 	; 	mov rdi, r8

 	; 	call copiarPixeles

 	; 	add j, 4
 	; 	cmp r13d, TAM_X
 	; 	jne .cicloColumnas

 	; inc i
 	; cmp r12d, TAM_Y
 	; jne .cicloFilas


 	add rsp, 8
 	pop rbx
 	pop r15
 	pop r14
 	pop r13
 	pop r12
 	pop rbp
ret
