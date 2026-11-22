/* lane_p6 helper N, round 29r1, form c: module 236 (sequencer/sequencer_engine.s), SeqPart_ValidateRight /
   SeqPart_ValidateLeft.  One-spot retry of helper M's p6_M_28r1m236f (run r76, O3Xr, +15: equal up to the advance
   path, where the ROM passes the stored byte straight in WA to a WriteByte call that the loop end shares, and the
   loop end tests bit 7 of the returned byte before it extends HL).  The stored byte passed directly, the read
   byte a char y tested before it becomes x; form a written with goto (the loop as a backward goto).
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqPart_CompareLeft SeqPart_CompareRight */
/* cc900-name: PartCtrl_ReadWordWithBoundsChk=PartCtrl_ReadWordWithBoundsCheck */
extern unsigned char __near ram_27d2;
extern unsigned int __near ram_27d4;
extern unsigned int __near ram_27d6;
extern unsigned int __near ram_27d8;
extern unsigned int __near ram_27da;
extern unsigned char __near ram_27dc;
extern unsigned char __near ram_27de;
extern unsigned char PartCtrl_ReadByteExtended(unsigned int b, unsigned int o);
extern void PartCtrl_ReadWordWithBoundsChk(unsigned int *, unsigned int *);
extern void PartCtrl_AdvanceToNextEntry(void);
extern void SeqPart_WriteByte_Primary(int);
unsigned char SeqPart_CompareLeft(void);
unsigned char SeqPart_CompareRight(void);



unsigned char SeqPart_ValidateRight(unsigned char c)
{
	unsigned int x;
	unsigned char y;

	x = c;
	SeqPart_WriteByte_Primary(x);
	if (ram_27d2 & 2)
		goto next;
	PartCtrl_AdvanceToNextEntry();
	SeqPart_WriteByte_Primary(ram_27de);
next:
	PartCtrl_ReadWordWithBoundsChk(&ram_27d8, &ram_27da);
	PartCtrl_AdvanceToNextEntry();
	if ((y = PartCtrl_ReadByteExtended(ram_27d8, ram_27da)) & 0x80)
		return SeqPart_CompareRight();
	x = y;
	SeqPart_WriteByte_Primary(x);
	goto next;
}

unsigned char SeqPart_ValidateLeft(unsigned char c)
{
	unsigned int x;
	unsigned char y;

	x = c;
	SeqPart_WriteByte_Primary(x);
	if (ram_27d2 & 1)
		goto next;
	PartCtrl_AdvanceToNextEntry();
	SeqPart_WriteByte_Primary(ram_27dc);
next:
	PartCtrl_ReadWordWithBoundsChk(&ram_27d4, &ram_27d6);
	PartCtrl_AdvanceToNextEntry();
	if ((y = PartCtrl_ReadByteExtended(ram_27d4, ram_27d6)) & 0x80)
		return SeqPart_CompareLeft();
	x = y;
	SeqPart_WriteByte_Primary(x);
	goto next;
}
