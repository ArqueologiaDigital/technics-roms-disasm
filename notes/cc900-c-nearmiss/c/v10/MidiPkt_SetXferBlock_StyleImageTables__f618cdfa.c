/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_12m285a.c (2026-11-19-92-p6-r57)
   sha256 f618cdfa7c1534c7b40e770f29d74dd3a78b1a6a1f4d7f411f4ccabdeec6a64d (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: MidiPkt_SetXferBlk_StyleImgTbl=MidiPkt_SetXferBlock_StyleImageTables */
struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char ram_94860;
extern unsigned char ram_95bc0;
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
