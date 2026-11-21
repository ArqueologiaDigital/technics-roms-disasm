/* helper U, round 21r1, module 285 (midi/midi_dispatch_handlers.s), form c: the four transfer-span setters.
   Every earlier form (p6_N_10/11/12m285a, p6_S_20r1m285a/b/c) gave the start in XBC and the size in XDE, the ROM
   has the start in XDE and computes the size in place in XBC from the end address (lda xbc; sub xbc, xde).  Here
   the end address gets its own pointer local q, DECLARED FIRST (declaration order decides the registers), and
   n = q - p.  The StyleImage pair ends with `add xde, xbc` (the start advanced in place), so x->end = p + n
   there; the Accomp pair keeps e = n + p (ld xhl, xbc; add xhl, xde), as the built MidiPkt_SetXferBlock_LivePanel.
   Form d: the same with q declared after p.
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
	unsigned char *q;
	unsigned char *p;
	long n;

	p = RHYTHM_PATTERN_BUF_A;
	x->start = p;
	q = &ram_94860;
	n = q - p;
	x->end = p + n;
	x->size = n;
}

void MidiPkt_SetXferBlk_StyleImgTbl(struct xfer *x)
{
	unsigned char *q;
	unsigned char *p;
	long n;

	p = &ram_94860;
	x->start = p;
	q = &ram_95bc0;
	n = q - p;
	x->end = p + n;
	x->size = n;
}

void MidiPkt_SetXferBlk_AccompArea(struct xfer *x)
{
	unsigned char *q;
	unsigned char *p;
	unsigned char *e;
	long n;

	p = &ram_1e8800;
	x->start = p;
	q = &ram_1e8820;
	n = q - p;
	e = n + p;
	x->end = e;
	x->size = n;
}

void MidiPkt_SetXferBlk_AccompBank(struct xfer *x)
{
	unsigned char *q;
	unsigned char *p;
	unsigned char *e;
	long n;

	p = &ram_1e8820;
	x->start = p;
	q = &ram_1e8b00;
	n = q - p;
	e = n + p;
	x->end = e;
	x->size = n;
}
