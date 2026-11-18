/* Phase 6, lane_p6 helper J, round 2, module 236 (sequencer/sequencer_engine.s, -O3 -Xr), form a: SeqPart_DualSwap.
   a == 0x82: write the end mark and the primary cursor's word + byte; otherwise write 0x81, advance, and compare
   the left / right cursors (0x27d4 / 0x27d6, 0x27d8 / 0x27da, passed as `ld xwa,N` like &SEQOP_* in the matched
   C) into *l and *r.  Part_WriteWordAndByte gets the cursor offset's low byte zero-extended. */
/* cc900-module: SeqPart_CompareLeft SeqPart_CompareRight */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int __near SEQOP_PRIMARY_OFFSET;
extern unsigned int __near SEQOP_PRIMARY_BLOCK;
extern unsigned char __near ram_27d2;
extern unsigned char __near ram_2684;
extern unsigned int __near ram_287d;
extern unsigned int __near ram_27d4;
extern unsigned int __near ram_27d6;
extern unsigned int __near ram_27d8;
extern unsigned int __near ram_27da;
extern void SeqPart_WriteByte_Primary(int);
extern void Part_WriteWordAndByte(unsigned int, unsigned int);
extern void PartCtrl_AdvanceToNextEntry(void);
extern void PartCtrl_ReadWordWithBoundsCheck(unsigned int *, unsigned int *);
extern unsigned char SeqPart_CompareLeft(void);
extern unsigned char SeqPart_CompareRight(void);

void SeqPart_DualSwap(unsigned char a, unsigned char *l, unsigned char *r)
{
	if (a == 0x82) {
		SeqPart_WriteByte_Primary(a);
		ram_27d2 = 0xff;
		ram_287d = ram_2684;
		Part_WriteWordAndByte(SEQOP_PRIMARY_BLOCK, (unsigned char)SEQOP_PRIMARY_OFFSET);
	} else {
		SeqPart_WriteByte_Primary(0x81);
		PartCtrl_AdvanceToNextEntry();
		PartCtrl_ReadWordWithBoundsCheck(&ram_27d4, &ram_27d6);
		*l = SeqPart_CompareLeft();
		PartCtrl_ReadWordWithBoundsCheck(&ram_27d8, &ram_27da);
		*r = SeqPart_CompareRight();
	}
}
