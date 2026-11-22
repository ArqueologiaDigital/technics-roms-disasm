/* lane_p6 helper O, round 29r1, form a: module 272 (ui/ui_widget_defs.s), IDCursorAdvance (104 B, singletons29_O):
   asks the object (cursor word +8) for its property string into a 128-byte frame buffer, sums EVT_GET_PROP_SIZE of
   property type 0x2600000 + (letter - 'A') over the first cursor[0] letters, and returns the object's instance plus
   that sum.  Form a: buffer declared before the sum; the count compared as unsigned long (the ROM's `jr c`).
   cc900-options: -O3 -Xr
*/

#define EVT_GET_INSTANCE      0x1e0000fL
#define EVT_GET_PROP_STRING   0x1e00019L
#define EVT_GET_PROP_SIZE     0x1e00027L

struct PropCursor {
	unsigned long index;
	long value;
	long obj;
};

extern long SendEvent(long, long, long);
extern char *IDCursorAdvance(struct PropCursor *c);

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
