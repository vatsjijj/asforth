BITS 64

;; nasm -g -F dwarf -f elf64 -o forth.o forth.asm
;; ld -o forth forth.o

%include "src/unistd_64.inc"

%define RET_STACK_SIZE 8192
%define BUF_SIZE 4096

;; Macros

%assign FORTH_VERSION 1

%macro NEXT 0
	lodsq
	jmp [rax]
%endmacro

%macro PUSHRSP 1
	lea rbp, [rbp-8]
	mov [rbp], %1
%endmacro

%macro POPRSP 1
	mov %1, [rbp]
	lea rbp, [rbp+8]
%endmacro

section .text
	DOCOL:
		PUSHRSP rsi
		add rax, 8
		mov rsi, rax
		NEXT
	
	global _start
	_start:
		cld
		mov [var_S0], rsp
		mov rbp, ret_stack_top
		call set_up_dsegment
		mov rsi, cold_start
		NEXT
	
section .rodata
	cold_start: dq QUIT

%define F_IMMED   0x80
%define F_HIDDEN  0x20
%define F_LENMASK 0x1F

%define link 0

;; Macro that defines a word
;; defword name, lbl, flag
%macro defword 2-3 0
	%strlen name_len %1

	section .rodata
		align 8, db 0
		global name_%2
		name_%2:
			dq link
			db name_len + %3
			db %1
		
		%define link name_%2

		align 8, db 0
		global %2
		%2: dq DOCOL
%endmacro

;; Macro that defines a NATIVE word
;; defcode name, lbl, flag
%macro defcode 2-3 0
	%strlen name_len %1

	section .rodata
		align 8, db 0
		global name_%2
		name_%2:
			dq link
			db name_len + %3
			db %1
		
		%define link name_%2

		align 8, db 0
		global $%2
		$%2: dq code_%2

	section .text
		align 8
		global code_%2
		code_%2:
%endmacro

defcode "DROP", DROP
	pop rax
	NEXT

defcode "SWAP", SWAP
	pop rax
	pop rbx
	push rax
	push rbx
	NEXT

defcode "DUP", DUP
	mov rax, [rsp]
	push rax
	NEXT

defcode "OVER", OVER
	mov rax, [rsp+8]
	push rax
	NEXT

defcode "ROT", ROT
	pop rax
	pop rbx
	pop rcx
	push rbx
	push rax
	push rcx
	NEXT

defcode "-ROT", NROT
	pop rax
	pop rbx
	pop rcx
	push rax
	push rcx
	push rbx
	NEXT

defcode "2DROP", TWODROP
	pop rax
	pop rax
	NEXT

defcode "2DUP", TWODUP
	mov rax, [rsp]
	mov rbx, [rsp+8]
	push rbx
	push rax
	NEXT

defcode "2SWAP", TWOSWAP
	pop rax
	pop rbx
	pop rcx
	pop rdx
	push rbx
	push rax
	push rdx
	push rcx
	NEXT

defcode "?DUP", QDUP
	mov rax, [rsp]
	test rax, rax
	jz .next
	push rax
.next NEXT

defcode "1+", INCR
	inc qword [rsp]
	NEXT

defcode "1-", DECR
	dec qword [rsp]
	NEXT

defcode "8+", INCR8
	add qword [rsp], 8
	NEXT

defcode "8-", DECR8
	sub qword [rsp], 8
	NEXT

defcode "+", PLUS
	pop rax
	add [rsp], rax
	NEXT

defcode "-", MINU
	pop rax
	sub [rsp], rax
	NEXT

defcode "*", MULT
	pop rax
	pop rbx
	imul rax, rbx
	push rax
	NEXT

defcode "/MOD", DIVMOD
	xor rdx, rdx
	pop rbx
	pop rax
	idiv rbx
	push rdx
	push rax
	NEXT

%macro defcmp 3
	defcode %1, %2
		pop rax
		pop rbx
		cmp rbx, rax
		set%+3 al
		movzx rax, al
		push rax
		NEXT
%endmacro

defcmp "=",  EQ,  e
defcmp "<>", NEQ, ne
defcmp "<",  LT,  l
defcmp ">",  GT,  g
defcmp "<=", LEQ, le
defcmp ">=", GEQ, ge

%macro deftest 3
	defcode %1, %2
		pop rax
		test rax, rax
		set%+3 al
		movzx rax, al
		push rax
		NEXT
%endmacro

