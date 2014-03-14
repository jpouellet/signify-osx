#include <sys/types.h>
#include <inttypes.h>

void explicit_bzero(void *, size_t);
int timingsafe_bcmp(const void *, const void *, size_t);
void arc4random_buf(void *, size_t);
