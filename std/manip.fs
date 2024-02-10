\ MANIP

: NIP ( x y -- y ) SWAP DROP ;

: TUCK ( x y -- y x y ) SWAP OVER ;

: PICK ( x_u ... x_1 x_0 u -- x_u ... x_1 x_0 x_u )
	1+ 8 * DSP@ + @ ;
