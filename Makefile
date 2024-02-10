all: asforth

asforth.o: src/asforth.asm src/unistd_64.inc
	nasm -f elf64 -o asforth.o src/asforth.asm

asforth: asforth.o
	ld -o asforth asforth.o

run_all_std: asforth
	cat            \
	std/core.fs    \
	std/cond.fs    \
	std/comment.fs \
	std/manip.fs   \
	std/fmt.fs     \
	std/print.fs   \
	std/util.fs    \
	std/except.fs  \
	std/cstr.fs    \
	std/env.fs     \
	std/file.fs    \
	std/prelude.fs \
	- | ./asforth

clean: asforth.o
	rm asforth.o