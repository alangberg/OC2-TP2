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

	; bgra_t *p_s = (bgra_t*) &src_matrix[tamy+offsety-i-1][(offsetx+j) * 4];
	; X . . .
	; . . . .
	; . . . .
	; . . . .
	; 

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



;  	; .cicloFilas:
;  	; 	xor j, j
;  	; 	.cicloColumnas:
;  	; 	; bgra_t *p_s = (bgra_t*) &src_matrix[tamy+offsety-i-1][(offsetx+j) * 4];

;  	; 	mov rdi, r14
;  	; 	mov esi, TAM_Y
;  	; 	add esi, OFFSET_Y
;  	; 	sub rsi, i
;  	; 	dec rsi

;  	; 	mov edx, OFFSET_X
;  	; 	add rdx, j
 
;  	; 	mov rcx, rbx
;  	; 	call matriz

;  	; 	mov r8, rax

;  	; 	mov rdi, r15
;  	; 	mov rsi, i
;  	; 	mov rdx, j
;  	; 	mov ecx, TAM_X

;  	; 	call matriz

;  	; 	mov rsi, rax
;  	; 	mov rdi, r8

;  	; 	call 0x7fffffffd970

;  	; 	add j, 4
;  	; 	cmp r13d, TAM_X
;  	; 	jne .cicloColumnas

;  	; inc i
;  	; cmp r12d, TAM_Y
;  	; jne .cicloFilas

;  %define tam_4pxs 16
; section .data
; global cropflip_asm

; section .text
; ;void cropflip_asm(unsigned char *src,  unsigned char *dst, int cols, int filas, int src_row_size, int dst_row_size, int tamx, int tamy, int offsetx, int offsety);
; ; 						RDI,      					RSI,     RDX ,     RCX,        R8,             R9

;  cropflip_asm:
; push rbp
; mov rbp, rsp
; push r12
; push r13
; push r14
; push r15


; pxor xmm0, xmm0
; pxor xmm7, xmm7
; xor rcx, rcx
; xor r8, r8
; xor r9, r9
; xor rax, rax
; xor r10, r10 ; indice "i" fuente
; xor r11, r11  ; indice "j" fuente
; xor r14, r14
; xor r15, r15
; mov r9d, [rbp+16]  ;tamX
; mov r14d, [rbp+24]  ; tamY
; mov r15d, [rbp+32]  ; offsetX
; mov eax, [rbp+40]  ;offsetY
; mov r8d, r14d ; TIENE TAMY
; ; “puntero al inicio de la matriz” + “cantidad elementos de la fila” * “indice de fila” * “tamaño dato” ++ “indice de columna” * “tamano dato”
; .ciclo:

; 	cmp r10, r14  ; si el indice de la fila = tamy
; 	je .fin
	
; 	cmp r11, r9 ;veo si r11 llego al tope de la fila
; 	jge .cambioFila

; 	add r14, rax 	;tamy + off
; 	sub r14, r10	;tamy + off - i
; 	dec r14			;tamy + off -i -1
; 	mov r12, rax
; 	mov rax, rdx
; 	imul r14, rdx;((tamy + off -i -1)*cols + (ox+j))*4
; 	mov rax, r12

; 	add r15, r11	;ox+j
; 	add r14, r15;
; 	movdqu xmm0, [rdi+r14*4]  ;agarre los 4 que tengo que mover a destino
	
; 	mov r14, r8
; 	sub r15, r11
	

; 	movdqu [rsi], xmm0
; 	lea rsi, [rsi+tam_4pxs]


; 	add r11, 4
; 	jmp .ciclo

; 	.cambioFila
; 	inc r10
; 	mov r11, 0
; 	jmp .ciclo

; .fin:
; pop r15
; pop r14
; pop r13
; pop r12
; pop rbp
; ret