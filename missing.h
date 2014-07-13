#include <sys/types.h>
#include <stddef.h>

void explicit_bzero(void *, size_t);
int timingsafe_bcmp(const void *, const void *, size_t);
int getentropy(void *, size_t);
void * reallocarray(void *, size_t, size_t);
