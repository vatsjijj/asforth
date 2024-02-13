\ MANIP

: NIP ( x y -- y ) SWAP DROP ;

: TUCK ( x y -- y x y ) SWAP OVER ;

: PICK ( x_u ... x_1 x_0 u -- x_u ... x_1 x_0 x_u )
	1+ 8 * DSP@ + @ ;

: MIN ( n1 n2 -- n3 )
	2DUP > IF
		SWAP
	THEN DROP ;

: MAX ( n1 n2 -- n3 )
	2DUP < IF
		SWAP
	THEN DROP ;
