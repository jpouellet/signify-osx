/*
 * OS X compilers seem to have trouble resolving __weak_alias()es,
 * so just make explicit wrapper functions.
 */

#include <sha2.h>

/* __weak_alias(SHA224Transform, SHA256Transform); */
void
SHA224Transform(u_int32_t state[8], const u_int8_t data[SHA256_BLOCK_LENGTH])
{
	SHA256Transform(state, data);
}

/* __weak_alias(SHA224Update, SHA256Update); */
void
SHA224Update(SHA2_CTX *context, const u_int8_t *data, size_t len)
{
	SHA256Update(context, data, len);
}

/* __weak_alias(SHA224Pad, SHA256Pad); */
void
SHA224Pad(SHA2_CTX *context)
{
	SHA256Pad(context);
}

/* __weak_alias(SHA384Transform, SHA512Transform); */
void
SHA384Transform(u_int64_t state[8], const u_int8_t data[SHA512_BLOCK_LENGTH])
{
	SHA512Transform(state, data);
}

/* __weak_alias(SHA384Update, SHA512Update); */
void
SHA384Update(SHA2_CTX *context, const u_int8_t *data, size_t len)
{
	SHA512Update(context, data, len);
}

/* __weak_alias(SHA384Pad, SHA512Pad); */
void
SHA384Pad(SHA2_CTX *context)
{
	SHA512Pad(context);
}
