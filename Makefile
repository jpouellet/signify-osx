PREFIX= /usr/local
BINDIR= ${PREFIX}/bin
MANDIR= ${PREFIX}/share/man

#CVSROOT= anoncvs@anoncvs.openbsd.org:/cvs
CVSROOT= anoncvs@anoncvs3.usa.openbsd.org:/cvs


### sources from upstream

SRCS+= src/lib/libc/crypt/blowfish.c
SRCS+= src/lib/libc/hash/sha2.c
SRCS+= src/lib/libc/net/base64.c
SRCS+= src/lib/libc/string/explicit_bzero.c
SRCS+= src/lib/libutil/bcrypt_pbkdf.c
SRCS+= src/lib/libutil/ohash.c
SRCS+= src/usr.bin/signify/crypto_api.c
SRCS+= src/usr.bin/signify/fe25519.c
SRCS+= src/usr.bin/signify/mod_ed25519.c
SRCS+= src/usr.bin/signify/mod_ge25519.c
SRCS+= src/usr.bin/signify/signify.c
SRCS+= src/usr.bin/signify/sc25519.c
SRCS+= src/usr.bin/signify/zsig.c

INCL+= src/include/blf.h
INCL+= src/include/sha2.h
INCL+= src/lib/libutil/ohash.h
INCL+= src/lib/libutil/util.h # only for bcrypt_pbkdf decl
INCL+= src/usr.bin/signify/crypto_api.h
INCL+= src/usr.bin/signify/fe25519.h
INCL+= src/usr.bin/signify/ge25519.h
INCL+= src/usr.bin/signify/ge25519_base.data
INCL+= src/usr.bin/signify/sc25519.h
INCL+= src/usr.bin/signify/signify.h

MAN= src/usr.bin/signify/signify.1

FETCH_ONLY+= src/etc/signify # keys
FETCH_ONLY+= src/lib/libc/hash/helper.c # src of generated files
FETCH_ONLY+= src/lib/libc/string/timingsafe_memcmp.c # only used by regress
FETCH_ONLY+= src/regress/lib/libc/explicit_bzero
FETCH_ONLY+= src/regress/lib/libc/timingsafe
FETCH_ONLY+= src/regress/usr.bin/signify


### formerly required sorces, now with native equivelants

# used to be for arc4random_buf, but now is available natively
#SRCS+= src/lib/libc/crypt/arc4random.c
#INCL+= src/lib/libcrypto/arc4random/arc4random_osx.h
#INCL+= src/lib/libc/crypt/chacha_private.h
#CFLAGS+= -I. # was for local arc4random.h

# used to be required since macOS's reaspassphrase() didn't support RPP_STDIN,
# but "RPP_STDIN was introduced in OS X 10.12" - readpassphrase(3)
#SRCS+= src/lib/libc/gen/readpassphrase.c
#INCL+= src/include/readpassphrase.h

# native timingsafe_bcmp introduced in macOS 10.12.1
#SRCS+= src/lib/libc/string/timingsafe_bcmp.c

# native getentropy introduced in OSX 10.12
#SRCS+= src/lib/libcrypto/arc4random/getentropy_osx.c


### everything we fetch remotely

FROM_CVS+= ${SRCS} ${INCL} ${MAN} ${FETCH_ONLY}


### local files

HASH_HELPERS+= src/lib/libc/hash/sha256hl.c
HASH_HELPERS+= src/lib/libc/hash/sha512hl.c
HASH_HELPERS+= src/lib/libc/hash/sha512_256hl.c

LOCAL_SRCS+= ${HASH_HELPERS}
LOCAL_SRCS+= hashaliases.c
LOCAL_SRCS+= freezero.c


### build cfg

CFLAGS+= -Isrc/include
CFLAGS+= -Isrc/lib/libutil
#CFLAGS+= -Isrc/usr.bin/signify
CFLAGS+= -include missing.h
#CFLAGS+= -D_NSIG=NSIG
CFLAGS+= '-DDEF_WEAK(a)=asm("")'
CFLAGS+= '-DMAKE_CLONE(a,b)=asm("")'
CFLAGS+= '-Dpledge(a,b)=(0)'
CFLAGS+= -Wall -Wextra
#CFLAGS+= -Wno-attributes
CFLAGS+= -Wno-pointer-sign
CFLAGS+= -Wno-sign-compare
CFLAGS+= -Wno-unused-parameter


### targets

.PHONY: fetch hash-helpers clean install check test up check-updates ls

signify: ${LOCAL_SRCS} ${SRCS} ${INCL}
	${CC} ${CFLAGS} -o $@ ${SRCS} ${LOCAL_SRCS}
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

src/lib/libc/hash/sha512_256hl.c: src/lib/libc/hash/helper.c
	sed -e 's/hashinc/sha2.h/g' \
	    -e 's/HASH/SHA512_256/g' \
	    -e 's/SHA512_256_CTX/SHA2_CTX/g' $< > $@

src/lib/libc/hash/helper.c:
	$(error Missing source files... Maybe you want to `make fetch`?)

fetch:
	cvs -qd ${CVSROOT} get -P ${FROM_CVS}

install: signify
	install -d ${BINDIR} ${MANDIR}/man1
	install -Ss -m 755 signify ${BINDIR}
	install -S -m 644 signify.1 ${MANDIR}/man1


### regression test targets

REGRESS_BZ_SRCS=  src/lib/libc/string/explicit_bzero.c
REGRESS_BZ_SRCS+= src/regress/lib/libc/explicit_bzero/explicit_bzero.c
explicit_bzero: ${REGRESS_BZ_SRCS}
	${CC} ${CFLAGS} -o $@ ${REGRESS_BZ_SRCS}

REGRESS_TS_SRCS=  src/lib/libc/string/timingsafe_memcmp.c
#REGRESS_TS_SRCS+= src/lib/libc/string/timingsafe_bcmp.c # not since 10.12
REGRESS_TS_SRCS+= src/regress/lib/libc/timingsafe/timingsafe.c
timingsafe: ${REGRESS_TS_SRCS}
	${CC} ${CFLAGS} -o $@ ${REGRESS_TS_SRCS}

check: test

test: signify explicit_bzero timingsafe
	@sh ./regress.sh


### syncing with upstream

up: check-updates

check-updates:
	@(cd src && CVS_RSH=ssh cvs -qn up 2>&1 \
	    | (grep -v '^? ' || echo 'Up to date!'))


### misc

ls:
	@echo $(FROM_CVS:src/%=%)

clean:
	rm -rf signify signify.1 test-results timingsafe explicit_bzero
