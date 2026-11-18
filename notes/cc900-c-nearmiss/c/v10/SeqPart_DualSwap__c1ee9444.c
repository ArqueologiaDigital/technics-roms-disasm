/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine_m236.c (2026-11-18-33-p6-r37)
   sha256 c1ee9444d3715c8560069870677c7a1bb4c6cef9031c14a6c71a7bd3d8a7712e (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
