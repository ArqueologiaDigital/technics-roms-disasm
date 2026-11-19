/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: MidiPkt_GetUsedSize_AccompBlocks MidiPkt_GetUsedSize_SeqEvents MidiPkt_GetUsedSize_StyleImage */   /* scripts/analysis/cc900/module_calls.py v10 */

struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char __near ram_bc7c;
extern unsigned char ram_b0000[];
extern long MidiPkt_GetUsedSize_SeqEvents(void);
extern void MidiPkt_SetXferBlock_SeqEvents(struct xfer *x);
extern unsigned char ram_1e8800;
extern long MidiPkt_GetUsedSize_AccompBlocks(void);
extern void MidiPkt_SetXferTotal_AccompBlk(struct xfer *x);
extern unsigned char RHYTHM_PATTERN_BUF_A[];
extern long MidiPkt_GetUsedSize_StyleImage(void);
extern void MidiPkt_SetXferTotal_StyleImg(struct xfer *x);

void MidiPkt_SetXferBlock_SeqEvents(struct xfer *x)
{
	long n;

	x->end = (x->start = ram_b0000) + 0x4d800;
	x->size = 0x4d800;
	if (ram_bc7c & 0x40) {
		n = MidiPkt_GetUsedSize_SeqEvents();
		x->end = (unsigned char *)((long)x->start + n);
		x->size = n;
	}
}

/* cc900-name: MidiPkt_SetXferTotal_AccompBlk=MidiPkt_SetXferTotal_AccompBlocks */
void MidiPkt_SetXferTotal_AccompBlk(struct xfer *x)
{
	long n;

	x->end = (x->start = &ram_1e8800) + 0x3c00;
	x->size = 0x3c00;
	if (ram_bc7c & 0x40) {
		n = MidiPkt_GetUsedSize_AccompBlocks();
		x->end = (unsigned char *)((long)x->start + n);
		x->size = n;
	}
}

/* cc900-name: MidiPkt_SetXferTotal_StyleImg=MidiPkt_SetXferTotal_StyleImage */
void MidiPkt_SetXferTotal_StyleImg(struct xfer *x)
{
	long n;

	x->end = (x->start = RHYTHM_PATTERN_BUF_A) + 0x16800;
	x->size = 0x16800;
	if (ram_bc7c & 0x40) {
		n = MidiPkt_GetUsedSize_StyleImage();
		x->end = (unsigned char *)((long)x->start + n);
		x->size = n;
	}
}
