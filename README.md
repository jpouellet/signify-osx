This is an OS X port of OpenBSD's signify(1).

I've only used it with GCC (not llvm/clang) on OS X 10.6.8 with a working CVS,
because that's all I needed. It may or may not work elsewhere, although if it
doesn't, it shouldn't be too hard to fix.

Man page at http://www.openbsd.org/cgi-bin/man.cgi?query=signify

`src/` is the current (as of May 1st, 2014) result of `make fetch`.

If you don't trust me (or github) to not have modified anything in there to
insert a backdoor (why should you?), but you trust the upstream OpenBSD version,
then simply `rm -r src` it, or `make clean` and audit the rest of the files that
constitute this "port". It's less than 200 lines, you can do it :)
