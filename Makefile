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
SRCS+= src/lib/libc/string/explicit_bzero.c
SRCS+= src/lib/libc/string/timingsafe_bcmp.c
SRCS+= src/lib/libcrypto/crypto/getentropy_osx.c
SRCS+= src/lib/libutil/bcrypt_pbkdf.c
SRCS+= src/lib/libutil/ohash.c
SRCS+= src/usr.bin/signify/crypto_api.c
SRCS+= src/usr.bin/signify/fe25519.c
SRCS+= src/usr.bin/signify/mod_ed25519.c
SRCS+= src/usr.bin/signify/mod_ge25519.c
SRCS+= src/usr.bin/signify/signify.c
SRCS+= src/usr.bin/signify/sc25519.c
SRCS+= src/usr.bin/signify/smult_curve25519_ref.c

HASH_HELPERS+= src/lib/libc/hash/sha256hl.c
HASH_HELPERS+= src/lib/libc/hash/sha512hl.c

LOCAL_SRCS+= ${HASH_HELPERS}
LOCAL_SRCS+= hashaliases.c

INCL+= src/include/blf.h
INCL+= src/include/readpassphrase.h
INCL+= src/include/sha2.h
INCL+= src/lib/libc/crypt/chacha_private.h
INCL+= src/lib/libcrypto/crypto/arc4random_osx.h
INCL+= src/lib/libutil/ohash.h
INCL+= src/lib/libutil/util.h
INCL+= src/usr.bin/signify/crypto_api.h
INCL+= src/usr.bin/signify/fe25519.h
INCL+= src/usr.bin/signify/ge25519.h
INCL+= src/usr.bin/signify/ge25519_base.data
INCL+= src/usr.bin/signify/sc25519.h

MAN= src/usr.bin/signify/signify.1

FETCH_ONLY+= src/lib/libc/hash/helper.c
FETCH_ONLY+= src/etc/signify
FETCH_ONLY+= src/regress/usr.bin/signify

FROM_CVS+= ${SRCS} ${INCL} ${MAN} ${FETCH_ONLY}

CFLAGS+= -Isrc/include -Isrc/lib/libutil -Isrc/usr.bin/signify -I.
CFLAGS+= -include missing.h
CFLAGS+= -D_NSIG=NSIG
CFLAGS+= '-D__weak_alias(a,b)='
CFLAGS+= -Wall -Wextra
CFLAGS+= -Wno-attributes -Wno-pointer-sign -Wno-sign-compare
CFLAGS+= -Wno-unused-parameter

.PHONY: fetch hash-helpers clean install check test check-updates

signify: ${LOCAL_SRCS} ${SRCS} ${INCL}
	${CC} ${CFLAGS} -o signify ${SRCS} ${LOCAL_SRCS}
	cp src/usr.bin/signify/signify.1 .

hash-helpers: ${HASH_HELPERS}

src/lib/libc/hash/sha256hl.c: src/lib/libc/hash/helper.c
	sed -e 's/hashinc/sha2.h/g' \
	    -e 's/HASH/SHA256/g' \
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
