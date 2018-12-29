#include <sys/types.h>

/* in macOS (probably since 10.12?) */
/* void arc4random_buf(void *, size_t); */

void explicit_bzero(void *, size_t);

void freezero(void *, size_t);

/* in macOS since 10.12 */
/* int getentropy(void *, size_t); */

/* in macOS since 10.12.1 */
/* int timingsafe_bcmp(const void *, const void *, size_t); */

/* not used by signify, only required for timingsafe regression test */
int timingsafe_memcmp(const void *, const void *, size_t);
