/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sequencer_engine_m236.c (2026-11-22-8-p6-r75)
   sha256 d34390834fa93cb1d308c8cc67c45d0e39301b201d69848ce9fc27b6ff77b04b (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: PartCtrl_ReadWordWithBoundsChk=PartCtrl_ReadWordWithBoundsCheck */
extern unsigned char __near ram_27d2;
extern unsigned char PartCtrl_ReadByteExtended(unsigned int b, unsigned int o);
extern void PartCtrl_ReadWordWithBoundsChk(unsigned int *, unsigned int *);
extern unsigned int __near ram_27d8;
extern unsigned int __near ram_27da;
extern unsigned char __near ram_27de;
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
