#!/bin/sh

t="$PWD/test-results"
s="$PWD/src/regress/usr.bin/signify"

rm -rf "$t"
mkdir "$t"

# We don't have native sha* like OpenBSD, so emulate them:
function fixsha { sed 's/^SHA\([0-9]*\)(\(.*\))= /SHA\1 (\2) = /'; }
function sha256 { openssl dgst -sha256 "$@" | fixsha; }
function sha512 { openssl dgst -sha512 "$@" | fixsha; }

# Use the signify we just compiled, not some other one.
alias signify="$PWD/signify"

if ( cd "$t" && . "$s/signify.sh" "$s" ); then
	echo 'All tests passed!'
	true
else
	echo 'TESTS FAILED!'
	false
fi
