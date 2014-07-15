PACKAGE:= signify
VERSION:= $(shell git describe --tags --always --dirty || echo unknown)

PREFIX= /usr/local
BINDIR= ${PREFIX}/bin
MANDIR= ${PREFIX}/share/man

#CVSROOT= anoncvs@anoncvs.openbsd.org:/cvs
CVSROOT= anoncvs@anoncvs3.usa.openbsd.org:/cvs

SRCS+= src/lib/libc/crypt/arc4random.c
SRCS+= src/lib/libc/crypt/blowfish.c
SRCS+= src/lib/libc/gen/readpassphrase.c
SRCS+= src/lib/libc/hash/sha2.c
SRCS+= src/lib/libc/net/base64.c
SRCS+= src/lib/libc/stdlib/reallocarray.c
SRCS+= src/lib/libc/string/explicit_bzero.c
SRCS+= src/lib/libc/string/timingsafe_bcmp.c
SRCS+= src/lib/libcrypto/crypto/getentropy_osx.c
SRCS+= src/lib/libutil/bcrypt_pbkdf.c
SRCS+= src/lib/libutil/ohash.c
SRCS+= src/usr.bin/signify/crypto_api.c
SRCS+= src/usr.bin/signify/mod_ed25519.c
SRCS+= src/usr.bin/signify/mod_ge25519.c
SRCS+= src/usr.bin/signify/signify.c
SRCS+= src/usr.bin/ssh/fe25519.c
SRCS+= src/usr.bin/ssh/sc25519.c
SRCS+= src/usr.bin/ssh/smult_curve25519_ref.c

HASH_HELPERS+= src/lib/libc/hash/sha224hl.c
HASH_HELPERS+= src/lib/libc/hash/sha256hl.c
HASH_HELPERS+= src/lib/libc/hash/sha384hl.c
HASH_HELPERS+= src/lib/libc/hash/sha512hl.c

LOCAL_SRCS+= hashaliases.c
LOCAL_SRCS+= nopthreads.c

LOCAL_INCL+= missing.h

INCL+= src/include/blf.h
INCL+= src/include/readpassphrase.h
INCL+= src/include/sha2.h
INCL+= src/lib/libc/crypt/chacha_private.h
INCL+= src/lib/libc/include/thread_private.h
INCL+= src/lib/libutil/ohash.h
INCL+= src/lib/libutil/util.h
INCL+= src/usr.bin/ssh/crypto_api.h
INCL+= src/usr.bin/ssh/fe25519.h
INCL+= src/usr.bin/ssh/ge25519.h
INCL+= src/usr.bin/ssh/ge25519_base.data
INCL+= src/usr.bin/ssh/sc25519.h

MAN= src/usr.bin/signify/signify.1

FETCH_ONLY+= src/lib/libc/hash/helper.c
FETCH_ONLY+= src/etc/signify
FETCH_ONLY+= src/regress/usr.bin/signify

FROM_CVS+= ${SRCS} ${INCL} ${MAN} ${FETCH_ONLY}

EXTRA_DIST+= Makefile
EXTRA_DIST+= regress.sh

CFLAGS+= -Isrc/usr.bin/ssh -Isrc/include -Isrc/lib/libutil
CFLAGS+= -Isrc/lib/libc/include
CFLAGS+= -include missing.h
CFLAGS+= -D_NSIG=NSIG
CFLAGS+= '-D__weak_alias(a,b)='
CFLAGS+= -Wall -Wextra
CFLAGS+= -Wno-attributes -Wno-pointer-sign -Wno-sign-compare
CFLAGS+= -Wno-unused-parameter

.PHONY: fetch hash-helpers clean install check test check-updates dist distcheck

signify: ${HASH_HELPERS} ${LOCAL_SRCS} ${LOCAL_INCL} ${SRCS} ${INCL}
	cc ${CFLAGS} -o signify ${SRCS} ${LOCAL_SRCS} ${HASH_HELPERS}
	cp src/usr.bin/signify/signify.1 .

hash-helpers: ${HASH_HELPERS}

src/lib/libc/hash/sha224hl.c: src/lib/libc/hash/helper.c
	sed -e 's/hashinc/sha2.h/g' \
	    -e 's/HASH/SHA224/g' \
	    -e 's/SHA[0-9][0-9][0-9]_CTX/SHA2_CTX/g' $< > $@

src/lib/libc/hash/sha256hl.c: src/lib/libc/hash/helper.c
	sed -e 's/hashinc/sha2.h/g' \
	    -e 's/HASH/SHA256/g' \
	    -e 's/SHA[0-9][0-9][0-9]_CTX/SHA2_CTX/g' $< > $@

src/lib/libc/hash/sha384hl.c: src/lib/libc/hash/helper.c
	sed -e 's/hashinc/sha2.h/g' \
	    -e 's/HASH/SHA384/g' \
	    -e 's/SHA[0-9][0-9][0-9]_CTX/SHA2_CTX/g' $< > $@

src/lib/libc/hash/sha512hl.c: src/lib/libc/hash/helper.c
	sed -e 's/hashinc/sha2.h/g' \
	    -e 's/HASH/SHA512/g' \
	    -e 's/SHA[0-9][0-9][0-9]_CTX/SHA2_CTX/g' $< > $@

src/lib/libc/hash/helper.c:
	$(error Missing source files... Maybe you want to `make fetch`?)

fetch:
	cvs -qd ${CVSROOT} get -P ${FROM_CVS}

clean:
	rm -rf signify signify.1 test-results

install: signify
	install -d ${BINDIR} ${MANDIR}/man1
	install -Ss -m 755 signify ${BINDIR}
	install -S -m 644 signify.1 ${MANDIR}/man1

check: test

test: signify
	@sh ./regress.sh

check-updates:
	@(cd src && cvs -qn up | (grep -v '^? ' || echo 'Up to date!'))

DISTDIR:= $(PACKAGE)-$(VERSION)
dist: $(DISTDIR).tar.gz

clean_DISTDIR:= $(RM) -r $(DISTDIR)
$(DISTDIR).tar.gz: $(FROM_CVS) $(LOCAL_SRCS) $(LOCAL_INCL) $(EXTRA_DIST)
	$(clean_DISTDIR)
	mkdir -p $(sort $(dir $(addprefix $(DISTDIR)/,$^)))
	for file in $^; do \
	  dirname=$${file%/*}; \
	  echo $${dirname}; \
	  if test -d $${dirname}; then \
	   cp -r $${file} $(DISTDIR)/$${file}; \
	  elif test -z $${dirname} -o $${dirname} = $${file}; then \
	    cp $${file} $(DISTDIR)/; \
	  else \
	    cp $${file} $(DISTDIR)/$${dirname}/; \
	  fi \
	done
	tar czf $@ $(DISTDIR)/*
	$(clean_DISTDIR)

distcheck: $(DISTDIR).tar.gz
	$(clean_DISTDIR)
	tar xf $<
	$(MAKE) -C $(DISTDIR) check
	$(clean_DISTDIR)
	@echo $< is ready for distribution.
