0 VALUE FD
100 CELLS ALLOT CONSTANT BUFFER

: TEST
	S" examples/fib.fs" R/O OPEN-FILE
	?DUP IF
		S" examples/fib.fs" PERROR QUIT
	THEN TO FD
	BEGIN
		BUFFER 100 CELLS FD READ-FILE
		?DUP IF
			S" READ-FILE" PERROR QUIT
		THEN DUP
		BUFFER SWAP TELL 0=
	UNTIL FD CLOSE-FILE
	?DUP IF
		S" CLOSE FILE" PERROR QUIT
	THEN ;
