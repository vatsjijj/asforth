\ FMT

: SPACES ( n -- )
	BEGIN
		DUP 0>
	WHILE
		SPACE 1-
	REPEAT DROP ;

: ZEROS ( n -- )
	BEGIN
		DUP 0>
	WHILE
		'0' EMIT 1-
	REPEAT DROP ;

: DECIMAL ( -- ) 10 BASE ! ;

: HEX ( -- ) 16 BASE ! ;
