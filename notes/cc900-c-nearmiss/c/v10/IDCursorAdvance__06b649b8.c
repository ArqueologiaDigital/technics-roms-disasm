/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_P_30r1m272a.c (2026-11-22-13-p6-r80)
   sha256 06b649b8bd8d39b23b8aa4d2c3e77c3f016e7ae3d369cf448235466640c968a5 (tar-sha256); compiled at -O3 -Xr
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
long IDCursorAdvance(struct PropCursor *c0)
{
	struct PropCursor *c;
	long sum;
	unsigned char buf[128];
	unsigned int i;

	c = c0;
	SendEvent(c->obj, EVT_GET_PROP_STRING, (long)buf);
	sum = 0;
	for (i = 0; i < c->index; i++)
		sum += SendEvent(0x2600000L + (unsigned char)(buf[i] - 0x41), EVT_GET_PROP_SIZE, 0);
	return SendEvent(c->obj, EVT_GET_INSTANCE, 0) + sum;
}
