/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_O_29r1m272a.c (2026-11-22-11-p6-r78)
   sha256 ca29f564ad788ac369013324dec6b6f893038a920b1d2ee6cc1323d9444b1c81 (tar-sha256); compiled at -O3 -Xr
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
char *IDCursorAdvance(struct PropCursor *c)
{
	char buf[128];
	long sum;
	unsigned int i;

	SendEvent(c->obj, EVT_GET_PROP_STRING, (long)buf);
	sum = 0;
	for (i = 0; i < c->index; i++)
		sum += SendEvent(0x2600000L + (unsigned char)(buf[i] - 'A'), EVT_GET_PROP_SIZE, 0);
	return (char *)SendEvent(c->obj, EVT_GET_INSTANCE, 0) + sum;
}
