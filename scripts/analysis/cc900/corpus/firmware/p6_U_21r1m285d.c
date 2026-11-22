/* helper U, round 21r1, module 285, form d: the four transfer-span setters as form c, with the end-address local q
   declared AFTER the start pointer p (form c: before).
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
	unsigned char *p;
	unsigned char *q;
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
	unsigned char *p;
	unsigned char *q;
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
	unsigned char *p;
	unsigned char *q;
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
	unsigned char *p;
	unsigned char *q;
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
