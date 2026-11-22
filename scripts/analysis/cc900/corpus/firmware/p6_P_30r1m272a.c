/* lane_p6 helper P, round 30r1, form a: module 272 (ui/ui_widget_defs.s), IDCursorAdvance.  One-spot retry of
   helper O's p6_O_29r1m272b (run r78: O3Xr agrees in every instruction but the frame offsets: the ROM keeps the
   cursor pointer at +2, the sum at +6 and the buffer at +10, where V4.23 put the spilled parameter at the top of the
   frame, +134, the sum at +2 and the buffer at +6).  Form a: the cursor copied into a pointer LOCAL declared first
   (a local gets a low slot, a spilled parameter the top one), then the sum, then the buffer.
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
extern long IDCursorAdvance(struct PropCursor *c0);

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
