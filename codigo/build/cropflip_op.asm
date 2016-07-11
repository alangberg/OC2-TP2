
cropflip_c.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <cropflip_c>:
   0:	41 57                	push   r15
   2:	41 56                	push   r14
   4:	41 55                	push   r13
   6:	41 54                	push   r12
   8:	55                   	push   rbp
   9:	53                   	push   rbx
   a:	44 8b 54 24 40       	mov    r10d,DWORD PTR [rsp+0x40]
   f:	8b 54 24 38          	mov    edx,DWORD PTR [rsp+0x38]
  13:	8b 4c 24 48          	mov    ecx,DWORD PTR [rsp+0x48]
  17:	45 85 d2             	test   r10d,r10d
  1a:	0f 8e 40 02 00 00    	jle    260 <cropflip_c+0x260>
  20:	44 8b 5c 24 50       	mov    r11d,DWORD PTR [rsp+0x50]
  25:	4d 63 c0             	movsxd r8,r8d
  28:	8d 04 8d 00 00 00 00 	lea    eax,[rcx*4+0x0]
  2f:	4d 63 e1             	movsxd r12,r9d
  32:	41 89 d1             	mov    r9d,edx
  35:	4c 63 f0             	movsxd r14,eax
  38:	41 c1 e9 02          	shr    r9d,0x2
  3c:	45 01 d3             	add    r11d,r10d
  3f:	4d 63 db             	movsxd r11,r11d
  42:	49 83 eb 01          	sub    r11,0x1
  46:	4d 0f af d8          	imul   r11,r8
  4a:	4b 8d 04 33          	lea    rax,[r11+r14*1]
  4e:	44 8d 5a ff          	lea    r11d,[rdx-0x1]
  52:	48 01 f8             	add    rax,rdi
  55:	42 8d 3c 8d 00 00 00 	lea    edi,[r9*4+0x0]
  5c:	00 
  5d:	48 89 44 24 e8       	mov    QWORD PTR [rsp-0x18],rax
  62:	8d 2c bd 00 00 00 00 	lea    ebp,[rdi*4+0x0]
  69:	89 fb                	mov    ebx,edi
  6b:	44 8d 3c 39          	lea    r15d,[rcx+rdi*1]
  6f:	83 c3 02             	add    ebx,0x2
  72:	48 63 c5             	movsxd rax,ebp
  75:	8d 6f 01             	lea    ebp,[rdi+0x1]
  78:	89 5c 24 d8          	mov    DWORD PTR [rsp-0x28],ebx
  7c:	48 89 44 24 e0       	mov    QWORD PTR [rsp-0x20],rax
  81:	41 c1 e7 02          	shl    r15d,0x2
  85:	44 8d 2c 29          	lea    r13d,[rcx+rbp*1]
  89:	89 6c 24 dc          	mov    DWORD PTR [rsp-0x24],ebp
  8d:	c1 e5 02             	shl    ebp,0x2
  90:	89 6c 24 bc          	mov    DWORD PTR [rsp-0x44],ebp
  94:	48 63 44 24 bc       	movsxd rax,DWORD PTR [rsp-0x44]
  99:	01 d9                	add    ecx,ebx
  9b:	8d 2c 8d 00 00 00 00 	lea    ebp,[rcx*4+0x0]
  a2:	c1 e3 02             	shl    ebx,0x2
  a5:	41 c1 e5 02          	shl    r13d,0x2
  a9:	31 c9                	xor    ecx,ecx
  ab:	4d 63 ff             	movsxd r15,r15d
  ae:	4d 63 ed             	movsxd r13,r13d
  b1:	44 89 4c 24 bc       	mov    DWORD PTR [rsp-0x44],r9d
  b6:	48 89 44 24 c0       	mov    QWORD PTR [rsp-0x40],rax
  bb:	48 63 c5             	movsxd rax,ebp
  be:	48 89 44 24 c8       	mov    QWORD PTR [rsp-0x38],rax
  c3:	48 63 c3             	movsxd rax,ebx
  c6:	48 89 44 24 d0       	mov    QWORD PTR [rsp-0x30],rax
  cb:	4a 8d 04 9d 04 00 00 	lea    rax,[r11*4+0x4]
  d2:	00 
  d3:	48 89 44 24 f0       	mov    QWORD PTR [rsp-0x10],rax
  d8:	48 8b 44 24 e8       	mov    rax,QWORD PTR [rsp-0x18]
  dd:	e9 ea 00 00 00       	jmp    1cc <cropflip_c+0x1cc>
  e2:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  e8:	83 fa 03             	cmp    edx,0x3
  eb:	0f 86 03 01 00 00    	jbe    1f4 <cropflip_c+0x1f4>
  f1:	85 ff                	test   edi,edi
  f3:	74 2f                	je     124 <cropflip_c+0x124>
  f5:	44 8b 4c 24 bc       	mov    r9d,DWORD PTR [rsp-0x44]
  fa:	45 31 db             	xor    r11d,r11d
  fd:	31 db                	xor    ebx,ebx
  ff:	f3 42 0f 6f 04 18    	movdqu xmm0,XMMWORD PTR [rax+r11*1]
 105:	83 c3 01             	add    ebx,0x1
 108:	f3 42 0f 7f 04 1e    	movdqu XMMWORD PTR [rsi+r11*1],xmm0
 10e:	49 83 c3 10          	add    r11,0x10
 112:	44 39 cb             	cmp    ebx,r9d
 115:	72 e8                	jb     ff <cropflip_c+0xff>
 117:	39 d7                	cmp    edi,edx
 119:	44 89 4c 24 bc       	mov    DWORD PTR [rsp-0x44],r9d
 11e:	0f 84 96 00 00 00    	je     1ba <cropflip_c+0x1ba>
 124:	4c 8b 4c 24 e0       	mov    r9,QWORD PTR [rsp-0x20]
 129:	4a 8d 5c 3d 00       	lea    rbx,[rbp+r15*1+0x0]
 12e:	3b 54 24 dc          	cmp    edx,DWORD PTR [rsp-0x24]
 132:	4e 8d 1c 0e          	lea    r11,[rsi+r9*1]
 136:	44 0f b6 0b          	movzx  r9d,BYTE PTR [rbx]
 13a:	45 88 0b             	mov    BYTE PTR [r11],r9b
 13d:	44 0f b6 4b 01       	movzx  r9d,BYTE PTR [rbx+0x1]
 142:	45 88 4b 01          	mov    BYTE PTR [r11+0x1],r9b
 146:	44 0f b6 4b 02       	movzx  r9d,BYTE PTR [rbx+0x2]
 14b:	0f b6 5b 03          	movzx  ebx,BYTE PTR [rbx+0x3]
 14f:	45 88 4b 02          	mov    BYTE PTR [r11+0x2],r9b
 153:	41 88 5b 03          	mov    BYTE PTR [r11+0x3],bl
 157:	7e 61                	jle    1ba <cropflip_c+0x1ba>
 159:	4a 8d 5c 2d 00       	lea    rbx,[rbp+r13*1+0x0]
 15e:	4c 8b 5c 24 c0       	mov    r11,QWORD PTR [rsp-0x40]
 163:	44 0f b6 0b          	movzx  r9d,BYTE PTR [rbx]
 167:	49 01 f3             	add    r11,rsi
 16a:	3b 54 24 d8          	cmp    edx,DWORD PTR [rsp-0x28]
 16e:	45 88 0b             	mov    BYTE PTR [r11],r9b
 171:	44 0f b6 4b 01       	movzx  r9d,BYTE PTR [rbx+0x1]
 176:	45 88 4b 01          	mov    BYTE PTR [r11+0x1],r9b
 17a:	44 0f b6 4b 02       	movzx  r9d,BYTE PTR [rbx+0x2]
 17f:	0f b6 5b 03          	movzx  ebx,BYTE PTR [rbx+0x3]
 183:	45 88 4b 02          	mov    BYTE PTR [r11+0x2],r9b
 187:	41 88 5b 03          	mov    BYTE PTR [r11+0x3],bl
 18b:	7e 2d                	jle    1ba <cropflip_c+0x1ba>
 18d:	48 03 6c 24 c8       	add    rbp,QWORD PTR [rsp-0x38]
 192:	48 8b 5c 24 d0       	mov    rbx,QWORD PTR [rsp-0x30]
 197:	4c 8d 1c 1e          	lea    r11,[rsi+rbx*1]
 19b:	0f b6 5d 00          	movzx  ebx,BYTE PTR [rbp+0x0]
 19f:	41 88 1b             	mov    BYTE PTR [r11],bl
 1a2:	0f b6 5d 01          	movzx  ebx,BYTE PTR [rbp+0x1]
 1a6:	41 88 5b 01          	mov    BYTE PTR [r11+0x1],bl
 1aa:	0f b6 5d 02          	movzx  ebx,BYTE PTR [rbp+0x2]
 1ae:	41 88 5b 02          	mov    BYTE PTR [r11+0x2],bl
 1b2:	0f b6 5d 03          	movzx  ebx,BYTE PTR [rbp+0x3]
 1b6:	41 88 5b 03          	mov    BYTE PTR [r11+0x3],bl
 1ba:	83 c1 01             	add    ecx,0x1
 1bd:	4c 29 c0             	sub    rax,r8
 1c0:	4c 01 e6             	add    rsi,r12
 1c3:	44 39 d1             	cmp    ecx,r10d
 1c6:	0f 84 94 00 00 00    	je     260 <cropflip_c+0x260>
 1cc:	85 d2                	test   edx,edx
 1ce:	7e ea                	jle    1ba <cropflip_c+0x1ba>
 1d0:	4c 8d 5e 10          	lea    r11,[rsi+0x10]
 1d4:	48 89 c5             	mov    rbp,rax
 1d7:	4c 29 f5             	sub    rbp,r14
 1da:	4c 39 d8             	cmp    rax,r11
 1dd:	4c 8d 58 10          	lea    r11,[rax+0x10]
 1e1:	0f 93 c3             	setae  bl
 1e4:	4c 39 de             	cmp    rsi,r11
 1e7:	41 0f 93 c3          	setae  r11b
 1eb:	44 08 db             	or     bl,r11b
 1ee:	0f 85 f4 fe ff ff    	jne    e8 <cropflip_c+0xe8>
 1f4:	48 8b 5c 24 f0       	mov    rbx,QWORD PTR [rsp-0x10]
 1f9:	44 8b 4c 24 bc       	mov    r9d,DWORD PTR [rsp-0x44]
 1fe:	49 89 f3             	mov    r11,rsi
 201:	48 89 44 24 e8       	mov    QWORD PTR [rsp-0x18],rax
 206:	48 8d 2c 33          	lea    rbp,[rbx+rsi*1]
 20a:	48 89 c3             	mov    rbx,rax
 20d:	0f 1f 00             	nop    DWORD PTR [rax]
 210:	0f b6 03             	movzx  eax,BYTE PTR [rbx]
 213:	49 83 c3 04          	add    r11,0x4
 217:	48 83 c3 04          	add    rbx,0x4
 21b:	41 88 43 fc          	mov    BYTE PTR [r11-0x4],al
 21f:	0f b6 43 fd          	movzx  eax,BYTE PTR [rbx-0x3]
 223:	41 88 43 fd          	mov    BYTE PTR [r11-0x3],al
 227:	0f b6 43 fe          	movzx  eax,BYTE PTR [rbx-0x2]
 22b:	41 88 43 fe          	mov    BYTE PTR [r11-0x2],al
 22f:	0f b6 43 ff          	movzx  eax,BYTE PTR [rbx-0x1]
 233:	41 88 43 ff          	mov    BYTE PTR [r11-0x1],al
 237:	49 39 eb             	cmp    r11,rbp
 23a:	75 d4                	jne    210 <cropflip_c+0x210>
 23c:	48 8b 44 24 e8       	mov    rax,QWORD PTR [rsp-0x18]
 241:	83 c1 01             	add    ecx,0x1
 244:	4c 01 e6             	add    rsi,r12
 247:	44 89 4c 24 bc       	mov    DWORD PTR [rsp-0x44],r9d
 24c:	4c 29 c0             	sub    rax,r8
 24f:	44 39 d1             	cmp    ecx,r10d
 252:	0f 85 74 ff ff ff    	jne    1cc <cropflip_c+0x1cc>
 258:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
 25f:	00 
 260:	5b                   	pop    rbx
 261:	5d                   	pop    rbp
 262:	41 5c                	pop    r12
 264:	41 5d                	pop    r13
 266:	41 5e                	pop    r14
 268:	41 5f                	pop    r15
 26a:	c3                   	ret    
