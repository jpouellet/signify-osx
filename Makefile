#CVSROOT= anoncvs@anoncvs.openbsd.org:/cvs
CVSROOT= anoncvs@anoncvs3.usa.openbsd.org:/cvs

SRCS+= src/lib/libc/crypt/blowfish.c
SRCS+= src/lib/libc/gen/readpassphrase.c
SRCS+= src/lib/libc/hash/sha2.c
SRCS+= src/lib/libc/net/base64.c
SRCS+= src/lib/libc/string/explicit_bzero.c
SRCS+= src/lib/libc/string/timingsafe_bcmp.c
SRCS+= src/lib/libutil/bcrypt_pbkdf.c
SRCS+= src/usr.bin/signify/crypto_api.c
SRCS+= src/usr.bin/signify/mod_ed25519.c
SRCS+= src/usr.bin/signify/mod_ge25519.c
SRCS+= src/usr.bin/signify/signify.c
SRCS+= src/usr.bin/ssh/fe25519.c
SRCS+= src/usr.bin/ssh/sc25519.c
SRCS+= src/usr.bin/ssh/smult_curve25519_ref.c

LOCAL_SRCS+= badrandom.c
LOCAL_SRCS+= hashaliases.c
LOCAL_SRCS+= reallocarray.c
LOCAL_SRCS+= src/lib/libc/hash/sha224hl.c
LOCAL_SRCS+= src/lib/libc/hash/sha256hl.c
LOCAL_SRCS+= src/lib/libc/hash/sha384hl.c
LOCAL_SRCS+= src/lib/libc/hash/sha512hl.c

INCL+= src/include/blf.h
INCL+= src/include/readpassphrase.h
INCL+= src/include/sha2.h
INCL+= src/lib/libutil/util.h
INCL+= src/usr.bin/ssh/crypto_api.h
INCL+= src/usr.bin/ssh/fe25519.h
INCL+= src/usr.bin/ssh/ge25519.h
INCL+= src/usr.bin/ssh/ge25519_base.data
INCL+= src/usr.bin/ssh/sc25519.h

MAN= src/usr.bin/signify/signify.1

FETCH_ONLY+= src/lib/libc/hash/helper.c
FETCH_ONLY+= src/etc/signify

FROM_CVS+= ${SRCS} ${INCL} ${MAN} ${FETCH_ONLY}

CPPFLAGS+= -Isrc/usr.bin/ssh -Isrc/include
CPPFLAGS+= -include missing.h -include src/lib/libutil/util.h
CPPFLAGS+= -D_NSIG=NSIG
CPPFLAGS+= '-D__weak_alias(a,b)='
CPPFLAGS+= -Wno-attributes

.PHONY: fetch hash_helpers clean install

signify: hash_helpers
	cc ${CPPFLAGS} -o signify ${SRCS} ${LOCAL_SRCS}
	cp src/usr.bin/signify/signify.1 .

hash_helpers: src/lib/libc/hash/sha224hl.c src/lib/libc/hash/sha256hl.c \
              src/lib/libc/hash/sha384hl.c src/lib/libc/hash/sha512hl.c

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

src/lib/libc/hash/helper.c: fetch

fetch:
	cvs -qd ${CVSROOT} get -P ${FROM_CVS}

clean:
	rm -rf src signify signify.1

install:
	install -d /usr/local/bin /usr/local/share/man/man1
	install -Ss -m 755 signify /usr/local/bin
	install -S -m 644 signify.1 /usr/local/share/man/man1
