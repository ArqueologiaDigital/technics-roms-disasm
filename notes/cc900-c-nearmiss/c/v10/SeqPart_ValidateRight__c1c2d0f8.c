/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_28r1m236f.c (2026-11-22-9-p6-r76)
   sha256 c1c2d0f81adbd774adc28e24296128cde82c1e804e372eeb5deeb3c963b3f9bf (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: PartCtrl_ReadWordWithBoundsChk=PartCtrl_ReadWordWithBoundsCheck */
extern unsigned char __near ram_27d2;
extern unsigned int __near ram_27d8;
extern unsigned int __near ram_27da;
extern unsigned char __near ram_27de;
extern unsigned char PartCtrl_ReadByteExtended(unsigned int b, unsigned int o);
extern void PartCtrl_ReadWordWithBoundsChk(unsigned int *, unsigned int *);
extern void PartCtrl_AdvanceToNextEntry(void);
extern void SeqPart_WriteByte_Primary(int);
unsigned char SeqPart_CompareRight(void);
unsigned char SeqPart_ValidateRight(unsigned char c)
{
	unsigned int x;

	x = c;
	SeqPart_WriteByte_Primary(x);
	if (ram_27d2 & 2)
		goto next;
	PartCtrl_AdvanceToNextEntry();
	x = ram_27de;
	for (;;) {
		SeqPart_WriteByte_Primary(x);
	next:
		PartCtrl_ReadWordWithBoundsChk(&ram_27d8, &ram_27da);
		PartCtrl_AdvanceToNextEntry();
		if ((x = PartCtrl_ReadByteExtended(ram_27d8, ram_27da)) & 0x80)
			return SeqPart_CompareRight();
	}
}
