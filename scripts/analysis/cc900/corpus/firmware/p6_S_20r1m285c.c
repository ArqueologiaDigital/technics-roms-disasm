/* Phase 6, lane_p6 helper S, round 1 of 2026-11-20, module 285 (midi/midi_dispatch_handlers.s), form c: one-spot
   retries of the span functions and of MidiPkt_SetXferTotal_SeqData.
   Spans (best p6_N_11m285a, run r56: +4, the same code with XBC / XDE swapped): the ROM keeps the start in XDE and
   the size in XBC.  Form c = form a (`n = (long)&end; n -= (long)p;`, n written twice as in the built
   MidiPkt_SetXferBlock_LivePanel's `- p + 2`) with n also declared `register long` (form b's spot).
   SeqData (best p6_N_11m285a, +31): V4.23 shared `n + 0x5800` between end and size; the ROM computes the end as
   lda (xhl+0x5800) + start, and the size afresh as 0x5800 then + n.  Form c writes the end as pointer arithmetic,
   start first, `x->start + 0x5800 + n`.
   cc900-options: -O3 -Xr
*/
/* cc900-module: MidiPkt_GetUsedSize_SeqEvents */
/* cc900-name: MidiPkt_SetXferBlk_StyleImgHdr=MidiPkt_SetXferBlock_StyleImageHeader */
/* cc900-name: MidiPkt_SetXferBlk_StyleImgTbl=MidiPkt_SetXferBlock_StyleImageTables */
/* cc900-name: MidiPkt_SetXferBlk_AccompArea=MidiPkt_SetXferBlock_AccompAreaHeader */
/* cc900-name: MidiPkt_SetXferBlk_AccompBank=MidiPkt_SetXferBlock_AccompBankTables */

struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char __near ram_bd18;
extern unsigned char RHYTHM_PATTERN_BUF_A[];
extern unsigned char ram_94860;
extern unsigned char ram_95bc0;
extern unsigned char __near SEQ_SONG_RECORD;
extern unsigned char ram_1e8800;
extern unsigned char ram_1e8820;
extern unsigned char ram_1e8b00;
extern long MidiPkt_GetUsedSize_SeqEvents(void);

void MidiPkt_SetXferBlk_StyleImgHdr(struct xfer *x)
{
	unsigned char *p = RHYTHM_PATTERN_BUF_A;
	register long n;

	x->start = p;
	n = (long)&ram_94860;
	n -= (long)p;
	x->end = (unsigned char *)((long)p + n);
	x->size = n;
}

void MidiPkt_SetXferBlk_StyleImgTbl(struct xfer *x)
{
	unsigned char *p = &ram_94860;
	register long n;

	x->start = p;
	n = (long)&ram_95bc0;
	n -= (long)p;
	x->end = (unsigned char *)((long)p + n);
	x->size = n;
}

void MidiPkt_SetXferTotal_SeqData(struct xfer *x)
{
	long n;

	x->end = (x->start = &SEQ_SONG_RECORD) + 0x53000;
	x->size = 0x53000;
	if (ram_bd18 & 0x40) {
		n = MidiPkt_GetUsedSize_SeqEvents();
		x->end = x->start + 0x5800 + n;
		x->size = 0x5800 + n;
	}
}

void MidiPkt_SetXferBlk_AccompArea(struct xfer *x)
{
	unsigned char *e;
	unsigned char *p = &ram_1e8800;
	register long n;

	x->start = p;
	n = (long)&ram_1e8820;
	n -= (long)p;
	e = n + p;
	x->end = e;
	x->size = n;
}

void MidiPkt_SetXferBlk_AccompBank(struct xfer *x)
{
	unsigned char *e;
	unsigned char *p = &ram_1e8820;
	register long n;

	x->start = p;
	n = (long)&ram_1e8b00;
	n -= (long)p;
	e = n + p;
	x->end = e;
	x->size = n;
}
