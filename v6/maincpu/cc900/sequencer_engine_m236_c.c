/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqPart_CompareLeft SeqPart_CompareRight */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ram_27b8;
extern unsigned int __near ram_27ba;
extern unsigned int __near ram_27bc;
extern unsigned char __near ram_27c2;
extern unsigned char PartCtrl_ReadByteExtended(unsigned int b, unsigned int o);
extern void PartCtrl_ReadWordWithBoundsChk(unsigned int *, unsigned int *);
extern void PartCtrl_AdvanceToNextEntry(void);
extern void SeqPart_WriteByte_Primary(int);
unsigned char SeqPart_CompareLeft(void);
unsigned char SeqPart_CompareRight(void);
extern unsigned char SeqPart_ValidateLeft(unsigned char c);
extern unsigned int __near ram_27be;
extern unsigned int __near ram_27c0;
extern unsigned char __near ram_27c4;
extern unsigned char SeqPart_ValidateRight(unsigned char c);

/* cc900-name: PartCtrl_ReadWordWithBoundsChk=PartCtrl_ReadWordWithBoundsCheck */
unsigned char SeqPart_ValidateLeft(unsigned char c)
{
	unsigned int x;
	unsigned char y;

	x = c;
	SeqPart_WriteByte_Primary(x);
	if (!(ram_27b8 & 1)) {
		PartCtrl_AdvanceToNextEntry();
		SeqPart_WriteByte_Primary(ram_27c2);
	}
	for (;;) {
		PartCtrl_ReadWordWithBoundsChk(&ram_27ba, &ram_27bc);
		PartCtrl_AdvanceToNextEntry();
		if ((y = PartCtrl_ReadByteExtended(ram_27ba, ram_27bc)) & 0x80)
			return SeqPart_CompareLeft();
		x = y;
		SeqPart_WriteByte_Primary(x);
	}
}

/* cc900-name: PartCtrl_ReadWordWithBoundsChk=PartCtrl_ReadWordWithBoundsCheck */
unsigned char SeqPart_ValidateRight(unsigned char c)
{
	unsigned int x;
	unsigned char y;

	x = c;
	SeqPart_WriteByte_Primary(x);
	if (!(ram_27b8 & 2)) {
		PartCtrl_AdvanceToNextEntry();
		SeqPart_WriteByte_Primary(ram_27c4);
	}
	for (;;) {
		PartCtrl_ReadWordWithBoundsChk(&ram_27be, &ram_27c0);
		PartCtrl_AdvanceToNextEntry();
		if ((y = PartCtrl_ReadByteExtended(ram_27be, ram_27c0)) & 0x80)
			return SeqPart_CompareRight();
		x = y;
		SeqPart_WriteByte_Primary(x);
	}
}
