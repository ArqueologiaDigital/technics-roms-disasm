/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqPart_CompareLeft SeqPart_CompareRight */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern void SeqPart_DualSwap(unsigned char a, unsigned char *l, unsigned char *r);

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
