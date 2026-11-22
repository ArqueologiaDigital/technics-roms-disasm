/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine_m236.c (2026-11-22-8-p6-r75)
   sha256 cc8231c80bdc29062f5f30d7c25d82b85abae0960f0b917d704ac71355084ff6 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: PartCtrl_ReadWordWithBoundsChk=PartCtrl_ReadWordWithBoundsCheck */
extern unsigned char __near ram_27b8;
extern unsigned int __near ram_27ba;
extern unsigned int __near ram_27bc;
extern unsigned char __near ram_27c2;
extern unsigned char PartCtrl_ReadByteExtended(unsigned int b, unsigned int o);
extern void PartCtrl_ReadWordWithBoundsChk(unsigned int *, unsigned int *);
unsigned char SeqPart_CompareLeft(void)
{
	unsigned char c;

	ram_27b8 &= ~1;
	c = PartCtrl_ReadByteExtended(ram_27ba, ram_27bc);
	if (c == 0x82 || c == 0x81)
		ram_27b8 |= 1;
	else {
		PartCtrl_ReadWordWithBoundsChk(&ram_27ba, &ram_27bc);
		ram_27c2 = PartCtrl_ReadByteExtended(ram_27ba, ram_27bc);
	}
	return c;
}
