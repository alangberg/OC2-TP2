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

	mov rdi, r14
	xor rsi, rsi
	mov esi, TAM_Y
	add esi, OFFSET_Y
	dec rsi

	xor rdx, rdx
	mov edx, OFFSET_X
	
	mov rcx, rbx
	
		mov r12, rdi
		mov rdi, rcx
		
		mov rax, rdi
		imul rax, rsi
		
		add rax, rdx

		lea rax, [r12 + rax*4]

	mov r14, rax
	mov rbx, rax

	xor rcx, rcx
 	mov ecx, TAM_Y

 	xor r13, r13
 	xor r12, r12
 	mov r12d, TAM_X

 	.ciclo:

		movdqu xmm0, [rbx]	; copio los 4 pixeles
		movdqu [r15], xmm0	; 
	 					
	 					; adelante 4 pixeles a los dos punteros
	 	add rbx, 4*4	; SRC += 4p
	 	add r15, 4*4	; DST += 4p

	 	add r13, 4		; al contador de la fila le sumo 4
	 	cmp r13d, r12d	; comparo para ver si se me terminaron las columnas

	 	jne .fin

		 	sub r14, r8	; si se termino pongo el puntero al principio de la fila una mas abajo

		 	mov rbx, r14	; actualizo rbx q es el reg q uso en el ciclo
		 	xor r13, r13	; limpio el contador de columnas
	 		dec rcx			; dec el contador de las filas

 	.fin:
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

