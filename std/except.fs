\ EXCEPT

: EXCEPTION-MARKER RDROP 0 ;

: CATCH
	DSP@ 8+ >R
	' EXCEPTION-MARKER 8+ >R
	EXECUTE ;

: THROW
	?DUP IF
		RSP@ BEGIN
			DUP R0 8- <
		WHILE
			DUP @
			' EXCEPTION-MARKER 8+ = IF
				8+ RSP! DUP DUP DUP R>
				8- SWAP OVER ! DSP! EXIT
			THEN 8+
		REPEAT DROP
		CASE
			0 1- OF
				." ABORTED " CR
			ENDOF
				." UNCAUGHT THROW "
				DUP . CR
		ENDCASE QUIT
	THEN ;

: ABORT 0 1- THROW ;

: PRINT-STACK-TRACE
	RSP@ BEGIN
		DUP R0 8- <
	WHILE
		DUP @ CASE
			' EXCEPTION-MARKER 8+ OF
				." CATCH ( DSP="
				8+ DUP @ U.
				." ) "
			ENDOF
				DUP CFA> ?DUP IF
					2DUP ID.
					[ CHAR + ] LITERAL EMIT
					SWAP >DFA 8+ - .
				THEN
		ENDCASE 8+
	REPEAT DROP CR ;