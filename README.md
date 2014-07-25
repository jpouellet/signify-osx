## OS X port of OpenBSD's [signify(1)](http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man1/signify.1)

Tested on OS X 10.6.8 with GCC 4.2.1 and 10.9.4 with Apple LLVM 5.0.

Man page at http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man1/signify.1

`src/` is the current (as of July 25th, 2014) result of `make fetch` (cvs get) and `make hash-helpers` (sed).

If you don't trust me (or github) to not have modified anything in there to
insert a backdoor (why should you?), but you trust the upstream OpenBSD version,
then simply `rm -r src` it and audit the rest of the files that constitute
this "port". It's less than 200 lines, you can do it :)

### Building:

I've included a copy of the upstream signify source in this repo for
convenience, but you should probably fetch it yourself. Doing so requires a
working `cvs`, which does not come with new OS X systems by default, so
either install that first (with macports or homebrew or whatever), or just
use the src shipped in this repo (as I know it works).

To get the latest upstream source:
```
rm -r src
make fetch
```

and then the usual `make`, `make install`.

### Testing:

To run the regression tests, `make test`.

### Keeping -current:

To check for upstream updates, `make check-updates`. (requires working CVS)
