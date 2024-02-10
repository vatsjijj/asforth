\ PRINT

: U. ( u -- )
	BASE @ /MOD
	?DUP IF
		RECURSE
	THEN
	DUP 10 < IF
		'0'
	ELSE
		10 - 'A'
	THEN + EMIT ;

: .S ( -- )
	DSP@ BEGIN
		DUP S0 @ <
	WHILE
		DUP @ U. SPACE 8+
	REPEAT DROP ;

: UWIDTH
	BASE @ / ?DUP IF
		RECURSE 1+
	ELSE 1 THEN ;

: U.R ( u width -- )
	SWAP DUP UWIDTH ROT
	SWAP - SPACES U. ;

: ZU.R ( u width -- )
	SWAP DUP UWIDTH ROT
	SWAP - ZEROS U. ;

: .R ( n width -- )
	SWAP DUP 0< IF
		NEGATE 1 SWAP ROT 1-
	ELSE
		0 SWAP ROT
	THEN
	SWAP DUP UWIDTH ROT SWAP -
	SPACES SWAP
	IF
		'-' EMIT
	THEN U. ;

: . 0 .R SPACE ;

: U. U. SPACE ;

: ? ( addr -- ) @ . ;
