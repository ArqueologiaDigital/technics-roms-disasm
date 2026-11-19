/* lane_p6 helper N, round 10, form a: module 285 (midi/midi_dispatch_handlers.s), new functions of the built
   SetXferBlock family (cc900/midi_dispatch_handlers.c):
   - MidiPkt_SetXferTotal_StyleImage / _SeqData, MidiPkt_SetXferBlock_SeqEvents, MidiPkt_SetXferTotal_AccompBlocks:
     a fixed area `x->end = (x->start = base) + N`, size N, cut to the used size when bit 6 of 0xbd18 is set;
   - MidiPkt_SetXferBlock_StyleImageHeader / _StyleImageTables: the span between two area bases, end = start +
     size in the start's register (`add xde,xbc`);
   - MidiPkt_SetXferBlock_AccompAreaHeader / _AccompBankTables: the same spans in the built
     MidiPkt_SetXferBlock_LivePanel's spelling (`e = n + p`, a new register for the end).
   cc900-options: -O3 -Xr
*/
/* cc900-module: MidiPkt_GetUsedSize_AccompBlocks MidiPkt_GetUsedSize_SeqEvents MidiPkt_GetUsedSize_StyleImage */
/* cc900-name: MidiPkt_SetXferTotal_StyleImg=MidiPkt_SetXferTotal_StyleImage */
/* cc900-name: MidiPkt_SetXferBlk_StyleImgHdr=MidiPkt_SetXferBlock_StyleImageHeader */
/* cc900-name: MidiPkt_SetXferBlk_StyleImgTbl=MidiPkt_SetXferBlock_StyleImageTables */
/* cc900-name: MidiPkt_SetXferTotal_AccompBlk=MidiPkt_SetXferTotal_AccompBlocks */
/* cc900-name: MidiPkt_SetXferBlk_AccompArea=MidiPkt_SetXferBlock_AccompAreaHeader */
/* cc900-name: MidiPkt_SetXferBlk_AccompBank=MidiPkt_SetXferBlock_AccompBankTables */

struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char __near ram_bd18;
extern unsigned char RHYTHM_PATTERN_BUF_A[];
extern unsigned char ram_94860;
extern unsigned char ram_95bc0;
extern unsigned char __near SEQ_SONG_RECORD;
extern unsigned char ram_b0000[];
extern unsigned char ram_1e8800;
extern unsigned char ram_1e8820;
extern unsigned char ram_1e8b00;
extern long MidiPkt_GetUsedSize_StyleImage(void);
extern long MidiPkt_GetUsedSize_SeqEvents(void);
extern long MidiPkt_GetUsedSize_AccompBlocks(void);

void MidiPkt_SetXferTotal_StyleImg(struct xfer *x)
{
	long n;

	x->end = (x->start = RHYTHM_PATTERN_BUF_A) + 0x16800;
	x->size = 0x16800;
	if (ram_bd18 & 0x40) {
		n = MidiPkt_GetUsedSize_StyleImage();
		x->end = x->start + n;
		x->size = n;
	}
}

void MidiPkt_SetXferBlk_StyleImgHdr(struct xfer *x)
{
	unsigned char *p = RHYTHM_PATTERN_BUF_A;
	long n;

	x->start = p;
	n = &ram_94860 - p;
	x->end = p + n;
	x->size = n;
}

void MidiPkt_SetXferBlk_StyleImgTbl(struct xfer *x)
{
	unsigned char *p = &ram_94860;
	long n;

	x->start = p;
	n = &ram_95bc0 - p;
	x->end = p + n;
	x->size = n;
}

void MidiPkt_SetXferTotal_SeqData(struct xfer *x)
{
	long n;

	x->end = (x->start = &SEQ_SONG_RECORD) + 0x53000;
	x->size = 0x53000;
	if (ram_bd18 & 0x40) {
		n = MidiPkt_GetUsedSize_SeqEvents();
		x->end = n + 0x5800 + x->start;
		x->size = 0x5800 + n;
	}
}

void MidiPkt_SetXferBlock_SeqEvents(struct xfer *x)
{
	long n;

	x->end = (x->start = ram_b0000) + 0x4d800;
	x->size = 0x4d800;
	if (ram_bd18 & 0x40) {
		n = MidiPkt_GetUsedSize_SeqEvents();
		x->end = x->start + n;
		x->size = n;
	}
}

void MidiPkt_SetXferTotal_AccompBlk(struct xfer *x)
{
	long n;

	x->end = (x->start = &ram_1e8800) + 0x3c00;
	x->size = 0x3c00;
	if (ram_bd18 & 0x40) {
		n = MidiPkt_GetUsedSize_AccompBlocks();
		x->end = x->start + n;
		x->size = n;
	}
}

void MidiPkt_SetXferBlk_AccompArea(struct xfer *x)
{
	unsigned char *p = &ram_1e8800;
	unsigned char *e;
	long n;

	x->start = p;
	n = &ram_1e8820 - p;
	e = n + p;
	x->end = e;
	x->size = n;
}

void MidiPkt_SetXferBlk_AccompBank(struct xfer *x)
{
	unsigned char *p = &ram_1e8820;
	unsigned char *e;
	long n;

	x->start = p;
	n = &ram_1e8b00 - p;
	e = n + p;
	x->end = e;
	x->size = n;
}
