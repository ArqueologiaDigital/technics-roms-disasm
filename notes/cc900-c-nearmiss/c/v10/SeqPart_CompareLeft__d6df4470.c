/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_27r1m236c.c (2026-11-22-7-p6-r74)
   sha256 d6df447048381be6091bfe53d17b3bbb4a725e306a5e88292a69e7a2016dd5ed (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: PartCtrl_ReadWordWithBoundsChk=PartCtrl_ReadWordWithBoundsCheck */
extern unsigned char __near ram_27d2;
extern unsigned int __near ram_27d4;
extern unsigned int __near ram_27d6;
extern unsigned char __near ram_27dc;
extern unsigned char PartCtrl_ReadByteExtended(unsigned int b, unsigned int o);
extern void PartCtrl_ReadWordWithBoundsChk(unsigned int *, unsigned int *);
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
