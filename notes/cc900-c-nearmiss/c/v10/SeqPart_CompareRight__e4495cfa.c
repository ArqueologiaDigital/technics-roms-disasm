/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_27r1m236b.c (2026-11-22-7-p6-r74)
   sha256 e4495cfa95644bace3475611f060f20cc76d0bf928f87a27141c418b957419fb (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: PartCtrl_ReadWordWithBoundsChk=PartCtrl_ReadWordWithBoundsCheck */
extern unsigned char __near ram_27d2;
extern unsigned int __near ram_27d8;
extern unsigned int __near ram_27da;
extern unsigned char __near ram_27de;
extern unsigned char PartCtrl_ReadByteExtended(unsigned int b, unsigned int o);
extern void PartCtrl_ReadWordWithBoundsChk(unsigned int *, unsigned int *);
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
