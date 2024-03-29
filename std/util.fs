\ UTIL

: WITHIN ( c a b -- f )
	-ROT OVER <= IF
		> IF TRUE ELSE FALSE THEN
	ELSE
		2DROP FALSE
	THEN ;

: DEPTH ( -- n ) S0 @ DSP@ - 8- ;

: ALIGNED ( addr -- addr ) 7 + 7 INVERT AND ;

: ALIGN HERE @ ALIGNED HERE ! ;

: C, HERE @ C! 1 HERE +! ;

: S" IMMEDIATE ( -- addr len )
	STATE @ IF
		' LITSTRING , HERE @ 0 ,
		BEGIN
			KEY DUP '"' <>
		WHILE C, REPEAT
		DROP DUP HERE @ SWAP -
		8- SWAP ! ALIGN
	ELSE
		HERE @ BEGIN
			KEY DUP '"' <>
		WHILE
			OVER C! 1+
		REPEAT DROP
		HERE @ - HERE @ SWAP
	THEN ;

: ." IMMEDIATE
	STATE @ IF
		[COMPILE] S" ' TELL ,
	ELSE BEGIN
		KEY DUP '"' = IF
			DROP EXIT
		THEN EMIT
	AGAIN THEN ;

: CONSTANT
	WORD CREATE DOCOL ,
	' LIT , , ' EXIT , ;

: ALLOT ( n -- addr ) HERE @ SWAP HERE +! ;

: CELLS ( n -- n ) 8 * ;

: VARIABLE
	1 CELLS ALLOT WORD CREATE
	DOCOL , ' LIT , , ' EXIT , ;

: VALUE ( n -- )
	WORD CREATE DOCOL ,
	' LIT , , ' EXIT , ;

: TO IMMEDIATE ( n -- )
	WORD FIND >DFA 8+ STATE @ IF
		' LIT , , ' ! ,
	ELSE
		!
	THEN ;

: +TO IMMEDIATE
	WORD FIND >DFA 8+ STATE @ IF
		' LIT , , ' +! ,
	ELSE
		+!
	THEN ;

: ID. ( addr -- )
	8+ DUP C@ F_LENMASK AND BEGIN
		DUP 0>
	WHILE
		SWAP 1+ DUP C@ EMIT SWAP 1-
	REPEAT 2DROP ;

: ?HIDDEN 8+ C@ F_HIDDEN AND ;

: ?IMMEDIATE 8+ C@ F_IMMED AND ;

: WORDS
	LATEST @ BEGIN
		?DUP
	WHILE
		DUP ?HIDDEN NOT IF
			DUP ID. SPACE
		THEN @
	REPEAT CR ;

: FORGET WORD FIND DUP @ LATEST ! HERE ! ;

: DUMP ( addr len -- )
	BASE @ -ROT HEX BEGIN
		?DUP
	WHILE
		OVER 8 ZU.R SPACE
		2DUP 1- 15 AND 1+ BEGIN
			?DUP
		WHILE
			SWAP DUP C@
			2 ZU.R SPACE
			1+ SWAP 1-
		REPEAT DROP
		2DUP 1- 15 AND 1+ BEGIN
			?DUP
		WHILE
			SWAP DUP C@
			DUP 32 128 WITHIN IF
				EMIT
			ELSE
				DROP '.' EMIT
			THEN 1+ SWAP 1-
		REPEAT DROP CR
		DUP 1- 15 AND 1+
		TUCK - >R + R>
	REPEAT DROP BASE ! ;

: CASE IMMEDIATE 0 ;

: OF IMMEDIATE
	' OVER , ' = ,
	[COMPILE] IF ' DROP , ;

: ENDOF IMMEDIATE [COMPILE] ELSE ;

: ENDCASE IMMEDIATE
	' DROP , BEGIN
		?DUP
	WHILE
		[COMPILE] THEN
	REPEAT ;

: CFA>
	LATEST @ BEGIN
		?DUP
	WHILE
		2DUP SWAP < IF
			NIP EXIT
		THEN @
	REPEAT DROP 0 ;

: SEE
	WORD FIND HERE @ LATEST @ BEGIN
		2 PICK OVER <>
	WHILE
		NIP DUP @
	REPEAT DROP SWAP
	':' EMIT SPACE DUP ID. SPACE
	DUP ?IMMEDIATE IF
		." IMMEDIATE "
	THEN >DFA
	BEGIN
		2DUP >
	WHILE
		DUP @ CASE
			' LIT OF
				8 + DUP @ .
			ENDOF
			' LITSTRING OF
				[ CHAR S ] LITERAL EMIT '"' EMIT SPACE
				8 + DUP @ SWAP 8 + SWAP
				2DUP TELL '"' EMIT SPACE
				+ ALIGNED 8 -
			ENDOF
			' 0BRANCH OF
				." 0BRANCH ( "
				8 + DUP @ .
				." ) "
			ENDOF
			' BRANCH OF
				." BRANCH ( "
				8 + DUP @ .
				." ) "
			ENDOF
			' ' OF
				[ CHAR ' ] LITERAL EMIT SPACE
				8 + DUP @ CFA> ID. SPACE
			ENDOF
			' EXIT OF
				2DUP 8 + <> IF
					." EXIT "
				THEN
			ENDOF
				DUP CFA> ID. SPACE
		ENDCASE 8 +
	REPEAT ';' EMIT CR 2DROP ;

: :NONAME 0 0 CREATE HERE @ DOCOL , ] ;

: ['] IMMEDIATE ' LIT , ;
