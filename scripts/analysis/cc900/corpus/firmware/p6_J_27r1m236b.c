/* lane_p6 helper J, round 27r1, form b: module 236 (sequencer/sequencer_engine.s), two families of
   families27_J: SeqPart_CompareLeft / SeqPart_CompareRight (the comparison cursors 0x27d4 / 0x27d6 and
   0x27d8 / 0x27da: read the current byte, flag bit 0 / 1 of 0x27d2 on an end (0x82) or bar (0x81) marker, else step
   the cursor and keep the next byte in 0x27dc / 0x27de; the byte is homed in QIZ's high byte) and
   SeqPart_ValidateLeft / SeqPart_ValidateRight (copy one event to the primary write position, finishing in the
   Compare routine by a conditional tail jump).
   Form b: the Validate loops share one SeqPart_WriteByte_Primary(n) at the loop head (int n: ram_27dc / 27de
   or the byte read), entered past it by `goto next` when the end flag is set.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqPart_CompareLeft SeqPart_CompareRight */   /* scripts/analysis/cc900/module_calls.py v10 */
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

unsigned char SeqPart_ValidateRight(unsigned char c)
{
	int n;

	SeqPart_WriteByte_Primary(c);
	if (ram_27d2 & 2)
		goto next;
	PartCtrl_AdvanceToNextEntry();
	n = ram_27de;
	for (;;) {
		SeqPart_WriteByte_Primary(n);
	next:
		PartCtrl_ReadWordWithBoundsChk(&ram_27d8, &ram_27da);
		PartCtrl_AdvanceToNextEntry();
		c = PartCtrl_ReadByteExtended(ram_27d8, ram_27da);
		if (c & 0x80)
			return SeqPart_CompareRight();
		n = c;
	}
}

unsigned char SeqPart_ValidateLeft(unsigned char c)
{
	int n;

	SeqPart_WriteByte_Primary(c);
	if (ram_27d2 & 1)
		goto next;
	PartCtrl_AdvanceToNextEntry();
	n = ram_27dc;
	for (;;) {
		SeqPart_WriteByte_Primary(n);
	next:
		PartCtrl_ReadWordWithBoundsChk(&ram_27d4, &ram_27d6);
		PartCtrl_AdvanceToNextEntry();
		c = PartCtrl_ReadByteExtended(ram_27d4, ram_27d6);
		if (c & 0x80)
			return SeqPart_CompareLeft();
		n = c;
	}
}
