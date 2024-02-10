\ COMMENT

: ( IMMEDIATE 
	1 BEGIN
		KEY DUP '(' = IF
			DROP 1+
		ELSE
			')' = IF
				1-
			THEN
		THEN
	DUP 0= UNTIL DROP ;
