/* lane_p6 helper M, round 28r1, form d: module 236 (sequencer/sequencer_engine.s), SeqPart_ValidateRight /
   SeqPart_ValidateLeft only (helper J's p6_J_27r1m236c has the Compare pair).  One-spot retry of J's form c
   (run r74, equal to +0: the ROM homes the event byte in HL as a 16-bit value, ld l, a; extz hl; ld wa, hl on
   entry and bit 7, l; extz hl; ld wa, hl at the loop end, where V4.23 kept it in A).  Here the byte copied to an unsigned int local x (x = c; x = ram_27de; x = ReadByteExtended()).
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
		x = PartCtrl_ReadByteExtended(ram_27d8, ram_27da);
		if (x & 0x80)
			return SeqPart_CompareRight();
	}
}

unsigned char SeqPart_ValidateLeft(unsigned char c)
{
	unsigned int x;

	x = c;
	SeqPart_WriteByte_Primary(x);
	if (ram_27d2 & 1)
		goto next;
	PartCtrl_AdvanceToNextEntry();
	x = ram_27dc;
	for (;;) {
		SeqPart_WriteByte_Primary(x);
	next:
		PartCtrl_ReadWordWithBoundsChk(&ram_27d4, &ram_27d6);
		PartCtrl_AdvanceToNextEntry();
		x = PartCtrl_ReadByteExtended(ram_27d4, ram_27d6);
		if (x & 0x80)
			return SeqPart_CompareLeft();
	}
}
