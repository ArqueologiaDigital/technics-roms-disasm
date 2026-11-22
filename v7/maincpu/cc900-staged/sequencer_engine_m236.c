/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqPart_CompareLeft SeqPart_CompareRight */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ram_27d2;
extern unsigned int __near ram_27d4;
extern unsigned int __near ram_27d6;
extern unsigned char __near ram_27dc;
extern unsigned char PartCtrl_ReadByteExtended(unsigned int b, unsigned int o);
extern void PartCtrl_ReadWordWithBoundsChk(unsigned int *, unsigned int *);
unsigned char SeqPart_CompareLeft(void);
unsigned char SeqPart_CompareRight(void);
extern unsigned char SeqPart_CompareLeft(void);
extern unsigned char SeqPart_CompareRight(void);
extern unsigned int __near ram_27d8;
extern unsigned int __near ram_27da;
extern unsigned char __near ram_27de;

/* cc900-name: PartCtrl_ReadWordWithBoundsChk=PartCtrl_ReadWordWithBoundsCheck */
unsigned char SeqPart_CompareLeft(void)
{
	unsigned char c;

	ram_27d2 &= ~1;
	c = PartCtrl_ReadByteExtended(ram_27d4, ram_27d6);
	if (c == 0x82 || c == 0x81)
		ram_27d2 |= 1;
	else {
		PartCtrl_ReadWordWithBoundsChk(&ram_27d4, &ram_27d6);
		ram_27dc = PartCtrl_ReadByteExtended(ram_27d4, ram_27d6);
	}
	return c;
}

/* cc900-name: PartCtrl_ReadWordWithBoundsChk=PartCtrl_ReadWordWithBoundsCheck */
unsigned char SeqPart_CompareRight(void)
{
	unsigned char c;

	ram_27d2 &= ~2;
	c = PartCtrl_ReadByteExtended(ram_27d8, ram_27da);
	if (c == 0x82 || c == 0x81)
		ram_27d2 |= 2;
	else {
		PartCtrl_ReadWordWithBoundsChk(&ram_27d8, &ram_27da);
		ram_27de = PartCtrl_ReadByteExtended(ram_27d8, ram_27da);
	}
	return c;
}
