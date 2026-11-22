/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_29r1m236b.c (2026-11-22-11-p6-r78)
   sha256 291c40aba14bdf6facbfca79dc3faaa02f73bf1f18643ea9e7509a5c934fa2dd (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: PartCtrl_ReadWordWithBoundsChk=PartCtrl_ReadWordWithBoundsCheck */
extern unsigned char __near ram_27d2;
extern unsigned int __near ram_27d4;
extern unsigned int __near ram_27d6;
extern unsigned char __near ram_27dc;
extern unsigned char PartCtrl_ReadByteExtended(unsigned int b, unsigned int o);
extern void PartCtrl_ReadWordWithBoundsChk(unsigned int *, unsigned int *);
extern void PartCtrl_AdvanceToNextEntry(void);
extern void SeqPart_WriteByte_Primary(int);
unsigned char SeqPart_CompareLeft(void);
unsigned char SeqPart_ValidateLeft(unsigned char c)
{
	unsigned int x;
	unsigned char y;

	x = c;
	SeqPart_WriteByte_Primary(x);
	if (!(ram_27d2 & 1)) {
		PartCtrl_AdvanceToNextEntry();
		SeqPart_WriteByte_Primary(ram_27dc);
	}
	for (;;) {
		PartCtrl_ReadWordWithBoundsChk(&ram_27d4, &ram_27d6);
		PartCtrl_AdvanceToNextEntry();
		if ((y = PartCtrl_ReadByteExtended(ram_27d4, ram_27d6)) & 0x80)
			return SeqPart_CompareLeft();
		SeqPart_WriteByte_Primary(y);
	}
}
