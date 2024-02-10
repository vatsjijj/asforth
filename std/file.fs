\ FILE

: R/O ( -- fam ) O_RDONLY ;

: R/W ( -- fam ) O_RDWR ;

: OPEN-FILE ( addr u fam -- fd 0 | c-addr u fam -- fd errno )
	-ROT CSTRING SYS_OPEN SYSCALL2
	DUP DUP 0< IF
		NEGATE
	ELSE
		DROP 0
	THEN ;

: CREATE-FILE
	O_CREAT OR O_TRUNC OR
	-ROT CSTRING 420 -ROT
	SYS_OPEN SYSCALL3
	DUP DUP 0< IF
		NEGATE
	ELSE
		DROP 0
	THEN ;

: CLOSE-FILE SYS_CLOSE SYSCALL1 NEGATE ;

: READ-FILE
	>R SWAP R> SYS_READ SYSCALL3
	DUP DUP 0< IF
		NEGATE
	ELSE
		DROP 0
	THEN ;

: PERROR
	TELL ':' EMIT SPACE
	." ERRNO=" . CR ;
