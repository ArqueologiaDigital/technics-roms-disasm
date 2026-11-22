/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_O_29r1m272b.c (2026-11-22-11-p6-r78)
   sha256 6b402ef088bf14a1814aacc0b2ca148e992d2262fe565af8a3bf1f71c85a304d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
#define EVT_GET_INSTANCE      0x1e0000fL
#define EVT_GET_PROP_STRING   0x1e00019L
#define EVT_GET_PROP_SIZE     0x1e00027L
struct PropCursor {
	unsigned long index;
	long value;
	long obj;
};
extern long SendEvent(long, long, long);
long IDCursorAdvance(struct PropCursor *c)
{
	long sum;
	unsigned char buf[128];
	unsigned int i;

	SendEvent(c->obj, EVT_GET_PROP_STRING, (long)buf);
	sum = 0;
	for (i = 0; i < c->index; i++)
		sum += SendEvent(0x2600000L + (unsigned char)(buf[i] - 0x41), EVT_GET_PROP_SIZE, 0);
	return SendEvent(c->obj, EVT_GET_INSTANCE, 0) + sum;
}
