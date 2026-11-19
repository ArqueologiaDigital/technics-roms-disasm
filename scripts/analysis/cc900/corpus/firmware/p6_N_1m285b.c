/* lane_p6 helper N, round 1, form a: module 285 (midi/midi_dispatch_handlers.s).
   MidiPkt_SetXferTotal_All: the all-data transfer size, the sum of the blocks the SetXferBlock_* functions of
   midi_dispatch_handlers.c set (live panel, panel memories, sequencer events, accompaniment blocks, song slots,
   current song, optional sound RAM / style image).  MidiPkt_UnpackNibblesToXfer: two nibbles of the active MIDI
   block per byte into the transfer at 0xbcec (start pointer, size at +8).
   Form b against a: the size sum with its constants pre-folded, and the unpack loop through explicit pointer
   locals (the ROM keeps &q->p6 in three places, &ram_bce4 and &q->wr in the frame).
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

	x->start = &LIVE_PANEL_BLOCK;
	n = MidiPkt_GetUsedSize_SeqEvents();
	x->size += &ram_ffbe - &LIVE_PANEL_BLOCK + 0x12cb2 + MidiPkt_GetUsedSize_AccompBlocks() + n + 0x5800;
	if (AccWrap_ReturnZero(1) != -1)
		x->size += 0x72aa;
	if (AccWrap_ReturnZero(3) != -1)
		x->size += MidiPkt_GetUsedSize_StyleImage();
	x->end = x->size + x->start;
}

int MidiPkt_UnpackNibblesToXfer(void)
{
	struct mq *q;
	unsigned char c;
	long n;
	unsigned char **hi;
	unsigned char **lo;
	unsigned char **d;
	long *left;
	long *cnt;
	unsigned char **cur;
	unsigned char **end;

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
