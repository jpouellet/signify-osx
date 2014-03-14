/*
 * I would rather port OpenBSD's ChaCha20 implementation, but it relies on the
 * kernel having a {CTL_KERN, KERN_ARND} (or equivelant) sysctl for stirring,
 * and OS X doesn't have one. Also, in trying to fill in the missing
 * functionality of a very important algorithm I don't fully understand, I may
 * mess something up, and there is no room for error in your PRNG (and errors
 * would be very hard to detect, especially in this OS X port of signify which
 * is probably not going to be well audited by anybody anyway. Therefore, just
 * use the system's PRNG and call it a day.
 */

#include <sys/types.h>
#include <sys/uio.h>

#include <err.h>
#include <fcntl.h>
#include <unistd.h>
#include <sysexits.h>

#ifdef ARC4_RANDOM_TEST
#include <stdio.h>
#include <string.h>
#endif

#define RND_DEV "/dev/random"

void
arc4random_buf(void *buf, size_t nbytes)
{
	int fd;

	if ((fd = open(RND_DEV, O_RDONLY)) == -1)
		err(EX_OSFILE, "unable to open " RND_DEV " for reading");

	if ((size_t)read(fd, buf, nbytes) != nbytes)
		err(EX_IOERR, "unable to read %zu bytes from " RND_DEV, nbytes);

	close(fd);
}

#ifdef ARC4_RANDOM_TEST
int
main()
{
	unsigned char buf[16];
	int i;

	memset(buf, 0, sizeof(buf));

	arc4random_buf(buf + 1, sizeof(buf) - 2);

	printf("expected: 00 ");
	for (i = 0; i < 14; i++)
		printf("?? ");
	printf("00\n");

	printf("found:    ");
	for (i = 0; i < 16; i++)
		printf("%02x ", buf[i]);
	printf("\n");
}
#endif
