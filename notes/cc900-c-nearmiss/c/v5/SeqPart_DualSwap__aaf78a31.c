/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine_m236.c (2026-11-18-33-p6-r37)
   sha256 aaf78a31cac362a0b5872a93882df0b70a8ffdffb2c46c431e7d8dc4f80cdd4b (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near SEQOP_PRIMARY_OFFSET;
extern unsigned int __near SEQOP_PRIMARY_BLOCK;
extern unsigned char __near ram_27b8;
extern unsigned char __near ram_266a;
extern unsigned int __near ram_2861;
extern unsigned int __near ram_27ba;
extern unsigned int __near ram_27bc;
extern unsigned int __near ram_27be;
extern unsigned int __near ram_27c0;
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
		ram_27b8 = 0xff;
		ram_2861 = ram_266a;
		Part_WriteWordAndByte(SEQOP_PRIMARY_BLOCK, (unsigned char)SEQOP_PRIMARY_OFFSET);
	} else {
		SeqPart_WriteByte_Primary(0x81);
		PartCtrl_AdvanceToNextEntry();
		PartCtrl_ReadWordWithBoundsCheck(&ram_27ba, &ram_27bc);
		*l = SeqPart_CompareLeft();
		PartCtrl_ReadWordWithBoundsCheck(&ram_27be, &ram_27c0);
		*r = SeqPart_CompareRight();
	}
}