deftest "0=",  ZEQ,  z
deftest "0<>", ZNEQ, nz
deftest "0<",  ZLT,  l
deftest "0>",  ZGT,  g
deftest "0<=", ZLEQ, le
deftest "0>=", ZGEQ, ge

defcode "AND", CAND
	pop rax
	and [rsp], rax
	NEXT

defcode "OR", COR
	pop rax
	or [rsp], rax
	NEXT

defcode "XOR", CXOR
	pop rax
	xor [rsp], rax
	NEXT

defcode "INVERT", INVERT
	not qword [rsp]
	NEXT

defcode "EXIT", EXIT
	POPRSP rsi
	NEXT

defcode "LIT", LIT
	lodsq
	push rax
	NEXT

defcode "!", STORE
	pop rbx
	pop rax
	mov [rbx], rax
	NEXT

defcode "@", FETCH
	pop rbx
	mov rax, [rbx]
	push rax
	NEXT

defcode "+!", ADDSTORE
	pop rbx
	pop rax
	add [rbx], rax
	NEXT

defcode "-!", SUBSTORE
	pop rbx
	pop rax
	sub [rbx], rax
	NEXT

defcode "C!", STOREBYTE
	pop rbx
	pop rax
	mov [rbx], al
	NEXT

defcode "C@", FETCHBYTE
	pop rbx
	xor rax, rax
	mov al, [rbx]
	push rax
	NEXT

defcode "C@C!", CCOPY
	mov rbx, [rsp+8]
	mov al, [rbx]
	pop rdi
	stosb
	push rdi
	inc qword [rsp+8]
	NEXT

defcode "CMOVE", CMOVE
	mov rdx, rsi
	pop rcx
	pop rdi
	pop rsi
	rep movsb
	mov rsi, rdx
	NEXT

%macro defvar 2-4 0, 0
	defcode %1, %2, %4
		push var_%2
		NEXT
	
	section .data
		align 8, db 0
		var_%2: dq %3
%endmacro

defvar "STATE", STATE
defvar "HERE", HERE
defvar "LATEST", LATEST, name_SYSCALL0
defvar "S0", S0
defvar "BASE", BASE, 10

%macro defconst 3-4 0
	defcode %1, %2, %4
		push %3
		NEXT
%endmacro

defconst "VERSION", VERSION, FORTH_VERSION
defconst "R0", R0, ret_stack_top
defconst "DOCOL", __DOCOL, DOCOL

defconst "F_IMMED",   __F_IMMED,   F_IMMED
defconst "F_HIDDEN",  __F_HIDDEN,  F_HIDDEN
defconst "F_LENMASK", __F_LENMASK, F_LENMASK

%macro defsys 2
	%defstr name SYS_%1
	defconst name, SYS_%1, __NR_%2
%endmacro

defsys EXIT,   exit
defsys OPEN,   open
defsys CLOSE,  close
defsys READ,   read
defsys WRITE,  write
defsys CREAT,  creat
defsys BRK,    brk

%macro defo 2
	%defstr name O_%1
	defconst name, __O_%1, %2
%endmacro

defo RDONLY,   0o
defo WRONLY,   10
defo RDWR,     20
defo CREAT,    100o
defo EXCL,     200o
defo TRUNC,    1000o
defo APPEND,   2000o
defo NONBLOCK, 4000o

defcode ">R", TOR
	pop rax
	PUSHRSP rax
	NEXT

defcode "R>", FROMR
	POPRSP rax
	push rax
	NEXT

defcode "RSP@", RSPFETCH
	push rbp
	NEXT

defcode "RSP!", RSPSTORE
	pop rbp
	NEXT

defcode "RDROP", RDROP
	add rbp, 8
	NEXT

defcode "DSP@", DSPFETCH
	mov rax, rsp
	push rax
	NEXT

defcode "DSP!", DSPSTORE
	pop rsp
	NEXT

defcode "KEY", KEY
	call _KEY
	push rax
	NEXT
_KEY:
	mov rbx, [currkey]
	cmp rbx, [buftop]
	jge .full
	xor rax, rax
	mov al, [rbx]
	inc rbx
	mov [currkey], rbx
	ret
.full:
	push rsi
	push rdi
	xor rdi, rdi
	mov rsi, buf
	mov [currkey], rsi
	mov rdx, BUF_SIZE
	mov rax, __NR_read
	syscall
	test rax, rax
	jbe .eof
	add rsi, rax
	mov [buftop], rsi
	pop rdi
	pop rsi
	jmp _KEY
