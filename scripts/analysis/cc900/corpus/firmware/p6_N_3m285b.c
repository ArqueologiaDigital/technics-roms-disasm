/* lane_p6 helper N, round 3, form b: module 285 (midi/midi_dispatch_handlers.s), retry of p6_N_1m285a / b.
   MidiPkt_SetXferTotal_All, form b: the live-panel size (pointer difference + 0x12cb2) in a long local assigned
   after both size calls, so the constant cannot fold with the trailing 0x5800; size functions long as built.
   MidiPkt_UnpackNibblesToXfer, form b: frame ones first, then hi, lo, d, then cnt last.
   cc900-options: -O3 -Xr
*/
/* cc900-module: AccWrap_ReturnZero MIDI_ReadChannelParam MidiPkt_GetUsedSize_AccompBlocks MidiPkt_GetUsedSize_SeqEvents MidiPkt_GetUsedSize_StyleImage */

struct mq { unsigned int count; unsigned char *rd; unsigned char *p6; unsigned char *wr; unsigned char buf[2]; };
typedef struct mq *mqp;
struct xfer { unsigned char *start; unsigned char *end; long size; };

extern unsigned char __near LIVE_PANEL_BLOCK;
extern unsigned char __near ram_ffbe;
extern long MidiPkt_GetUsedSize_SeqEvents(void);
extern long MidiPkt_GetUsedSize_AccompBlocks(void);
extern long MidiPkt_GetUsedSize_StyleImage(void);
extern int AccWrap_ReturnZero(int);
extern mqp __near MIDISEQ_ACTIVE_BLOCK_PTR;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern struct xfer __near ram_bcec;
extern long __near ram_bce4;
extern void MIDI_ReadChannelParam(mqp, int, int);

void MidiPkt_SetXferTotal_All(struct xfer *x)
{
	long n;
	long m;
	long t;

	x->start = &LIVE_PANEL_BLOCK;
	n = MidiPkt_GetUsedSize_SeqEvents();
	m = MidiPkt_GetUsedSize_AccompBlocks();
	t = (&ram_ffbe - &LIVE_PANEL_BLOCK) + 0x12cb2;
	x->size += t + m + n + 0x5800;
	if (AccWrap_ReturnZero(1) != -1)
		x->size += 0x72aa;
	if (AccWrap_ReturnZero(3) != -1)
		x->size += MidiPkt_GetUsedSize_StyleImage();
	x->end = (unsigned char *)(x->size + (long)x->start);
}

int MidiPkt_UnpackNibblesToXfer(void)
{
	struct mq *q;
	unsigned char c;
	long n;
	long *left;
	unsigned char **cur;
	unsigned char **end;
	unsigned char **hi;
	unsigned char **lo;
	unsigned char **d;
	long *cnt;

	q = MIDISEQ_ACTIVE_BLOCK_PTR;
	if (q->count != 0) {
		hi = lo = &q->p6;
		d = &ram_bcec.start;
		left = &ram_bce4;
		cnt = &ram_bcec.size;
		cur = &q->p6;
		end = &q->wr;
		do {
			c = *(*hi)++ << 4;
			c ^= *(*lo)++ & 0x0f;
			*(*d)++ = c;
			*left -= 1;
			n = --*cnt;
			if (*cur >= *end - 3)
				return 0;
		} while (n != 0);
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 22);
	}
	return -1;
}
