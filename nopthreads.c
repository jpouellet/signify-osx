/* This isn't multithreaded, so we don't care. Just make it compile. */

int __isthreaded = 0;

void
_thread_arc4_lock(void)
{
}

void
_thread_arc4_unlock(void)
{
}
