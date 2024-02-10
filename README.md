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