.eof:
	xor rdi, rdi
	mov rax, __NR_exit
	syscall

section .data
	align 8, db 0
	currkey: dq buf
	buftop: dq buf

defcode "EMIT", EMIT
	pop rax
	call _EMIT
	NEXT
_EMIT:
	mov rdi, 1
	mov [emit_scratch], al
	push rsi
	mov rsi, emit_scratch
	mov rdx, 1
	mov rax, __NR_write
	syscall
	pop rsi
	ret

section .data
	emit_scratch: db 0

defcode "WORD", IWORD
	call _IWORD
	push rdi
	push rcx
	NEXT
_IWORD:
.ws:
	call _KEY
	cmp al, '\'
	je .comment
	cmp al, ' '
	jbe .ws
	mov rdi, word_buf
.iword:
	stosb
	call _KEY
	cmp al, ' '
	ja .iword
	sub rdi, word_buf
	mov rcx, rdi
	mov rdi, word_buf
	ret
.comment:
	call _KEY
	cmp al, 0x0A
	jne .comment
	jmp .ws

section .data
	word_buf: times 32 db 0

defcode "NUMBER", NUMBER
	pop rcx
	pop rdi
	call _NUMBER
	push rax
	push rcx
	NEXT
_NUMBER:
	xor rax, rax
	xor rbx, rbx
	test rcx, rcx
	jz .retu
	mov rdx, [var_BASE]
	mov bl, [rdi]
	inc rdi
	push rax
	cmp bl, '-'
	jnz .convert
	pop rax
	push rbx
	dec rcx
	jnz .iloop
	pop rbx
	mov rcx, 1
	ret
.iloop:
	imul rax, rdx
	mov bl, [rdi]
	inc rdi
.convert:
	sub bl, '0'
	jb .finish
	cmp bl, 10
	jb .numeric
	sub bl, 17
	jb .finish
	add bl, 10
.numeric:
	cmp bl, dl
	jge .finish
	add rax, rbx
	dec rcx
	jnz .iloop
.finish:
	pop rbx
	test rbx, rbx
	jz .retu
	neg rax
.retu:
	ret

defcode "FIND", FIND
	pop rcx
	pop rdi
	call _FIND
	push rax
	NEXT
_FIND:
	push rsi
	mov rdx, [var_LATEST]
.iloop:
	test rdx, rdx
	je .notfound
	xor rax, rax
	mov al, [rdx+8]
	and al, F_HIDDEN | F_LENMASK
	cmp al, cl
	jne .next
	push rcx
	push rdi
	lea rsi, [rdx+9]
	repe cmpsb
	pop rdi
	pop rcx
	jne .next
	pop rsi
	mov rax, rdx
	ret
.next:
	mov rdx, [rdx]
	jmp .iloop
.notfound:
	pop rsi
	xor rax, rax
	ret

defcode ">CFA", TCFA
	pop rdi
	call _TCFA
	push rdi
	NEXT
_TCFA:
	xor rax, rax
	add rdi, 8
	mov al, [rdi]
	inc rdi
	and al, F_LENMASK
	add rdi, rax
	add rdi, 0b111
	and rdi, ~0b111
	ret

defword ">DFA", TDFA
	dq TCFA
	dq INCR8
	dq EXIT

defcode "CREATE", CREATE
	pop rcx
	pop rbx
	mov rdi, [var_HERE]
	mov rax, [var_LATEST]
	stosq
	mov al, cl
	stosb
	push rsi
	mov rsi, rbx
	rep movsb
	pop rsi
	add rdi, 0b111
	and rdi, ~0b111
	mov rax, [var_HERE]
	mov [var_LATEST], rax
	mov [var_HERE], rdi
	NEXT

defcode ",", COMMA
	pop rax
	call _COMMA
	NEXT
_COMMA:
	mov rdi, [var_HERE]
	stosq
	mov [var_HERE], rdi
	ret

defcode "[", LBRAC, F_IMMED
	xor rax, rax
	mov [var_STATE], rax
	NEXT

defcode "]", RBRAC
	mov qword [var_STATE], 1
	NEXT

defword ":", COLON
	dq $IWORD
	dq CREATE
	dq LIT, DOCOL, COMMA
	dq LATEST, FETCH, HIDDEN
	dq RBRAC
	dq EXIT

defword ";", SEMICOLON, F_IMMED
	dq LIT, EXIT, COMMA
	dq LATEST, FETCH, HIDDEN
	dq LBRAC
	dq EXIT

