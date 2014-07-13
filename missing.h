#include <sys/types.h>
#include <stddef.h>

void arc4random_buf(void *, size_t);
void explicit_bzero(void *, size_t);
int getentropy(void *, size_t);
void * reallocarray(void *, size_t, size_t);
int timingsafe_bcmp(const void *, const void *, size_t);
