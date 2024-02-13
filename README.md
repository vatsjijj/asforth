# asforth
Forth, written in 800 lines of assembly.

## Building
You must have NASM and Make installed, and you must be running an x86_64 Linux machine.

Run `make` to build `asforth`, running `asforth` will work, but you haven't told `asforth` about any of the stdlib.

For convenience `rasforth` is provided, to utilize `rasforth` you must have `rlwrap` installed.

`asforth` reads from `STDIN`, you can define separate files and pipe them into `asforth`.

```
." Hello, world!" CR
```

Have fun Forthing!

## TODO
Allow evaluation and interpretation of files on-the-fly. This would allow for actual file imports rather than having to concatenate every file from the stdlib and feeding it through standard input.

`DOES>` would be a very nice word to have, figure out how to implement this.

Along with `DOES>`, `EVALUATE` would also be extremely nice.