defcode "IMMEDIATE", IMMEDIATE, F_IMMED
	mov rdi, [var_LATEST]
	add rdi, 8
	xor byte [rdi], F_IMMED
	NEXT

defcode "HIDDEN", HIDDEN
	pop rdi
	add rdi, 8
	xor byte [rdi], F_HIDDEN
	NEXT

defword "HIDE", HIDE
	dq $IWORD
	dq FIND
	dq HIDDEN
	dq EXIT

defcode "'", TICK
	lodsq
	push rax
	NEXT

defcode "BRANCH", BRANCH
	add rsi, [rsi]
	NEXT

defcode "0BRANCH", ZBRANCH
	pop rax
	test rax, rax
	jz code_BRANCH
	lodsq
	NEXT

defcode "LITSTRING", LITSTRING
	lodsq
	push rsi
	push rax
	add rsi, rax
	add rsi, 0b111
	and rsi, ~0b111
	NEXT

defcode "TELL", TELL
	mov rcx, rsi
	mov rdi, 1
	pop rdx
	pop rsi
	mov rax, __NR_write
	push rcx
	syscall
	pop rsi
	NEXT

;; Exclusively for testing
defword "FORTYTWO", FORTYTWO
	dq LIT
	dq 42
	dq EXIT

defword "QUIT", QUIT
	dq R0, RSPSTORE
	dq INTERPRET
	dq BRANCH, -16

defcode "INTERPRET", INTERPRET
	call _IWORD
	xor rax, rax
	mov [interpret_is_lit], rax
	call _FIND
	test rax, rax
	jz .number
	mov rdi, rax
	mov al, [rdi+8]
	push ax
	call _TCFA
	pop ax
	and al, F_IMMED
	mov rax, rdi
	jnz .exec
	jmp .main
.number:
	inc qword [interpret_is_lit]
	call _NUMBER
	test rcx, rcx
	jnz .numerror
	mov rbx, rax
	mov rax, LIT
.main:
	mov rdx, [var_STATE]
	test rdx, rdx
	jz .exec
	call _COMMA
	mov rcx, [interpret_is_lit]
	test rcx, rcx
	jz .next
	mov rax, rbx
	call _COMMA
.next: NEXT
.exec:
	mov rcx, [interpret_is_lit]
	test rcx, rcx
	jnz .litexec
	jmp [rax]
.litexec:
	push rbx
	NEXT
.numerror:
	push rsi
	mov rdi, 2
	mov rsi, errmsg
	mov rdx, errmsglen
	mov rax, __NR_write
	syscall
	mov rsi, [currkey]
	mov rdx, rsi
	sub rdx, buf
	cmp rdx, 40
	jle .le
	mov rdx, 40
.le:
	sub rsi, rdx
	mov rax, __NR_write
	syscall
	mov rsi, errmsgnl
	mov rdx, 1
	mov rax, __NR_write
	syscall
	pop rsi
	NEXT
	
section .rodata
	errmsg: db "PARSE ERROR: "
	errmsglen: equ $ - errmsg
	errmsgnl: db 0x0A

section .data
	align 8
	interpret_is_lit: dq 0

defcode "CHAR", CHAR
	call _IWORD
	xor rax, rax
	mov al, [rdi]
	push rax
	NEXT

defcode "EXECUTE", EXECUTE
	pop rax
	jmp [rax]

defcode "SYSCALL3", SYSCALL3
	mov rcx, rsi
	pop rax
	pop rdi
	pop rsi
	pop rdx
	push rcx
	syscall
	pop rsi
	push rax
	NEXT

defcode "SYSCALL2", SYSCALL2
	mov rcx, rsi
	pop rax
	pop rdi
	pop rsi
	push rcx
	syscall
	pop rsi
	push rax
	NEXT

defcode "SYSCALL1", SYSCALL1
	pop rax
	pop rdi
	syscall
	push rax
	NEXT

defcode "SYSCALL0", SYSCALL0
	pop rax
	syscall
	push rax
	NEXT

%define INITIAL_DATA_SEGMENT_SIZE 65536

section .text
	set_up_dsegment:
		xor rdi, rdi
		mov rax, __NR_brk
		syscall
		mov [var_HERE], rax
		add rax, INITIAL_DATA_SEGMENT_SIZE
		mov rdi, rax
		mov rax, __NR_brk
		syscall
		ret

section .bss
	align 4096
	ret_stack: resb RET_STACK_SIZE
	ret_stack_top:
	
	align 4096
	buf: resb BUF_SIZE