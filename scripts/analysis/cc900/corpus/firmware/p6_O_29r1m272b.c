/* lane_p6 helper O, round 29r1, form b: module 272 (ui/ui_widget_defs.s), IDCursorAdvance (104 B, singletons29_O).
   Form a with the sum declared before the buffer (frame order: the ROM has the spilled argument at +2, the sum at
   +6, the buffer at +10) and the result a long sum.
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
extern long IDCursorAdvance(struct PropCursor *c);

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
