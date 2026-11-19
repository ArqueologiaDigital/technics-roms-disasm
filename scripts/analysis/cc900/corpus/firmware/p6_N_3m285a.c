/* lane_p6 helper N, round 3, form a: module 285 (midi/midi_dispatch_handlers.s), retry of p6_N_1m285a / b.
   MidiPkt_SetXferTotal_All (p6-r42: +30): V4.23 folded all the constants of the size sum into one (0x184b2) where
   the ROM adds 0x12cb2 after the pointer difference and 0x5800 at the end.  Form a: the size functions return
   unsigned long, so the sum changes type after the first constant; the end pointer as an integer sum, size first.
   MidiPkt_UnpackNibblesToXfer (p6-r42: +1, body otherwise in the ROM's shape with form b's pointer locals): the
   ROM keeps hi / lo / d / cnt in XIX / XHL / XDE / XIY and left / cur / end in the frame at +4 / +8 / +12.
   Form a declares the frame ones first, then cnt, then hi, lo, d.
   cc900-options: -O3 -Xr
*/
/* cc900-module: AccWrap_ReturnZero MIDI_ReadChannelParam MidiPkt_GetUsedSize_AccompBlocks MidiPkt_GetUsedSize_SeqEvents MidiPkt_GetUsedSize_StyleImage */

struct mq { unsigned int count; unsigned char *rd; unsigned char *p6; unsigned char *wr; unsigned char buf[2]; };
typedef struct mq *mqp;
struct xfer { unsigned char *start; unsigned char *end; long size; };

extern unsigned char __near LIVE_PANEL_BLOCK;
extern unsigned char __near ram_ffbe;
extern unsigned long MidiPkt_GetUsedSize_SeqEvents(void);
extern unsigned long MidiPkt_GetUsedSize_AccompBlocks(void);
extern unsigned long MidiPkt_GetUsedSize_StyleImage(void);
extern int AccWrap_ReturnZero(int);
extern mqp __near MIDISEQ_ACTIVE_BLOCK_PTR;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern struct xfer __near ram_bcec;
extern long __near ram_bce4;
extern void MIDI_ReadChannelParam(mqp, int, int);

void MidiPkt_SetXferTotal_All(struct xfer *x)
{
	unsigned long n;

	x->start = &LIVE_PANEL_BLOCK;
	n = MidiPkt_GetUsedSize_SeqEvents();
	x->size += (&ram_ffbe - &LIVE_PANEL_BLOCK) + 0x12cb2 + MidiPkt_GetUsedSize_AccompBlocks() + n + 0x5800;
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
	long *cnt;
	unsigned char **hi;
	unsigned char **lo;
	unsigned char **d;

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
