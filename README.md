This is an OS X port of OpenBSD's signify(1).

Man page at http://www.openbsd.org/cgi-bin/man.cgi?query=signify

`src/` is the current (as of 3/14/14) result of `make fetch`.

If you don't trust me to not have modified anything in there to insert a backdoor
(why should you?), but you trust the upstream OpenBSD version, then simply
`rm -r src` it, or `make clean` and audit the rest of the files that constitute
this "port". It's <200 lines, you can do it :)
