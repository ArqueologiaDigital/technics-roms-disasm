/* lane_p6 helper N, round 12, form a: module 285 (midi/midi_dispatch_handlers.s), retries of the four span
   functions (p6-r56: +4, a register choice).  The ROM keeps the base in XDE and the size in XBC; V4.23 put the base
   in XBC (StyleImage*) or loaded it through XBC into XDE (Accomp*: the pointer's initialiser).  Round 11's form a
   of the Accomp pair (end declared first) gave the ROM's registers apart from that initialiser: here the base is
   assigned in a statement, and the StyleImage pair gets the same declarations with the end built in place on the
   base (`p += n`), as the ROM's `add xde,xbc`.
   cc900-options: -O3 -Xr
*/
/* cc900-name: MidiPkt_SetXferBlk_StyleImgHdr=MidiPkt_SetXferBlock_StyleImageHeader */
/* cc900-name: MidiPkt_SetXferBlk_StyleImgTbl=MidiPkt_SetXferBlock_StyleImageTables */
/* cc900-name: MidiPkt_SetXferBlk_AccompArea=MidiPkt_SetXferBlock_AccompAreaHeader */
/* cc900-name: MidiPkt_SetXferBlk_AccompBank=MidiPkt_SetXferBlock_AccompBankTables */

struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char RHYTHM_PATTERN_BUF_A[];
extern unsigned char ram_94860;
extern unsigned char ram_95bc0;
extern unsigned char ram_1e8800;
extern unsigned char ram_1e8820;
extern unsigned char ram_1e8b00;

void MidiPkt_SetXferBlk_StyleImgHdr(struct xfer *x)
{
	unsigned char *e;
	unsigned char *p;
	long n;

	p = RHYTHM_PATTERN_BUF_A;
	x->start = p;
	n = &ram_94860 - p;
	p += n;
	x->end = p;
	x->size = n;
}

void MidiPkt_SetXferBlk_StyleImgTbl(struct xfer *x)
{
	unsigned char *e;
	unsigned char *p;
	long n;

	p = &ram_94860;
	x->start = p;
	n = &ram_95bc0 - p;
	p += n;
	x->end = p;
	x->size = n;
}

void MidiPkt_SetXferBlk_AccompArea(struct xfer *x)
{
	unsigned char *e;
	unsigned char *p;
	long n;

	p = &ram_1e8800;
	x->start = p;
	n = &ram_1e8820 - p;
	e = n + p;
	x->end = e;
	x->size = n;
}

void MidiPkt_SetXferBlk_AccompBank(struct xfer *x)
{
	unsigned char *e;
	unsigned char *p;
	long n;

	p = &ram_1e8820;
	x->start = p;
	n = &ram_1e8b00 - p;
	e = n + p;
	x->end = e;
	x->size = n;
}
