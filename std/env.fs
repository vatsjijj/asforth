\ ENV

: ARGC S0 @ @ ;

: ARGV ( n -- str u )
	1+ CELLS S0 @ +
	@ DUP STRLEN ;

: ENVIRON ARGC 2 + CELLS S0 @ + ;

: BYE 0 SYS_EXIT SYSCALL1 ;

: GET-BRK ( -- brkpoint ) 0 SYS_BRK SYSCALL1 ;

: UNUSED ( -- n ) GET-BRK HERE @ - 8 / ;

: BRK ( brkpoint -- ) SYS_BRK SYSCALL1 ;

: MORECORE ( cells -- ) CELLS GET-BRK + BRK ;
